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

private _sheepGroup = createGroup [sideAmbientLife, true];
private _safePos = [_centerPos, 25, 200, 5, 0, 0.4, 0] call BIS_fnc_findSafePos;
for "_s" from 1 to 5 do {
    private _spawnPos = _safePos getPos [random 10, random 360];
    private _sheep = _sheepGroup createUnit ["Sheep_random_F", _spawnPos, [], 0, "NONE"];
    _sheep setVariable ["LL_isAnimal", true];
};

private _spawnCount = (count _nodes) min _maxCivs;
private _spawnedCivs = [];

for "_i" from 1 to _spawnCount do {
    private _node = selectRandom _nodes;
    private _pos = getPosATL _node;
    private _isIndoor = false;
    
    if (_node isKindOf "House" || _node isKindOf "Building") then {
        private _bPosList = _node buildingPos -1;
        if (count _bPosList > 0) then { 
            _pos = selectRandom _bPosList; 
            _pos set [2, (_pos select 2) + 0.5];
            _isIndoor = true;
        };
    };
    
    private _grp = createGroup [civilian, true];
    private _civ = _grp createUnit ["C_man_1", _pos, [], 0, "CAN_COLLIDE"];
    _civ setPosATL _pos;
    
    if (_isIndoor) then {
        private _posASL = getPosASL _civ;
        private _terrainZ = getTerrainHeightASL [_posASL select 0, _posASL select 1];
        if ((_posASL select 2) < _terrainZ + 0.3) then {
            private _fallback = [_node, 5, 30, 3, 0, 0.4, 0] call BIS_fnc_findSafePos;
            _civ setPosATL [_fallback select 0, _fallback select 1, 0];
        };
    };
    
    _civ disableAI "TARGET";
    _civ disableAI "AUTOTARGET";
    _civ disableAI "MINEDETECTION";
    _civ disableAI "SUPPRESSION";
    _civ disableAI "COVER";
    
    private _isFemale = (random 1) < 0.10;
    [_civ, _isFemale, false] execVM "Functions\Civilian\fn_applyTakistaniIdentity.sqf";
    
    if ((random 100) <= 20 && {count _otherZonePos > 0}) then {
        _civ setVariable ["LL_profile", "TRAVELER"];
        _civ setVariable ["LL_travelNodes", _validTowns];
        _civ setVariable ["LL_travelIndex", 0];
    } else {
        _civ setVariable ["LL_profile", "LOCAL"];
    };
    
    _civ addEventHandler ["FiredNear", {
        params ["_unit", "_firer", "_distance", "_weapon", "_muzzle", "_mode", "_ammo", "_gunner"];
        if (_distance < 150) then {
            _unit setVariable ["LL_fleeTime", time + 60 + random 60];
        };
    }];
    
    _civ allowDamage false;
    [_civ] spawn { sleep 3; (_this select 0) allowDamage true; };
    
    _spawnedCivs pushBack _civ;
    sleep 0.1;
};

private _allEntities = _spawnedCivs + (units _sheepGroup);

{
    [_x, _nodes, _otherZonePos] spawn {
        params ["_unit", "_nodes", "_otherZonePos"];
        
        while { alive _unit } do {
            if (!(_unit getVariable ["LL_hasBeenSeen", false])) then {
                if (player distance2D _unit < 800) then {
                    _unit setVariable ["LL_hasBeenSeen", true];
                };
            } else {
                if (player distance2D _unit > 1000) exitWith {
                    deleteVehicle _unit;
                };
            };
            
            if (!alive _unit) exitWith {};
            
            if (_unit getVariable ["LL_isAnimal", false]) then {
                sleep 10;
            } else {
                private _fleeTime = _unit getVariable ["LL_fleeTime", 0];
                private _isFleeing = time < _fleeTime;
                
                private _profile = _unit getVariable ["LL_profile", "LOCAL"];
                private _targetPos = [];
                
                if (_isFleeing) then {
                    private _node = selectRandom _nodes;
                    _targetPos = getPosATL _node;
                    if (_node isKindOf "House" || _node isKindOf "Building") then {
                        private _bPosList = _node buildingPos -1;
                        if (count _bPosList > 0) then { _targetPos = selectRandom _bPosList; };
                    };
                    
                    _unit setBehaviour "CARELESS";
                    _unit setSpeedMode "FULL";
                    _unit setUnitPos "UP";
                } else {
                    _unit setBehaviour "SAFE";
                    _unit setSpeedMode "LIMITED";
                    _unit setUnitPos "UP";
                    
                    if (_profile == "LOCAL") then {
                        private _node = selectRandom _nodes;
                        _targetPos = getPosATL _node;
                        if (_node isKindOf "House" || _node isKindOf "Building") then {
                            private _bPosList = _node buildingPos -1;
                            if (count _bPosList > 0) then { _targetPos = selectRandom _bPosList; };
                        };
                    } else {
                        private _towns = _unit getVariable ["LL_travelNodes", []];
                        private _idx = _unit getVariable ["LL_travelIndex", 0];
                        
                        if (_idx < count _towns) then {
                            _targetPos = locationPosition (_towns select _idx);
                        } else {
                            _targetPos = _otherZonePos;
                        };
                    };
                };
                
                if (count _targetPos > 0) then {
                    _unit doMove _targetPos;
                    
                    private _timeout = time + 180;
                    waitUntil {
                        sleep 2;
                        !alive _unit || {(_unit distance2D _targetPos) < 15} || {time > _timeout} || {time < _unit getVariable ["LL_fleeTime", 0] && !_isFleeing}
                    };
                    
                    if (alive _unit) then {
                        if (time < _unit getVariable ["LL_fleeTime", 0]) then {
                            _unit setUnitPos "DOWN";
                            sleep (5 + random 15);
                        } else {
                            if (_profile == "TRAVELER") then {
                                private _idx = _unit getVariable ["LL_travelIndex", 0];
                                _unit setVariable ["LL_travelIndex", _idx + 1];
                                
                                sleep (5 + random 10);
                                
                                if (_unit distance2D _otherZonePos < 150) then {
                                    _unit setVariable ["LL_profile", "LOCAL"];
                                };
                            } else {
                                sleep (10 + random 40);
                            };
                        };
                    };
                };
            };
        };
    };
} forEach _allEntities;
