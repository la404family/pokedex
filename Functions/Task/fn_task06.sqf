params [["_mode", "init", [""]], ["_args", [], [[]]]];

if (!isServer) exitWith {};

if (_mode == "init") exitWith {
    private _allLogics = allMissionObjects "Logic";
    if (count _allLogics == 0) exitWith {
        missionNamespace setVariable ["LL_g_taskInProgress", false, true];
    };

    private _logicsPool = _allLogics call BIS_fnc_arrayShuffle;
    private _alivePlayers = allPlayers select { alive _x };
    private _selectedLogic = objNull;
    private _minDistPlayers = 400;
    private _maxDist = 450;

    while { isNull _selectedLogic && _maxDist <= 15000 } do {
        {
            private _candidate = _x;
            private _candidatePos = getPosASL _candidate;
            private _valid = true;
            { private _d = _x distance2D _candidatePos; if (_d < _minDistPlayers || _d > _maxDist) exitWith { _valid = false; }; } forEach _alivePlayers;
            if (_valid) exitWith { _selectedLogic = _candidate; };
        } forEach _logicsPool;

        if (isNull _selectedLogic) then { _maxDist = _maxDist + 50; };
    };

    if (isNull _selectedLogic) exitWith {
        [[], "LL_fnc_task06"] spawn { sleep 15; ["init"] spawn LL_fnc_task06; };
    };

    missionNamespace setVariable ["LL_Task06_AllUnits", [], true];
    missionNamespace setVariable ["LL_Task06_Failed", false, true];
    private _allUnits = [];

    private _spawnPos = getPosASL _selectedLogic;
    _spawnPos set [2, (_spawnPos select 2) + 0.2];

    private _numPatrols = 5 + floor (random 3);
    private _step = (475 - 15) / (_numPatrols - 1 max 1);

    for "_p" from 0 to (_numPatrols - 1) do {
        private _radius = round (15 + (_p * _step) + (random 20 - 10)) max 15 min 475;
        private _grp = createGroup [east, true];
        _grp setBehaviour "SAFE";
        _grp setCombatMode "RED";

        private _numGuards = 2 + floor (random 3);
        for "_g" from 1 to _numGuards do {
            sleep 1.5;
            private _guardClass = "O_Soldier_F";
            private _guard = _grp createUnit [_guardClass, _spawnPos, [], 0, "NONE"];
            _guard setPosASL _spawnPos;
            _guard allowDamage false;
            [_guard] spawn { sleep 3; (_this select 0) allowDamage true; };
            [_guard] call TUE_fnc_applyEnemyEquipment;
            _allUnits pushBack _guard;
        };

        [_grp, _spawnPos, _radius] call BIS_fnc_taskPatrol;
    };

    sleep 1.5;
    private _grpHvt = createGroup [east, true];
    private _hvtClass = "O_Officer_F";
    private _hvt = _grpHvt createUnit [_hvtClass, _spawnPos, [], 0, "NONE"];
    _hvt setPosASL _spawnPos;
    _hvt allowDamage false;
    [_hvt] spawn { sleep 3; (_this select 0) allowDamage true; };
    [_hvt] call TUE_fnc_applyEnemyEquipment;
    _hvt setRank "COLONEL";
    _allUnits pushBack _hvt;

    _hvt setCaptive true;
    _hvt disableAI "MOVE";

    _hvt setVariable ["LL_Task_Status", "WAIT", true];
    missionNamespace setVariable ["LL_Task06_HVT", _hvt, true];
    missionNamespace setVariable ["LL_Task06_Triggered", false, true];

    [_hvt] spawn {
        params ["_hvt"];
        waitUntil {
            sleep 0.5;
            private _players = allPlayers select { alive _x };
            ({ _x distance2D _hvt < 5 } count _players) > 0 || !alive _hvt
        };

        if (alive _hvt) then {
            removeAllWeapons _hvt;

            _hvt enableAI "MOVE";
            _hvt enableAI "ANIM";
            _hvt disableAI "PATH";
            _hvt disableAI "FSM";
            _hvt disableAI "TARGET";
            _hvt disableAI "AUTOTARGET";
            _hvt setUnitPos "UP";

            [_hvt, "AmovPercMstpSnonWnonDnon_AmovPercMstpSsurWnonDnon"] remoteExec ["playMove", 0];

            [_hvt] spawn { params ["_u"]; sleep 1.3; [_u, "AmovPercMstpSsurWnonDnon"] remoteExec ["switchMove", 0]; };

            _hvt setVariable ["LL_Task_Status", "READY_TO_CAPTURE", true];

            private _civGrp = createGroup [civilian, true];
            [_hvt] joinSilent _civGrp;

            private _varName = format ["LL_Task06_HVT_%1", round(random 100000)];
            _hvt setVehicleVarName _varName;
            missionNamespace setVariable [_varName, _hvt, true];

            [_hvt, netId _hvt] remoteExec ["LL_fnc_task06_addAction", 0, _hvt];
        };
    };

    _hvt addEventHandler ["Killed", {
        params ["_unit"];
        private _parent = _unit getVariable ["LL_Task06_EscortParent", objNull];
        if (!isNull _parent && alive _parent) then {
            [_unit, _parent] remoteExec ["enableCollisionWith", 0, _unit];
            [_parent, _unit] remoteExec ["enableCollisionWith", 0, _unit];
        };
        detach _unit;

        missionNamespace setVariable ["LL_Task06_Failed", true, true];
        ["task_06_hvt", "FAILED", true] call BIS_fnc_taskSetState;
        missionNamespace setVariable ["LL_g_taskInProgress", false, true];

        deleteMarker "mkr_task06_zone";
    }];

    private _mkrName = "mkr_task06_zone";
    createMarker [_mkrName, _spawnPos];
    _mkrName setMarkerType "mil_objective";
    _mkrName setMarkerColor "ColorOrange";
    _mkrName setMarkerText (localize "STR_LL_Task_06_Marker");

    missionNamespace setVariable ["LL_Task06_AllUnits", _allUnits, true];

    [
        independent,
        ["task_06_hvt"],
        [
            localize "STR_LL_Task_06_Desc",
            localize "STR_LL_Task_06_Title",
            localize "STR_LL_Task_06_Marker"
        ],
        objNull,
        "AUTOASSIGNED",
        5,
        true,
        "search",
        false
    ] call BIS_fnc_taskCreate;

    [[], { player createDiaryRecord ["diary", [localize "STR_LL_Diary_Task06_Title", localize "STR_LL_Diary_Task06_Text"]]; }] remoteExec ["spawn", 0, true];
};

if (_mode == "escort") exitWith {
    _args params ["_hvt", "_caller"];

    if ((_hvt getVariable ["LL_Task_Status", ""]) != "READY_TO_CAPTURE") exitWith {};
    _hvt setVariable ["LL_Task_Status", "ESCORTED", true];
    _hvt setVariable ["LL_Task06_EscortParent", _caller, true];

    { _hvt enableAI _x; } forEach ["MOVE", "ANIM", "PATH", "TEAMSWITCH"];
    { _hvt disableAI _x; } forEach ["FSM", "TARGET", "AUTOTARGET", "AUTOCOMBAT", "SUPPRESSION", "COVER", "CHECKVISIBLE"];
    _hvt setBehaviour "CARELESS";
    _hvt setCombatMode "BLUE";
    _hvt setSpeedMode "FULL";
    _hvt setUnitPos "UP";
    _hvt allowFleeing 0;
    _hvt forceSpeed -1;
    _hvt setSkill ["courage", 1];
    _hvt setSkill ["commanding", 1];

    [_hvt, _caller] remoteExec ["disableCollisionWith", 0];
    [_caller, _hvt] remoteExec ["disableCollisionWith", 0];

    [_hvt] joinSilent (group _caller);

    [_hvt, ""] remoteExec ["switchMove", 0];

    [_hvt, _caller] spawn {
        params ["_hvt", "_caller"];
        if (isNull _hvt || isNull _caller) exitWith {};

        private _lastPos = getPosATL _hvt;
        private _lastCallerPos = [0,0,0];
        private _stuckTime = 0;
        private _stuckCheckInterval = 2;

        while { alive _hvt && (_hvt getVariable ["LL_Task_Status", ""]) == "ESCORTED" } do {
            private _targetPlayer = _caller;
            if (isNull _targetPlayer || !alive _targetPlayer) then {
                private _players = allPlayers select { alive _x };
                if (count _players > 0) then {
                    _targetPlayer = _players select 0;
                    private _minD = _hvt distance2D _targetPlayer;
                    {
                        private _d = _hvt distance2D _x;
                        if (_d < _minD) then { _minD = _d; _targetPlayer = _x; };
                    } forEach _players;
                    _hvt setVariable ["LL_Task06_EscortParent", _targetPlayer, true];
                };
            };

            if (isNull _targetPlayer || !alive _targetPlayer) exitWith {
                _hvt setVariable ["LL_Task_Status", "READY_TO_CAPTURE", true];
                _hvt setVariable ["LL_Task06_EscortParent", objNull, true];
                _hvt disableAI "PATH";
                doStop _hvt;
                [_hvt, "AmovPercMstpSnonWnonDnon_AmovPercMstpSsurWnonDnon"] remoteExec ["playMove", 0];
                [_hvt] spawn { params ["_u"]; sleep 1.3; [_u, "AmovPercMstpSsurWnonDnon"] remoteExec ["switchMove", 0]; };
            };

            if (vehicle _targetPlayer != _targetPlayer) then {
                if (vehicle _hvt == _hvt) then {
                    private _veh = vehicle _targetPlayer;
                    if ((_veh emptyPositions "Cargo") > 0) then {
                        _hvt assignAsCargo _veh;
                        [_hvt] orderGetIn true;
                    } else {
                        if (_hvt distance2D _veh > 5) then {
                            _hvt doMove (getPosATL _veh);
                        };
                    };
                };
            } else {
                if (vehicle _hvt != _hvt) then {
                    unassignVehicle _hvt;
                    [_hvt] orderGetIn false;
                    _hvt action ["Eject", vehicle _hvt];
                };

                private _dist = _hvt distance2D _targetPlayer;

                if (_dist > 3.5) then {
                    private _callerCurrentPos = getPosATL _targetPlayer;

                    if ((_callerCurrentPos distance2D _lastCallerPos > 3) || unitReady _hvt) then {
                        _hvt doMove _callerCurrentPos;
                        _lastCallerPos = _callerCurrentPos;
                    };

                    private _currentHvtPos = getPosATL _hvt;
                    private _movedDist = _currentHvtPos distance2D _lastPos;

                    if (_movedDist < 0.4) then {
                        _stuckTime = _stuckTime + _stuckCheckInterval;

                        if (_stuckTime >= 3 && _stuckTime < 6) then {
                            [_hvt, ""] remoteExec ["switchMove", 0];
                            _hvt setUnitPos "UP";
                            _hvt forceWalk false;
                            _hvt setSpeedMode "FULL";
                        };

                        if (_stuckTime >= 6 && _stuckTime < 9) then {
                            private _nearObs = nearestObjects [_hvt, ["Building", "House", "Fence", "Wall", "Static", "Thing"], 6];
                            { _hvt disableCollisionWith _x; } forEach _nearObs;

                            private _dir = _hvt getDir _targetPlayer;
                            private _escapeDir = _dir + (selectRandom [60, -60, 90, -90]);
                            private _escapePos = _currentHvtPos getPos [5, _escapeDir];
                            _hvt doMove _escapePos;
                        };

                        if (_stuckTime >= 9) then {
                            private _dirVec = (getPosASL _hvt) vectorFromTo (getPosASL _targetPlayer);
                            _dirVec set [2, 0.08];
                            _hvt setVelocity (_dirVec vectorMultiply 1.5);
                            _hvt doMove _callerCurrentPos;
                            _stuckTime = 0;
                            _lastPos = getPosATL _hvt;
                        };
                    } else {
                        _stuckTime = 0;
                        _lastPos = _currentHvtPos;
                    };
                } else {
                    _stuckTime = 0;
                    _lastPos = getPosATL _hvt;
                };
            };

            sleep _stuckCheckInterval;
        };

        if (!isNull _caller && alive _caller) then {
            [_hvt, _caller] remoteExec ["enableCollisionWith", 0];
            [_caller, _hvt] remoteExec ["enableCollisionWith", 0];
        };
    };

    if !(missionNamespace getVariable ["LL_Task06_Triggered", false]) then {
        missionNamespace setVariable ["LL_Task06_Triggered", true, true];

        private _hvtGrp = group _hvt;
        private _dummy = _hvtGrp createUnit ["O_Soldier_F", getPosASL _hvt, [], 0, "NONE"];
        _dummy hideObjectGlobal true;
        _dummy allowDamage false;
        _dummy disableAI "ALL";
        _hvtGrp selectLeader _hvt;
        _dummy commandMove (getPos _hvt getPos [500, random 360]);
        [_dummy] spawn { sleep 3; deleteVehicle (_this select 0); };

        deleteMarker "mkr_task06_zone";

        missionNamespace setVariable ["LL_g_taskInProgress", false, true];

        private _allUnits = missionNamespace getVariable ["LL_Task06_AllUnits", []];
        private _guards = _allUnits select { _x != _hvt && alive _x };
        [_guards] spawn LL_fnc_taskCleanup;
    };
};

if (_mode == "release") exitWith {
    _args params ["_hvt", "_caller"];

    if ((_hvt getVariable ["LL_Task_Status", ""]) != "ESCORTED") exitWith {};
    _hvt setVariable ["LL_Task_Status", "READY_TO_CAPTURE", true];
    _hvt setVariable ["LL_Task06_EscortParent", objNull, true];

    _hvt disableAI "PATH";
    doStop _hvt;

    [_hvt, _caller] remoteExec ["enableCollisionWith", 0];
    [_caller, _hvt] remoteExec ["enableCollisionWith", 0];

    [_hvt, "AmovPercMstpSnonWnonDnon_AmovPercMstpSsurWnonDnon"] remoteExec ["playMove", 0];
    [_hvt] spawn { params ["_u"]; sleep 1.3; [_u, "AmovPercMstpSsurWnonDnon"] remoteExec ["switchMove", 0]; };
};
