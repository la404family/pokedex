params [["_mode", "init", [""]], ["_args", [], [[]]]];

if (!isServer) exitWith {};

if (_mode == "init") exitWith {
    private _allLogics = allMissionObjects "Logic";
    if (count _allLogics < 1) exitWith {
        missionNamespace setVariable ["LL_g_taskInProgress", false, true];
    };

    private _selectedLogic = objNull;
    private _logicsPool = _allLogics call BIS_fnc_arrayShuffle;
    private _alivePlayers = allPlayers select { alive _x };
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
        [[], "LL_fnc_task00"] spawn { sleep 15; ["init"] spawn LL_fnc_task00; };
    };

    missionNamespace setVariable ["LL_Task00_NumZones", 1, true];
    missionNamespace setVariable ["LL_Task00_AllUnits", [], true];
    private _allUnits = [];

    private _spawnPos = getPosASL _selectedLogic;
    _spawnPos set [2, (_spawnPos select 2) + 0.2];

    private _grpCiv = createGroup [civilian, true];
    private _hostage = _grpCiv createUnit ["C_man_polo_1_F", _spawnPos, [], 0, "NONE"];
    _hostage setPosASL _spawnPos;
    _hostage allowDamage false;
    [_hostage] spawn { sleep 3; (_this select 0) allowDamage true; };
    _allUnits pushBack _hostage;

    _hostage setCaptive true;
    removeAllWeapons _hostage;
    removeBackpack _hostage;

    _hostage setVariable ["LL_Task_Status", "WAIT", true];
    missionNamespace setVariable ["LL_Task00_Hostage", _hostage, true];

    _hostage disableAI "MOVE";
    _hostage disableAI "ANIM";
    _hostage setUnitPos "UP";
    _hostage switchMove "Acts_ExecutionVictim_Loop";

    _hostage addEventHandler ["AnimDone", {
        params ["_unit"];
        if (alive _unit && (_unit getVariable ["LL_Task_Status", "WAIT"]) == "WAIT") then {
            _unit switchMove "Acts_ExecutionVictim_Loop";
        };
    }];

    _hostage addEventHandler ["Killed", {
        private _nz = missionNamespace getVariable ["LL_Task00_NumZones", 1];
        ["task_00_exfiltration", "FAILED", true] call BIS_fnc_taskSetState;
        missionNamespace setVariable ["LL_g_taskInProgress", false, true];
        for "_i" from 0 to (_nz - 1) do { deleteMarker format ["mkr_task00_zone_%1", _i]; };
        ["End2", false, 5] remoteExec ["BIS_fnc_endMission", 0];
    }];

    private _varName = format ["LL_Task00_Hostage_%1", round(random 100000)];
    _hostage setVehicleVarName _varName;
    missionNamespace setVariable [_varName, _hostage, true];

    [_hostage, netId _hostage, _varName] remoteExec ["LL_fnc_task00_addAction", 0, _hostage];

    private _mkrName = "mkr_task00_zone_0";
    createMarker [_mkrName, _spawnPos];
    _mkrName setMarkerType "mil_objective";
    _mkrName setMarkerColor "ColorOrange";
    _mkrName setMarkerText (localize "STR_LL_Task_00_MarkerMain");

    private _numGroups = 5 + floor (random 4);
    private _step = (400 - 10) / (_numGroups - 1 max 1);

    for "_i" from 0 to (_numGroups - 1) do {
        private _grpEnemy = createGroup [east, true];
        _grpEnemy setBehaviour "SAFE";
        _grpEnemy setCombatMode "RED";

        private _numGuards = 2 + floor (random 3);
        for "_g" from 1 to _numGuards do {
            sleep 1;
            private _guardClass = "O_Soldier_F";
            private _guard = _grpEnemy createUnit [_guardClass, _spawnPos, [], 0, "NONE"];
            _guard setPosASL _spawnPos;
            _guard allowDamage false;
            [_guard] spawn { sleep 3; (_this select 0) allowDamage true; };
            [_guard] call TUE_fnc_applyEnemyEquipment;
            _allUnits pushBack _guard;
        };

        private _currentRadius = round (10 + (_i * _step) + (random 20 - 10)) max 10 min 400;
        [_grpEnemy, _spawnPos, _currentRadius] call BIS_fnc_taskPatrol;
    };

    missionNamespace setVariable ["LL_Task00_AllUnits", _allUnits, true];

    [
        independent,
        ["task_00_exfiltration"],
        [
            localize "STR_LL_Task_00_Desc",
            localize "STR_LL_Task_00_Title",
            localize "STR_LL_Task_00_MarkerMain"
        ],
        objNull,
        "AUTOASSIGNED",
        5,
        true,
        "search",
        false
    ] call BIS_fnc_taskCreate;

    [[], { player createDiaryRecord ["diary", [localize "STR_LL_Diary_Task00_Title", localize "STR_LL_Diary_Task00_Text"]]; }] remoteExec ["spawn", 0, true];

    ["STR_LL_Task_Assigned"] remoteExec ["LL_fnc_radioMessage", 0];
};

if (_mode == "free") exitWith {
    _args params ["_hostage", "_caller"];

    if ((_hostage getVariable ["LL_Task_Status", "WAIT"]) != "WAIT") exitWith {};
    _hostage setVariable ["LL_Task_Status", "ACTION", true];

    private _hostageFixedPos = getPosASL _hostage;
    private _hostageFixedDir = getDir _hostage;

    _hostage setCaptive false;

    _hostage enableAI "ANIM";
    [_hostage, "Acts_ExecutionVictim_Unbow"] remoteExec ["switchMove", 0];

    [_hostage, _hostageFixedPos, _hostageFixedDir] spawn {
        params ["_h", "_pos", "_dir"];
        private _tStart = time;
        while { alive _h && (_h getVariable ["LL_Task_Status", "WAIT"]) == "ACTION" && (time - _tStart) < 10 } do {
            _h setPosASL _pos;
            _h setDir _dir;
            sleep 0.05;
        };
    };

    sleep 8.5;

    _hostage setPosASL _hostageFixedPos;
    _hostage setDir _hostageFixedDir;
    [_hostage, ""] remoteExec ["switchMove", 0];
    _hostage setVariable ["LL_Task_Status", "FREE", true];

    private _hostageGrp = group _hostage;
    private _dummy = _hostageGrp createUnit ["O_Soldier_F", getPosASL _hostage, [], 0, "NONE"];
    _dummy hideObjectGlobal true;
    _dummy allowDamage false;
    _dummy disableAI "ALL";
    _hostageGrp selectLeader _hostage;
    _dummy commandMove (getPos _hostage getPos [500, random 360]);
    sleep 3;
    deleteVehicle _dummy;

    [_hostage] joinSilent (group _caller);

    { _hostage enableAI _x; } forEach ["MOVE", "AUTOTARGET", "TARGET"];
    _hostage setUnitPos "UP";
    _hostage setSkill ["courage", 1];
    _hostage allowFleeing 0;

    _hostage disableAI "FSM";
    _hostage disableAI "AUTOCOMBAT";
    _hostage disableAI "SUPPRESSION";
    _hostage setBehaviour "CARELESS";
    _hostage setSpeedMode "FULL";

    [_hostage] spawn {
        params ["_hostage"];
        private _lastPos = getPosATL _hostage;
        private _stuckCheckTime = time;
        private _unstuckUntil = 0;

        while { alive _hostage && (_hostage getVariable ["LL_Task_Status", ""]) == "FREE" && (vehicle _hostage == _hostage) } do {
            private _alivePlayers = allPlayers select { alive _x };
            if (count _alivePlayers > 0) then {
                private _closestPlayer = objNull;
                private _minDist = 999999;
                {
                    private _dist = _x distance2D _hostage;
                    if (_dist < _minDist) then {
                        _minDist = _dist;
                        _closestPlayer = _x;
                    };
                } forEach _alivePlayers;

                if (!isNull _closestPlayer) then {
                    if (time >= _unstuckUntil) then {
                        if (_minDist > 5) then {
                            _hostage doMove (getPosATL _closestPlayer);

                            if ((getPosATL _hostage) distance2D _lastPos < 1.0) then {
                                if (time - _stuckCheckTime >= 6) then {
                                    _unstuckUntil = time + 10;
                                    private _escapePos = (getPosATL _hostage) getPos [15 + random 10, random 360];
                                    _hostage doMove _escapePos;
                                    _lastPos = getPosATL _hostage;
                                    _stuckCheckTime = time + 10;
                                };
                            } else {
                                _lastPos = getPosATL _hostage;
                                _stuckCheckTime = time;
                            };
                        } else {
                            _lastPos = getPosATL _hostage;
                            _stuckCheckTime = time;
                        };
                    };
                };
            };
            sleep 2;
        };
    };

    private _allBlufor = allUnits select { side _x == west && alive _x };
    private _allOpfor  = allUnits select { side _x == east && alive _x && _x != _hostage };
    if (count _allOpfor > 0 && count _allBlufor > 0) then {
        private _grpsProcessed = [];
        {
            private _enemy = _x;
            _enemy setBehaviour "COMBAT";
            _enemy setCombatMode "RED";
            _enemy setSpeedMode "FULL";
            { _enemy reveal [_x, 4]; } forEach _allBlufor;

            private _grp = group _enemy;
            if !(_grp in _grpsProcessed) then {
                _grpsProcessed pushBack _grp;
                private _grpPos = getPosATL (leader _grp);
                private _nearest = _allBlufor select 0;
                private _nearestDist = _nearest distance2D _grpPos;
                { private _d = _x distance2D _grpPos; if (_d < _nearestDist) then { _nearestDist = _d; _nearest = _x; }; } forEach _allBlufor;

                while { count waypoints _grp > 0 } do { deleteWaypoint [_grp, 0]; };
                private _wp = _grp addWaypoint [getPosATL _nearest, 10];
                _wp setWaypointType "SAD";
                _wp setWaypointSpeed "FULL";
                _wp setWaypointBehaviour "COMBAT";
            };
        } forEach _allOpfor;
    };

    private _nz = missionNamespace getVariable ["LL_Task00_NumZones", 4];
    for "_i" from 0 to (_nz - 1) do { deleteMarker format ["mkr_task00_zone_%1", _i]; };

    if (alive _hostage) then {
        ["task_00_exfiltration", "SUCCEEDED", true] call BIS_fnc_taskSetState;
        missionNamespace setVariable ["LL_g_taskInProgress", false, true];
    };

    private _allUnits = missionNamespace getVariable ["LL_Task00_AllUnits", []];
    private _guards = _allUnits select { _x != _hostage && alive _x };
    [_guards] spawn LL_fnc_taskCleanup;
};
