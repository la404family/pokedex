params [["_mode", "init", [""]], ["_args", [], [[]]]];

if (!isServer) exitWith {};

if (_mode == "init") exitWith {
    private _heliports = allMissionObjects "HeliH";
    { _heliports pushBackUnique _x; } forEach (allMissionObjects "Land_HelipadEmpty_F");
    { _heliports pushBackUnique _x; } forEach (allMissionObjects "HeliHSquare_F");
    private _allLogics = _heliports;

    if (count _allLogics < 1) exitWith {
        missionNamespace setVariable ["LL_g_taskInProgress", false, true];
    };

    private _selectedLogics = [];
    private _alivePlayers = allPlayers select { alive _x };
    private _logicsPool = _allLogics call BIS_fnc_arrayShuffle;
    private _minDistPlayers = 400;
    private _maxDist = 450;

    while { count _selectedLogics < 1 && _maxDist <= 15000 } do {
        {
            private _candidate = _x;
            private _candidatePos = getPosASL _candidate;
            private _valid = true;
            { 
                private _d = _x distance2D _candidatePos; 
                if (_d < _minDistPlayers || _d > _maxDist) exitWith { _valid = false; }; 
            } forEach _alivePlayers;
            
            if (_valid) then { _selectedLogics pushBack _candidate; };
            if (count _selectedLogics == 1) exitWith {};
        } forEach _logicsPool;

        if (count _selectedLogics < 1) then { _maxDist = _maxDist + 50; };
    };

    if (count _selectedLogics < 1) exitWith {
        [[], "LL_fnc_task07"] spawn { sleep 15; ["init"] spawn LL_fnc_task07; };
    };

    private _selectedLogic = _selectedLogics select 0;
    private _spawnPos = getPosASL _selectedLogic;
    _spawnPos set [2, (_spawnPos select 2) + 0.2];

    private _allUnits = [];

    private _numPatrols = 3 + floor (random 2);
    private _patrolRadii = [15, 30, 60, 100];
    
    for "_p" from 0 to (_numPatrols - 1) do {
        private _radius = _patrolRadii select (_p % (count _patrolRadii));
        
        private _grp = createGroup [east, true];
        _grp setBehaviour "AWARE";
        _grp setCombatMode "RED";

        private _numGuards = 2 + floor (random 2);
        for "_g" from 1 to _numGuards do {
            sleep 1.5;
            private _guard = _grp createUnit ["O_Soldier_F", _spawnPos, [], 0, "NONE"];
            _guard setPosASL _spawnPos;
            _guard allowDamage false;
            [_guard] spawn { sleep 3; (_this select 0) allowDamage true; };
            [_guard] call TUE_fnc_applyEnemyEquipment;
            _allUnits pushBack _guard;
        };

        if (_radius == 15 && random 1 > 0.5) then {
            private _wp = _grp addWaypoint [_spawnPos, 0];
            _wp setWaypointType "GUARD";
        } else {
            [_grp, _spawnPos, _radius] call BIS_fnc_taskPatrol;
        };
    };

    sleep 1.5;

    private _tank = createVehicle ["O_MBT_04_command_F", _spawnPos, [], 0, "CAN_COLLIDE"];
    _tank setPosASL _spawnPos;
    _tank setDir (random 360);
    _tank allowDamage false;
    [_tank] spawn { sleep 3; (_this select 0) allowDamage true; };
    _allUnits pushBack _tank;

    createVehicleCrew _tank;
    {
        _allUnits pushBack _x;
    } forEach (crew _tank);

    [_tank, _spawnPos] spawn {
        params ["_tank", "_spawnPos"];
        sleep 5;
        private _targetPos = [_spawnPos, 20, 30, 5, 0, 0.5, 0] call BIS_fnc_findSafePos;
        if (count _targetPos > 0) then {
            _tank doMove _targetPos;
        };
    };

    sleep 1.5;

    private _grpOfficers = createGroup [east, true];
    _grpOfficers setBehaviour "AWARE";
    private _officers = [];
    for "_i" from 1 to 2 do {
        sleep 1.5;
        private _officer = _grpOfficers createUnit ["O_officer_F", _spawnPos, [], 0, "NONE"];
        _officer setPosASL _spawnPos;
        _officer allowDamage false;
        [_officer] spawn { sleep 3; (_this select 0) allowDamage true; };
        [_officer] call TUE_fnc_applyEnemyEquipment;
        _officers pushBack _officer;
        _allUnits pushBack _officer;
    };
    [_grpOfficers, _spawnPos, 15] call BIS_fnc_taskPatrol;

    private _markerArea = createMarker ["LL_Task07_Area", _spawnPos];
    _markerArea setMarkerShape "ELLIPSE";
    _markerArea setMarkerSize [150, 150];
    _markerArea setMarkerColor "ColorOrange";
    _markerArea setMarkerAlpha 0.4;

    {
        private _markerName = format ["LL_Task07_Officer_%1", _forEachIndex];
        private _marker = createMarker [_markerName, getPosASL _x];
        _marker setMarkerType "o_inf";
        _marker setMarkerColor "ColorRed";
        _marker setMarkerText (localize "STR_LL_Task_07_Officer_Marker");
        
        [_x, _markerName] spawn {
            params ["_unit", "_mName"];
            while {alive _unit && missionNamespace getVariable ["LL_g_taskInProgress", false]} do {
                _mName setMarkerPos (getPosASL _unit);
                sleep 2;
            };
            deleteMarker _mName;
        };
    } forEach _officers;

    missionNamespace setVariable ["LL_Task07_PlaneTriggered", false, true];
    missionNamespace setVariable ["LL_Task07_TargetTank", _tank, true];

    [
        independent,
        ["task_07_cas"],
        [
            localize "STR_LL_Task_07_Desc",
            localize "STR_LL_Task_07_Title",
            localize "STR_LL_Task_07_Marker"
        ],
        _spawnPos,
        "AUTOASSIGNED",
        5,
        true,
        "destroy",
        false
    ] call BIS_fnc_taskCreate;

    [[], { player createDiaryRecord ["diary", [localize "STR_LL_Diary_Task07_Title", localize "STR_LL_Diary_Task07_Text"]]; }] remoteExec ["spawn", 0, true];

    [_tank] remoteExec ["LL_fnc_task07_addAction", 0, true];

    [_officers, _tank, _allUnits] spawn {
        params ["_officers", "_tank", "_allUnits"];
        
        while {true} do {
            sleep 5;
            
            private _officersDead = true;
            {
                if (alive _x) exitWith { _officersDead = false; };
            } forEach _officers;
            
            private _tankDead = !alive _tank;
            
            if (_officersDead && _tankDead) exitWith {
                ["task_07_cas", "SUCCEEDED", true] call BIS_fnc_taskSetState;
                missionNamespace setVariable ["LL_g_taskInProgress", false, true];
                deleteMarker "LL_Task07_Area";
                [_allUnits] spawn LL_fnc_taskCleanup;
            };
        };
    };
};
