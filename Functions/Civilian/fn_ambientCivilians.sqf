if (!isServer) exitWith {};

params [
    ["_centerPos", [0,0,0], [[]]],
    ["_radius", 400, [0]],
    ["_maxCivs", 35, [0]],
    ["_otherZonePos", [], [[]]]
];

if (_centerPos isEqualTo [0,0,0]) exitWith {};

private _nodes = nearestObjects [_centerPos, ["Logic", "Land_HelipadEmpty_F", "House", "Building"], _radius];
if (count _nodes == 0) exitWith {};

private _validTowns = [];
if (count _otherZonePos > 0) then {
    private _distToTarget = _centerPos distance2D _otherZonePos;
    private _towns = nearestLocations [_centerPos, ["NameVillage", "NameCity", "NameCityCapital", "NameLocal"], _distToTarget];
    {
        private _pos = locationPosition _x;
        if ((_pos distance2D _otherZonePos) < _distToTarget && (_pos distance2D _centerPos) > 150) then {
            _validTowns pushBack _x;
        };
    } forEach _towns;
};

private _outdoorNodes = [];
private _buildingNodes = [];
{
    if (_x isKindOf "House" || _x isKindOf "Building") then {
        _buildingNodes pushBack _x;
    } else {
        _outdoorNodes pushBack _x;
    };
} forEach _nodes;

if (count _outdoorNodes == 0) then { _outdoorNodes = _nodes; };

private _zoneRoads = _centerPos nearRoads _radius;
private _hasRoads = count _zoneRoads > 0;
private _hasOtherZone = count _otherZonePos > 0;

private _spawnCount = (count _nodes) min _maxCivs;
private _spawnedCivs = [];
private _globalCivs = missionNamespace getVariable ["MISSION_var_ambientCivs", []];

for "_i" from 1 to _spawnCount do {
    private _node = selectRandom _nodes;
    private _pos = getPosATL _node;
    private _isIndoor = false;
    private _homeBuilding = objNull;

    if (_node isKindOf "House" || _node isKindOf "Building") then {
        private _bPosList = _node buildingPos -1;
        if (count _bPosList > 0) then {
            _pos = selectRandom _bPosList;
            _pos set [2, (_pos select 2) + 0.2];
            _isIndoor = true;
            _homeBuilding = _node;
        };
    };

    private _roll = random 100;
    private _profile = "LOCAL";

    if (_isIndoor) then {
        if (_roll < 70) then {
            _profile = "INDOOR";
        } else {
            _profile = "LOCAL";
        };
    } else {
        if (_roll < 25) then {
            _profile = "LOCAL";
        } else {
            if (_roll < 45 && {_hasRoads}) then {
                _profile = "ROAD_WALKER";
            } else {
                if (_roll < 60 && {_hasOtherZone}) then {
                    _profile = "TRAVELER";
                } else {
                    if (_roll < 70) then {
                        _profile = "MARKET";
                    } else {
                        if (_roll < 78) then {
                            _profile = "SITTER";
                        } else {
                            _profile = "LOCAL";
                        };
                    };
                };
            };
        };
    };

    private _fleeRoll = random 100;
    private _fleeStrategy = "FLEE_DIRECT";
    if (_fleeRoll < 30) then {
        _fleeStrategy = "FLEE_ROAD";
    } else {
        if (_fleeRoll < 55) then {
            _fleeStrategy = "FLEE_DIRECT";
        } else {
            if (_fleeRoll < 80) then {
                _fleeStrategy = "FLEE_HIDE";
            } else {
                _fleeStrategy = "FLEE_SCATTER";
            };
        };
    };

    if (_fleeStrategy == "FLEE_ROAD" && {!_hasRoads}) then { _fleeStrategy = "FLEE_DIRECT"; };

    private _grp = createGroup [civilian, true];
    private _civ = _grp createUnit ["C_man_1", _pos, [], 0, "CAN_COLLIDE"];
    _civ setPosATL _pos;

    _civ setVariable ["LL_isIndoor", _isIndoor];
    _civ setVariable ["LL_homeBuilding", _homeBuilding];
    _civ setVariable ["LL_profile", _profile];
    _civ setVariable ["LL_fleeStrategy", _fleeStrategy];
    _civ setVariable ["LL_lastRoadPos", getPosATL _civ];

    if (_profile == "TRAVELER") then {
        _civ setVariable ["LL_travelNodes", _validTowns];
        _civ setVariable ["LL_travelIndex", 0];
    };

    _civ disableAI "TARGET";
    _civ disableAI "AUTOTARGET";
    _civ disableAI "MINEDETECTION";
    _civ disableAI "SUPPRESSION";
    _civ disableAI "COVER";
    _civ disableAI "AUTOCOMBAT";

    private _isFemale = (random 1) < 0.10;
    [_civ, _isFemale, false] execVM "Functions\Civilian\fn_applyTakistaniIdentity.sqf";

    _civ addEventHandler ["FiredNear", {
        params ["_unit", "_firer", "_distance"];
        if (_distance < 150) then {
            private _fleeEnd = time + 60 + random 60;
            _unit setVariable ["LL_fleeTime", _fleeEnd];
            _unit setVariable ["LL_fleeOrigin", getPosATL _firer];
            {
                if (_x != _unit && {side _x == civilian} && {_x getVariable ["LL_fleeTime", 0] < time}) then {
                    [_x, _fleeEnd, getPosATL _firer] spawn {
                        params ["_u", "_ft", "_fo"];
                        sleep (1 + random 4);
                        if (!isNull _u && {alive _u}) then {
                            _u setVariable ["LL_fleeTime", _ft];
                            _u setVariable ["LL_fleeOrigin", _fo];
                        };
                    };
                };
            } forEach (_unit nearEntities ["Man", 50]);
        };
    }];

    _civ allowDamage false;
    [_civ] spawn {
        sleep 3;
        if (!isNull (_this select 0)) then { (_this select 0) allowDamage true; };
    };

    _spawnedCivs pushBack _civ;
    _globalCivs pushBack _civ;
    sleep 0.1;
};

missionNamespace setVariable ["MISSION_var_ambientCivs", _globalCivs];

{
    [_x, _outdoorNodes, _buildingNodes, _otherZonePos, _zoneRoads] spawn {
        params ["_unit", "_outdoorNodes", "_buildingNodes", "_otherZonePos", "_zoneRoads"];

        private _fnc_nearestRoad = {
            params ["_pos"];
            private _r = _pos nearRoads 100;
            if (count _r > 0) then { _r select 0 } else { objNull }
        };

        private _fnc_roadToward = {
            params ["_pos", "_toward"];
            private _r = _pos nearRoads 80;
            private _best = objNull;
            private _bestDist = 999999;
            {
                private _connected = roadsConnectedTo _x;
                {
                    private _cPos = getPos _x;
                    private _d = _cPos distance2D _toward;
                    if (_d < _bestDist && {_cPos distance2D _pos > 5}) then {
                        _bestDist = _d;
                        _best = _x;
                    };
                } forEach _connected;
            } forEach _r;
            _best
        };

        private _fnc_nextRoad = {
            params ["_road", "_prevPos"];
            private _connected = roadsConnectedTo _road;
            if (count _connected == 0) exitWith { objNull };
            private _best = objNull;
            private _bestDist = 0;
            {
                private _d = (getPos _x) distance2D _prevPos;
                if (_d > _bestDist) then { _bestDist = _d; _best = _x; };
            } forEach _connected;
            _best
        };

        while { !isNull _unit && { alive _unit } } do {
            private _fleeTime = _unit getVariable ["LL_fleeTime", 0];
            private _isFleeing = time < _fleeTime;
            private _profile = _unit getVariable ["LL_profile", "LOCAL"];
            private _isIndoor = _unit getVariable ["LL_isIndoor", false];
            private _homeBuilding = _unit getVariable ["LL_homeBuilding", objNull];
            private _targetPos = [];
            private _waitTime = 10 + random 40;
            private _moveTimeout = 120;

            if (_isFleeing) then {
                private _fleeStrategy = _unit getVariable ["LL_fleeStrategy", "FLEE_DIRECT"];
                private _fleeOrigin = _unit getVariable ["LL_fleeOrigin", [0,0,0]];

                if (_fleeStrategy != "FLEE_HIDE" && {_isIndoor} && {!isNull _homeBuilding}) then {
                    _unit setVariable ["LL_isIndoor", false];
                    _unit setVariable ["LL_homeBuilding", objNull];
                    _unit setVariable ["LL_profile", "LOCAL"];
                };

                _unit enableAI "MOVE";
                _unit switchMove "";
                _unit setBehaviour "AWARE";
                _unit setSpeedMode "FULL";
                _unit setUnitPos "UP";

                switch (_fleeStrategy) do {
                    case "FLEE_ROAD": {
                        if (count _otherZonePos > 0) then {
                            private _nextRoad = [getPosATL _unit, _otherZonePos] call _fnc_roadToward;
                            if (!isNull _nextRoad) then {
                                _targetPos = (getPos _nextRoad) getPos [1 + random 2, random 360];
                            } else {
                                private _nr = [getPosATL _unit] call _fnc_nearestRoad;
                                if (!isNull _nr) then {
                                    _targetPos = (getPos _nr) getPos [1 + random 2, random 360];
                                } else {
                                    _targetPos = _otherZonePos getPos [random 200, random 360];
                                };
                            };
                        } else {
                            _targetPos = (getPosATL _unit) getPos [80 + random 120, random 360];
                        };
                        _moveTimeout = 45;
                    };

                    case "FLEE_DIRECT": {
                        if (count _otherZonePos > 0) then {
                            _targetPos = _otherZonePos getPos [random 200, random 360];
                        } else {
                            private _awayDir = if (!(_fleeOrigin isEqualTo [0,0,0])) then {
                                _fleeOrigin getDir (getPosATL _unit)
                            } else { random 360 };
                            _targetPos = (getPosATL _unit) getPos [150 + random 100, _awayDir + (-30 + random 60)];
                        };
                        _moveTimeout = 60;
                    };

                    case "FLEE_HIDE": {
                        if (_isIndoor && {!isNull _homeBuilding}) then {
                            private _bPosList = _homeBuilding buildingPos -1;
                            if (count _bPosList > 0) then {
                                _targetPos = selectRandom _bPosList;
                                _targetPos set [2, (_targetPos select 2) + 0.2];
                            };
                        } else {
                            private _nearBldgs = nearestObjects [getPosATL _unit, ["House", "Building"], 150];
                            if (count _nearBldgs > 0) then {
                                private _hideBldg = _nearBldgs select 0;
                                private _bPosList = _hideBldg buildingPos -1;
                                if (count _bPosList > 0) then {
                                    _targetPos = selectRandom _bPosList;
                                    _targetPos set [2, (_targetPos select 2) + 0.2];
                                    _unit setVariable ["LL_isIndoor", true];
                                    _unit setVariable ["LL_homeBuilding", _hideBldg];
                                    _unit setVariable ["LL_profile", "INDOOR"];
                                } else {
                                    _targetPos = (getPosATL _hideBldg) getPos [2, random 360];
                                };
                            } else {
                                private _awayDir = if (!(_fleeOrigin isEqualTo [0,0,0])) then {
                                    _fleeOrigin getDir (getPosATL _unit)
                                } else { random 360 };
                                _targetPos = (getPosATL _unit) getPos [100 + random 80, _awayDir + (-45 + random 90)];
                            };
                        };
                        _moveTimeout = 30;
                    };

                    case "FLEE_SCATTER": {
                        private _awayDir = if (!(_fleeOrigin isEqualTo [0,0,0])) then {
                            (_fleeOrigin getDir (getPosATL _unit)) + (-90 + random 180)
                        } else { random 360 };
                        _targetPos = (getPosATL _unit) getPos [60 + random 100, _awayDir];
                        _moveTimeout = 30;
                    };
                };

                _waitTime = 2 + random 5;

            } else {
                _unit setBehaviour "CARELESS";
                _unit setSpeedMode "LIMITED";
                _unit setUnitPos "UP";

                switch (_profile) do {
                    case "INDOOR": {
                        if (!isNull _homeBuilding) then {
                            private _bPosList = _homeBuilding buildingPos -1;
                            if (count _bPosList > 0) then {
                                _targetPos = selectRandom _bPosList;
                                _targetPos set [2, (_targetPos select 2) + 0.2];
                            };
                        };
                        _waitTime = 15 + random 45;
                        _moveTimeout = 120;
                    };

                    case "LOCAL": {
                        private _node = selectRandom _outdoorNodes;
                        _targetPos = (getPosATL _node) getPos [1 + random 3, random 360];
                        _waitTime = 10 + random 30;
                        _moveTimeout = 180;
                    };

                    case "ROAD_WALKER": {
                        private _lastPos = _unit getVariable ["LL_lastRoadPos", getPosATL _unit];
                        private _nr = [getPosATL _unit] call _fnc_nearestRoad;
                        if (!isNull _nr) then {
                            private _next = [_nr, _lastPos] call _fnc_nextRoad;
                            if (!isNull _next) then {
                                _targetPos = (getPos _next) getPos [random 2, random 360];
                            } else {
                                _targetPos = (getPos _nr) getPos [1 + random 2, random 360];
                            };
                        } else {
                            private _node = selectRandom _outdoorNodes;
                            _targetPos = (getPosATL _node) getPos [1 + random 3, random 360];
                        };
                        _unit setVariable ["LL_lastRoadPos", getPosATL _unit];
                        _waitTime = 3 + random 8;
                        _moveTimeout = 60;
                    };

                    case "TRAVELER": {
                        private _towns = _unit getVariable ["LL_travelNodes", []];
                        private _idx = _unit getVariable ["LL_travelIndex", 0];
                        private _dest = [];

                        if (_idx < count _towns) then {
                            _dest = locationPosition (_towns select _idx);
                        } else {
                            if (count _otherZonePos > 0) then { _dest = _otherZonePos; };
                        };

                        if (count _dest > 0) then {
                            private _nextRoad = [getPosATL _unit, _dest] call _fnc_roadToward;
                            if (!isNull _nextRoad) then {
                                _targetPos = (getPos _nextRoad) getPos [random 2, random 360];
                            } else {
                                _targetPos = _dest getPos [random 5, random 360];
                            };
                        } else {
                            private _node = selectRandom _outdoorNodes;
                            _targetPos = (getPosATL _node) getPos [1 + random 3, random 360];
                        };
                        _waitTime = 5 + random 10;
                        _moveTimeout = 120;
                    };

                    case "MARKET": {
                        if (count _buildingNodes > 0) then {
                            private _bldg = selectRandom _buildingNodes;
                            _targetPos = (getPosATL _bldg) getPos [3 + random 3, random 360];
                        } else {
                            private _node = selectRandom _outdoorNodes;
                            _targetPos = (getPosATL _node) getPos [1 + random 3, random 360];
                        };
                        _waitTime = 30 + random 60;
                        _moveTimeout = 120;
                    };

                    case "SITTER": {
                        if (count _buildingNodes > 0) then {
                            private _bldg = selectRandom _buildingNodes;
                            _targetPos = (getPosATL _bldg) getPos [2 + random 4, random 360];
                        } else {
                            private _node = selectRandom _outdoorNodes;
                            _targetPos = (getPosATL _node) getPos [1 + random 3, random 360];
                        };
                        _waitTime = 60 + random 120;
                        _moveTimeout = 120;
                    };
                };
            };

            if (count _targetPos > 0) then {
                _unit doMove _targetPos;

                private _timeout = time + _moveTimeout;
                waitUntil {
                    sleep 2;
                    isNull _unit || {!alive _unit} ||
                    {(_unit distance2D _targetPos) < 3} ||
                    {time > _timeout} ||
                    {(time < _unit getVariable ["LL_fleeTime", 0]) && !_isFleeing}
                };

                if (!isNull _unit && { alive _unit }) then {
                    if (time < _unit getVariable ["LL_fleeTime", 0]) then {
                        private _fs = _unit getVariable ["LL_fleeStrategy", "FLEE_DIRECT"];
                        if (_fs == "FLEE_HIDE" && {_unit getVariable ["LL_isIndoor", false]}) then {
                            _unit setUnitPos "DOWN";
                            private _hideEnd = time + 5 + random 10;
                            waitUntil {
                                sleep 1;
                                isNull _unit || {!alive _unit} || {time > _hideEnd}
                            };
                            if (!isNull _unit && {alive _unit}) then { _unit setUnitPos "UP"; };
                        } else {
                            if (random 1 < 0.3) then {
                                _unit setUnitPos "MIDDLE";
                                sleep (1 + random 3);
                                if (!isNull _unit && {alive _unit}) then { _unit setUnitPos "UP"; };
                            };
                        };
                    } else {
                        if (_profile == "TRAVELER") then {
                            private _idx = _unit getVariable ["LL_travelIndex", 0];
                            _unit setVariable ["LL_travelIndex", _idx + 1];

                            private _twEnd = time + 3 + random 8;
                            waitUntil {
                                sleep 1;
                                isNull _unit || {!alive _unit} || {time > _twEnd} ||
                                {time < _unit getVariable ["LL_fleeTime", 0]}
                            };

                            if (!isNull _unit && {alive _unit} && {count _otherZonePos > 0}) then {
                                if (_unit distance2D _otherZonePos < 150) then {
                                    _unit setVariable ["LL_profile", "LOCAL"];
                                };
                            };
                        } else {
                            if (_profile == "SITTER") then {
                                _unit setUnitPos "DOWN";
                                private _sEnd = time + _waitTime;
                                waitUntil {
                                    sleep 1;
                                    isNull _unit || {!alive _unit} || {time > _sEnd} ||
                                    {time < _unit getVariable ["LL_fleeTime", 0]}
                                };
                                if (!isNull _unit && {alive _unit}) then { _unit setUnitPos "UP"; };
                            } else {
                                if (_profile == "MARKET") then {
                                    if (random 1 < 0.5) then {
                                        _unit setDir ((getDir _unit) + (-45 + random 90));
                                    };
                                };
                                private _wEnd = time + _waitTime;
                                waitUntil {
                                    sleep 1;
                                    isNull _unit || {!alive _unit} || {time > _wEnd} ||
                                    {time < _unit getVariable ["LL_fleeTime", 0]}
                                };
                            };
                        };
                    };
                };
            } else {
                sleep 5;
            };
        };
    };
} forEach _spawnedCivs;

if (isNil "MISSION_var_civDespawnLoopStarted") then {
    MISSION_var_civDespawnLoopStarted = true;

    [] spawn {
        waitUntil {
            sleep 2;
            private _targetPos = missionNamespace getVariable ["MISSION_var_targetPos", [0,0,0]];
            !(_targetPos isEqualTo [0,0,0]) && { (player distance2D _targetPos) <= 800 }
        };

        while { true } do {
            sleep 120;
            private _allCivs = missionNamespace getVariable ["MISSION_var_ambientCivs", []];
            _allCivs = _allCivs select { !isNull _x && { alive _x } };

            private _remainingCivs = [];
            {
                if ((player distance2D _x) >= 1500) then {
                    deleteVehicle _x;
                } else {
                    _remainingCivs pushBack _x;
                };
            } forEach _allCivs;

            missionNamespace setVariable ["MISSION_var_ambientCivs", _remainingCivs];
        };
    };
};
