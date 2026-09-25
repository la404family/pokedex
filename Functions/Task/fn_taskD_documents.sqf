/*
    LL_fnc_taskD_documents
    Éliminer le commandant et récupérer les documents top-secrets.
*/

if (!isServer) exitWith {};

params [
    ["_locMarker", "", [""]]
];

if (_locMarker == "") then { _locMarker = "marker_0"; };

private _centerPos = getMarkerPos _locMarker;
private _radius = (markerSize _locMarker) select 0;
if (_radius == 0) then { _radius = 250; };
private _nearHelipads = nearestObjects [_centerPos, ["Land_HelipadEmpty_F"], _radius];
private _allLogics = allMissionObjects "Logic";
private _nearLogics = _allLogics select { _x distance2D _centerPos <= _radius };

private _usedPositions = missionNamespace getVariable ["LL_g_usedTaskPos", []];
private _validSpawnPoints = (_nearLogics + _nearHelipads) select {
    private _candidate = _x;
    (_usedPositions findIf { _x distance2D _candidate < 15 }) == -1
};

if (count _validSpawnPoints == 0) then {
    _validSpawnPoints = _nearLogics + _nearHelipads;
};

if (count _validSpawnPoints < 2) then {
    while { count _validSpawnPoints < 2 } do {
        private _dummyLogic = "Logic" createVehicleLocal (_centerPos getPos [300 + random 400, random 360]);
        _validSpawnPoints pushBack _dummyLogic;
    };
};

private _numSpawns = (1 + floor (random 2)) min (count _validSpawnPoints);
private _shuffled = _validSpawnPoints call BIS_fnc_arrayShuffle;
private _selectedLogics = _shuffled select [0, _numSpawns];

missionNamespace setVariable ["LL_TaskD_Doc_NumZones", _numSpawns, true];
private _targetIndex = floor random _numSpawns;
missionNamespace setVariable ["LL_TaskD_Doc_AllUnits", [], true];
private _officersData = [];
private _targetOfficer = objNull;

for "_i" from 0 to (_numSpawns - 1) do {
    private _logic = _selectedLogics select _i;
    private _spawnPos = getPosATL _logic;
    if (_spawnPos isEqualTo [0,0,0]) then { _spawnPos = getPos _logic; };
    
    _usedPositions pushBack _spawnPos;
    missionNamespace setVariable ["LL_g_usedTaskPos", _usedPositions];
    
    _spawnPos set [2, (_spawnPos select 2) + 0.2];

    private _zoneGuards = [];
    
    private _numPatrols = 2 + floor (random 2);
    for "_p" from 1 to _numPatrols do {
        private _grp = createGroup [east, true];
        _grp setBehaviour "SAFE";
        _grp setCombatMode "YELLOW";

        private _numGuards = 2 + floor (random 2);
        for "_g" from 1 to _numGuards do {
            private _guard = _grp createUnit ["O_G_Soldier_F", _spawnPos, [], 0, "CAN_COLLIDE"];
            _guard setPosATL _spawnPos;
            _guard allowDamage false;
            [_guard] spawn { sleep 3; (_this select 0) allowDamage true; };
            [_guard, false, true] call LL_fnc_applyTakistaniIdentity;
            _zoneGuards pushBack _guard;
        };
        private _wp = _grp addWaypoint [_spawnPos, 150];
        _wp setWaypointType "SAD";
        _wp setWaypointBehaviour "SAFE";
    };

    private _grpOfficer = createGroup [east, true];
    _grpOfficer setBehaviour "SAFE";
    _grpOfficer setCombatMode "YELLOW";
    private _officer = _grpOfficer createUnit ["O_Officer_F", _spawnPos, [], 0, "CAN_COLLIDE"];
    _officer setPosATL _spawnPos;
    _officer allowDamage false;
    [_officer] spawn { sleep 3; (_this select 0) allowDamage true; };
    [_officer, false, true] call LL_fnc_applyTakistaniIdentity;
    _officer setRank "COLONEL";
    private _wpO = _grpOfficer addWaypoint [_spawnPos, 50];
    _wpO setWaypointType "MOVE";
    _wpO setWaypointBehaviour "SAFE";

    private _allUnits = missionNamespace getVariable ["LL_TaskD_Doc_AllUnits", []];
    _allUnits append _zoneGuards;
    _allUnits pushBack _officer;
    missionNamespace setVariable ["LL_TaskD_Doc_AllUnits", _allUnits, true];

    if (_i == _targetIndex) then {
        _officer setVariable ["LL_hasDocuments", true, true];
        _targetOfficer = _officer;
    } else {
        _officer setVariable ["LL_hasDocuments", false, true];
    };

    _officer addEventHandler ["Killed", {
        params ["_unit"];
        
        if (_unit getVariable ["LL_hasDocuments", false]) then {
            
            if (isNil "LL_fnc_taskD_docComplete") then {
                missionNamespace setVariable ["LL_fnc_taskD_docComplete", {
                    params ["_unit"];
                    ["task_d_documents", "SUCCEEDED", true] call BIS_fnc_taskSetState;
                    missionNamespace setVariable ["LL_g_taskInProgress", false, true];
                    
                    private _allU = missionNamespace getVariable ["LL_TaskD_Doc_AllUnits", []];
                    private _alive = _allU select { alive _x };
                    if (count _alive > 0) then {
                        [_alive] spawn LL_fnc_taskCleanup;
                    };
                }];
            };

            private _actionTitle = format ["<t color='#FFFF00'>%1</t>", "Fouiller le corps (Documents)"];
            
            [
                _unit, 
                _actionTitle, 
                "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_search_ca.paa", 
                "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_search_ca.paa", 
                "_this distance _target < 3", 
                "true", 
                { (_this select 1) playActionNow "PutDown"; }, 
                {}, 
                {
                    params ["_target", "_caller", "_actionId", "_arguments"];
                    _arguments params ["_unit"];
                    
                    if (missionNamespace getVariable ["LL_TaskD_Doc_Triggered", false]) exitWith {};
                    missionNamespace setVariable ["LL_TaskD_Doc_Triggered", true];
                    
                    if (_caller canAdd "Item_Document_01_F") then { _caller addItem "Item_Document_01_F"; };
                    
                    [_target, _actionId] call BIS_fnc_holdActionRemove;
                    [_unit] call (missionNamespace getVariable "LL_fnc_taskD_docComplete");
                }, 
                {}, 
                [_unit], 
                1.5, 
                10, 
                true, 
                false
            ] call BIS_fnc_holdActionAdd;
            
            private _alivePlayers = allPlayers select { alive _x };
            private _allTaskUnits = missionNamespace getVariable ["LL_TaskD_Doc_AllUnits", []];
            private _guards = _allTaskUnits select { alive _x && _x != _unit };
            if (count _guards > 0 && count _alivePlayers > 0) then {
                private _grpsProcessed = [];
                {
                    private _guard = _x;
                    _guard setBehaviour "COMBAT";
                    _guard setCombatMode "RED";
                    _guard setSpeedMode "FULL";
                    { _guard reveal [_x, 4]; } forEach _alivePlayers;

                    private _grp = group _guard;
                    if !(_grp in _grpsProcessed) then {
                        _grpsProcessed pushBack _grp;
                        private _nearest = _alivePlayers select 0;
                        while { count waypoints _grp > 0 } do { deleteWaypoint [_grp, 0]; };
                        private _wp = _grp addWaypoint [getPosATL _nearest, 10];
                        _wp setWaypointType "SAD";
                    };
                } forEach _guards;
            };
        };
    }];
};

[
    group player,
    ["task_d_documents"],
    [
        localize "STR_LL_Task_01_Desc",
        localize "STR_LL_Task_01_Title",
        localize "STR_LL_Task_01_Marker"
    ],
    [_targetOfficer, true],
    "AUTOASSIGNED",
    5,
    true,
    "documents",
    false
] call BIS_fnc_taskCreate;

{ _x createDiaryRecord ["diary", [localize "STR_LL_Diary_Task01_Title", localize "STR_LL_Diary_Task01_Text"]]; } forEach (units group player);
