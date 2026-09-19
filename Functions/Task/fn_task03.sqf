params [["_mode", "init", [""]], ["_args", [], [[]]]];

if (!isServer) exitWith {};

if (_mode == "init") exitWith {
    private _allLogics = allMissionObjects "Logic";
    if (count _allLogics < 2) exitWith {
        missionNamespace setVariable ["LL_g_taskInProgress", false, true];
    };

    private _targetNumRadios = 2 + floor (random 3); 
    private _selectedRadios = [];
    private _logicsPool = _allLogics call BIS_fnc_arrayShuffle;
    private _alivePlayers = allPlayers select { alive _x };
    private _minDistPlayers = 400;
    private _maxDist = 450;

    while { count _selectedRadios < 2 && _maxDist <= 15000 } do {
        _selectedRadios = [];
        {
            private _candidate = _x;
            private _candidatePos = getPosASL _candidate;
            private _valid = true;

            { private _d = _x distance2D _candidatePos; if (_d < _minDistPlayers || _d > _maxDist) exitWith { _valid = false; }; } forEach _alivePlayers;

            if (_valid) then {
                { if ((getPosASL _x) distance2D _candidatePos < 250) exitWith { _valid = false; }; } forEach _selectedRadios;
            };

            if (_valid) then { _selectedRadios pushBack _candidate; };
            if (count _selectedRadios >= _targetNumRadios) exitWith {};
        } forEach _logicsPool;

        if (count _selectedRadios < 2) then { _maxDist = _maxDist + 50; };
    };

    private _numRadios = count _selectedRadios;
    if (_numRadios < 2) exitWith {
        [[], "LL_fnc_task03"] spawn { sleep 15; ["init"] spawn LL_fnc_task03; };
    };

    missionNamespace setVariable ["LL_Task03_AllUnits", [], true];
    missionNamespace setVariable ["LL_Task03_Destroyed", 0, true];
    missionNamespace setVariable ["LL_Task03_Total", _numRadios, true];

    private _allUnits = [];
    private _radios = [];

    for "_i" from 0 to (_numRadios - 1) do {
        private _logic = _selectedRadios select _i;
        private _spawnPos = getPosASL _logic;

        private _numPatrols = 4 + floor (random 3);
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

        private _mkrName = format ["mkr_task03_zone_%1", _i];
        createMarker [_mkrName, _spawnPos];
        _mkrName setMarkerType "mil_objective";
        _mkrName setMarkerColor "ColorOrange";
        _mkrName setMarkerText format ["%1 %2", localize "STR_LL_Task_03_Marker", _i + 1];

        sleep 1.5;

        private _radioClass = "RuggedTerminal_01_communications_F";
        private _radio = createVehicle [_radioClass, [0,0,0], [], 0, "CAN_COLLIDE"];
        _radio setDir (getDir _logic);
        _radio setVectorUp [0, 0, 1];
        _radio setPosASL _spawnPos;
        _radio setVariable ["LL_Task_Status", "WAIT", true];
        _radio setVariable ["LL_Radio_Marker", _mkrName, true];

        _radio allowDamage false;
        [_radio] spawn { sleep 3; (_this select 0) allowDamage true; };

        _radios pushBack _radio;

        private _varName = format ["LL_Task03_Radio_%1_%2", _i, round(random 100000)];
        _radio setVehicleVarName _varName;
        missionNamespace setVariable [_varName, _radio, true];

        [_radio, netId _radio, _varName] remoteExec ["LL_fnc_task03_addAction", 0, true];
    };

    missionNamespace setVariable ["LL_Task03_AllUnits", _allUnits, true];
    missionNamespace setVariable ["LL_Task03_Radios", _radios, true];

    [
        independent,
        ["task_03_radio"],
        [
            localize "STR_LL_Task_03_Desc",
            localize "STR_LL_Task_03_Title",
            localize "STR_LL_Task_03_MarkerMain"
        ],
        objNull,
        "AUTOASSIGNED",
        5,
        true,
        "destroy",
        false
    ] call BIS_fnc_taskCreate;

    [[], { player createDiaryRecord ["diary", [localize "STR_LL_Diary_Task03_Title", localize "STR_LL_Diary_Task03_Text"]]; }] remoteExec ["spawn", 0, true];
};

if (_mode == "plant") exitWith {
    _args params ["_radio", "_caller"];

    if ((_radio getVariable ["LL_Task_Status", "WAIT"]) != "WAIT") exitWith {};
    _radio setVariable ["LL_Task_Status", "ACTION", true];

    _caller playMove "AinvPknlMstpSnonWnonDnon_medic_1";

    private _pos = getPosATL _radio;
    private _charge = createVehicle ["DemoCharge_F", _pos, [], 0, "CAN_COLLIDE"];
    _charge attachTo [_radio, [0, 0, 0.2]];
    _charge setVectorUp [0, 0, 1];

    [_radio, _charge] spawn {
        params ["_radio", "_charge"];

        sleep 40; 

        if (!isNull _charge) then { deleteVehicle _charge; };

        private _pos = getPos _radio;
        private _mkrName = _radio getVariable ["LL_Radio_Marker", ""];

        "Bo_GBU12_LGB" createVehicle _pos;

        if (!isNull _radio) then { deleteVehicle _radio; };

        if (_mkrName != "") then {
            _mkrName setMarkerColor "ColorBlack";
            _mkrName setMarkerText (localize "STR_LL_Task_03_Marker_Destroyed");
        };

        private _destroyed = (missionNamespace getVariable ["LL_Task03_Destroyed", 0]) + 1;
        missionNamespace setVariable ["LL_Task03_Destroyed", _destroyed, true];
        private _total = missionNamespace getVariable ["LL_Task03_Total", 1];

        if (_destroyed >= _total) then {
            ["task_03_radio", "SUCCEEDED", true] call BIS_fnc_taskSetState;
            missionNamespace setVariable ["LL_g_taskInProgress", false, true];

            [] spawn {
                sleep 10;
                private _radios = missionNamespace getVariable ["LL_Task03_Radios", []];
                for "_i" from 0 to ((count _radios) - 1) do { deleteMarker format ["mkr_task03_zone_%1", _i]; };
            };

            private _allUnits = missionNamespace getVariable ["LL_Task03_AllUnits", []];
            private _guards = _allUnits select { alive _x };
            [_guards] spawn LL_fnc_taskCleanup;
        };
    };
};
