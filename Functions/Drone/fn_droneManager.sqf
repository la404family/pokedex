if (!isServer) exitWith {};

missionNamespace setVariable ["LL_Drone_Active", false, true];
missionNamespace setVariable ["LL_DRONE_pending", [], false];

while { true } do {
    sleep 0.5;

    private _pending = missionNamespace getVariable ["LL_DRONE_pending", []];
    if (count _pending > 0) then {
        _pending params ["_type", "_targetPos", "_caller"];
        missionNamespace setVariable ["LL_DRONE_pending", [], false];

        LL_Drone_Active = true;
        publicVariable "LL_Drone_Active";

        private _altitude = 350;
        private _orbitRadius = 400;
        private _scanRadius = 500;
        private _duration = 300;
        
        if (count _targetPos < 3) then { _targetPos resize 3; };
        { if (isNil "_targetPos") exitWith {}; if (isNil { _targetPos # _forEachIndex }) then { _targetPos set [_forEachIndex, 0]; }; } forEach _targetPos;

        private _spawnPos = [_targetPos select 0, (_targetPos select 1) - 3000, _altitude];

        private _drone = createVehicle ["CUP_B_USMC_DYN_MQ9", _spawnPos, [], 0, "FLY"];
        _drone setDir (_spawnPos getDir _targetPos);
        _drone setVelocityModelSpace [0, 80, 0];
        _drone flyInHeight _altitude;
        createVehicleCrew _drone;
        private _grp = group (driver _drone);

        _drone allowDamage false;
        _drone setCaptive true;

        _grp setCombatMode "RED";
        _grp setBehaviour "COMBAT";
        {
            _x allowDamage false;
            _x disableAI "SUPPRESSION";
        } forEach units _grp;

        _grp addEventHandler ["EnemyDetected", {
            params ["_grp", "_detected"];
            if (_detected isKindOf "Man") then {
                { _x forgetTarget _detected } forEach units _grp;
            };
        }];

        private _markerArea = createMarker ["LL_Drone_Area", _targetPos];
        _markerArea setMarkerShape "ELLIPSE";
        _markerArea setMarkerSize [_orbitRadius, _orbitRadius];
        _markerArea setMarkerColor "ColorBlue";
        _markerArea setMarkerAlpha 0.15;
        _markerArea setMarkerBrush "SolidBorder";

        private _markerIcon = createMarker ["LL_Drone_Icon", _targetPos];
        _markerIcon setMarkerType "b_air";
        _markerIcon setMarkerColor "ColorBlue";
        _markerIcon setMarkerSize [1.2, 1.2];
        _markerIcon setMarkerText "  MQ-9 Reaper";

        private _markerDroneName = format ["LL_Drone_Pos_%1", floor(random 1000)];
        private _markerDrone = createMarker [_markerDroneName, getPosATL _drone];
        _markerDrone setMarkerType "mil_triangle";
        _markerDrone setMarkerColor "ColorCIV";
        _markerDrone setMarkerSize [0.9, 0.9];

        ["STR_Drone_Approach", [round (_duration / 60)]] call LL_fnc_radioMessage;

        private _wp = _grp addWaypoint [_targetPos, 0];
        _wp setWaypointType "LOITER";
        _wp setWaypointLoiterRadius _orbitRadius;
        _wp setWaypointLoiterType "CIRCLE";
        _wp setWaypointSpeed "LIMITED";

        private _endTime = time + _duration;
        private _enemyMarkers = createHashMap;

        while { time < _endTime && alive _drone && !(missionNamespace getVariable ["LL_Drone_Jammed", false]) } do {
            _markerDrone setMarkerPos (getPosATL _drone);

            private _enemies = [];
            if ((_drone distance2D _targetPos) <= (_orbitRadius + 200)) then {
                _enemies = _targetPos nearEntities [["Car", "Tank", "Helicopter", "Plane", "Ship", "Man"], _scanRadius];
                _enemies = _enemies select { alive _x && (side _x == east || _x in (missionNamespace getVariable ["LL_Task08_Targets", []])) };
            };

            private _currentEnemyIds = [];

            {
                private _id = str (netId _x);
                _currentEnemyIds pushBack _id;
                private _mName = format ["LL_Drone_Enemy_%1", _id];

                if !(_id in keys _enemyMarkers) then {
                    createMarker [_mName, getPosATL _x];
                    _mName setMarkerType "mil_dot";
                    _mName setMarkerColor "ColorRed";
                    _mName setMarkerSize [0.7, 0.7];
                    _enemyMarkers set [_id, _mName];
                };

                _mName setMarkerPos (getPosATL _x);
            } forEach _enemies;

            private _toRemove = [];
            {
                private _eid = _x;
                private _mkr = _y;
                if !(_eid in _currentEnemyIds) then {
                    deleteMarker _mkr;
                    _toRemove pushBack _eid;
                };
            } forEach _enemyMarkers;
            { _enemyMarkers deleteAt _x; } forEach _toRemove;

            {
                private _ltW = _x getVariable ["LL_LaserTargetW", objNull];
                if (!alive _x && !isNull _ltW) then {
                    deleteVehicle _ltW;
                    _x setVariable ["LL_LaserTargetW", objNull];
                };
                private _ltC = _x getVariable ["LL_LaserTargetC", objNull];
                if (!alive _x && !isNull _ltC) then {
                    deleteVehicle _ltC;
                    _x setVariable ["LL_LaserTargetC", objNull];
                };
            } forEach (missionNamespace getVariable ["LL_Task08_Targets", []]);

            private _vehicles = _enemies select { !(_x isKindOf "CAManBase") };
            {
                _grp reveal [_x, 4];

                west reportRemoteTarget [_x, 10];
                independent reportRemoteTarget [_x, 10];
                _x confirmSensorTarget [west, true];
                _x confirmSensorTarget [independent, true];

                (gunner _drone) doTarget _x;
                (gunner _drone) doFire _x;

                if (alive _x) then {

                    private _ltW = _x getVariable ["LL_LaserTargetW", objNull];
                    if (isNull _ltW) then {
                        _ltW = createVehicle ["LaserTargetW", getPosATL _x, [], 0, "CAN_COLLIDE"];
                        _ltW attachTo [_x, [0, 0, 0.5]];
                        _x setVariable ["LL_LaserTargetW", _ltW];
                    };

                    private _ltC = _x getVariable ["LL_LaserTargetC", objNull];
                    if (isNull _ltC) then {
                        _ltC = createVehicle ["LaserTargetC", getPosATL _x, [], 0, "CAN_COLLIDE"];
                        _ltC attachTo [_x, [0, 0, 0.5]];
                        _x setVariable ["LL_LaserTargetC", _ltC];
                    };

                    private _wpn = "";
                    {
                        private _lowerW = toLower _x;
                        if (["agm", _lowerW] call BIS_fnc_inString || ["hellfire", _lowerW] call BIS_fnc_inString || ["scalpel", _lowerW] call BIS_fnc_inString || ["lg", _lowerW] call BIS_fnc_inString || ["missile", _lowerW] call BIS_fnc_inString || ["bomb", _lowerW] call BIS_fnc_inString || ["gbu", _lowerW] call BIS_fnc_inString) exitWith {
                            _wpn = _x;
                        };
                    } forEach (_drone weaponsTurret [0]);

                    if (_wpn != "") then {
                        _drone selectWeaponTurret [_wpn, [0]];
                        (gunner _drone) fireAtTarget [_x, _wpn];
                    };
                };
            } forEach _vehicles;

            sleep 3;
        };

        ["STR_Drone_RTB"] call LL_fnc_radioMessage;

        {
            private _ltW = _x getVariable ["LL_LaserTargetW", objNull];
            if (!isNull _ltW) then {
                deleteVehicle _ltW;
                _x setVariable ["LL_LaserTargetW", objNull];
            };
            private _ltC = _x getVariable ["LL_LaserTargetC", objNull];
            if (!isNull _ltC) then {
                deleteVehicle _ltC;
                _x setVariable ["LL_LaserTargetC", objNull];
            };
        } forEach (missionNamespace getVariable ["LL_Task08_Targets", []]);

        { deleteMarker _y; } forEach _enemyMarkers;
        deleteMarker _markerArea;
        deleteMarker _markerIcon;
        deleteMarker _markerDrone;

        if (alive _drone) then {
            _grp setBehaviour "CARELESS";
            _grp setCombatMode "BLUE";

            private _rtbPos = [
                (_targetPos select 0),
                (_targetPos select 1) - 3000,
                _altitude
            ];
            while { count (waypoints _grp) > 0 } do { deleteWaypoint [_grp, 0]; };
            private _wpRtb = _grp addWaypoint [_rtbPos, 0];
            _wpRtb setWaypointType "MOVE";
            _wpRtb setWaypointBehaviour "CARELESS";
            _wpRtb setWaypointCombatMode "BLUE";
            _wpRtb setWaypointSpeed "FULL";
            _drone doMove _rtbPos;

            private _timer = 0;
            waitUntil {
                sleep 5; _timer = _timer + 5;
                (!alive _drone) || (_drone distance2D _rtbPos < 100) || _timer > 120
            };

            { deleteVehicle _x; } forEach (crew _drone);
            deleteVehicle _drone;
        };

        deleteGroup _grp;

        sleep 10;
        LL_Drone_Active = false;
        publicVariable "LL_Drone_Active";
        ["STR_Drone_Available"] call LL_fnc_radioMessage;
    };
};
