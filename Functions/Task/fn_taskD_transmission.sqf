/*
    LL_fnc_taskD_transmission
    Détruire les stations radio.
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

// Si pas assez de points, on en crée de faux (Fallback)
if (count _validSpawnPoints < 2) then {
    while { count _validSpawnPoints < 2 } do {
        private _dummyLogic = "Logic" createVehicleLocal (_centerPos getPos [300 + random 400, random 360]);
        _validSpawnPoints pushBack _dummyLogic;
    };
};

private _numRadios = (1 + floor (random 2)) min (count _validSpawnPoints);
private _shuffled = _validSpawnPoints call BIS_fnc_arrayShuffle;
private _selectedLogics = _shuffled select [0, _numRadios];

missionNamespace setVariable ["LL_TaskD_Trans_AllUnits", [], true];
missionNamespace setVariable ["LL_TaskD_Trans_Destroyed", 0, true];
missionNamespace setVariable ["LL_TaskD_Trans_Total", _numRadios, true];

// Tâche Parente Globale
[
    group player,
    ["task_d_transmission"],
    [
        localize "STR_LL_Task_D_Transmission_Desc",
        localize "STR_LL_Task_D_Transmission_Title",
        localize "STR_LL_Task_D_Transmission_Marker"
    ],
    objNull,
    "AUTOASSIGNED",
    5,
    true,
    "destroy",
    false
] call BIS_fnc_taskCreate;

// Journal / Briefing assigné à tout le groupe
{ _x createDiaryRecord ["diary", [localize "STR_LL_Diary_TaskD_Transmission_Title", localize "STR_LL_Diary_TaskD_Transmission_Text"]]; } forEach (units group player);

for "_i" from 0 to (_numRadios - 1) do {
    private _logic = _selectedLogics select _i;
    private _spawnPos = getPosATL _logic;
    if (_spawnPos isEqualTo [0,0,0]) then { _spawnPos = getPos _logic; };
    
    _usedPositions pushBack _spawnPos;
    missionNamespace setVariable ["LL_g_usedTaskPos", _usedPositions];
    
    _spawnPos set [2, (_spawnPos select 2) + 0.2]; // Z + 0.2 obligatoire (Anti-Glitch)

    private _zoneGuards = [];
    
    // Spawn des patrouilles de gardes Takistanis
    private _numPatrols = 1 + floor (random 2);
    for "_p" from 1 to _numPatrols do {
        private _grp = createGroup [east, true];
        _grp setBehaviour "SAFE";
        _grp setCombatMode "RED";

        private _numGuards = 2 + floor (random 2);
        for "_g" from 1 to _numGuards do {
            private _guardPos = _spawnPos getPos [random 5, random 360];
            _guardPos set [2, (_spawnPos select 2)];
            private _guard = _grp createUnit ["O_G_Soldier_F", _guardPos, [], 0, "CAN_COLLIDE"];
            _guard setPosATL _guardPos;
            _guard allowDamage false;
            [_guard] spawn { sleep 3; (_this select 0) allowDamage true; };
            [_guard, false, true] execVM "Functions\Civilian\fn_applyTakistaniIdentity.sqf";
            _zoneGuards pushBack _guard;
        };
        [_grp, _spawnPos, 40 + random 60] call BIS_fnc_taskPatrol;
    };

    private _allUnits = missionNamespace getVariable ["LL_TaskD_Trans_AllUnits", []];
    _allUnits append _zoneGuards;
    missionNamespace setVariable ["LL_TaskD_Trans_AllUnits", _allUnits, true];

    // Spawn de l'équipement radio
    private _radioClass = "RuggedTerminal_01_communications_F";
    private _radio = createVehicle [_radioClass, _spawnPos, [], 0, "CAN_COLLIDE"];
    _radio setPosATL [_spawnPos select 0, _spawnPos select 1, (_spawnPos select 2) - 0.2]; // Z = 0
    _radio setDir (getDir _logic);
    _radio setVectorUp [0, 0, 1];

    _radio allowDamage false;
    [_radio] spawn { sleep 3; (_this select 0) allowDamage true; };

    // Tâche enfant spécifique à CETTE radio
    private _taskChildId = format ["task_d_transmission_radio_%1", _i];
    [
        group player,
        [_taskChildId, "task_d_transmission"],
        [
            localize "STR_LL_Task_D_Transmission_Sub_Desc",
            localize "STR_LL_Task_D_Transmission_Sub_Title",
            localize "STR_LL_Task_D_Transmission_Sub_Marker"
        ],
        [_radio, true], // La radio sert de destination (marqueur 3D automatique)
        "AUTOASSIGNED",
        4,
        true,
        "destroy",
        false
    ] call BIS_fnc_taskCreate;

    // Action locale de sabotage (Sans réseau)
    _radio addAction [
        format ["<t color='#FFFF00'>%1</t>", localize "STR_LL_Task_D_Transmission_Action"],
        {
            params ["_target", "_caller", "_actionId", "_arguments"];
            _arguments params ["_radio", "_taskChildId"];
            
            // Verrou anti-double déclenchement
            if (_radio getVariable ["LL_TaskD_Trans_Triggered", false]) exitWith {};
            _radio setVariable ["LL_TaskD_Trans_Triggered", true, true];
            
            _target removeAction _actionId;
            _caller playActionNow "PutDown";
            
            // Placer la charge explosive
            private _pos = getPosATL _radio;
            private _charge = createVehicle ["DemoCharge_F", _pos, [], 0, "CAN_COLLIDE"];
            _charge attachTo [_radio, [0, 0, 0.2]];
            _charge setVectorUp [0, 0, 1];
            
            // Séquence d'explosion et validation
            [_radio, _charge, _taskChildId] spawn {
                params ["_radio", "_charge", "_taskChildId"];
                
                sleep 40; 
                
                if (!isNull _charge) then { deleteVehicle _charge; };
                
                private _pos = getPosATL _radio;
                "Bo_GBU12_LGB" createVehicle _pos; // Effet d'explosion
                
                if (!isNull _radio) then { deleteVehicle _radio; };
                
                // Valider la sous-tâche
                [_taskChildId, "SUCCEEDED", true] call BIS_fnc_taskSetState;
                
                private _destroyed = (missionNamespace getVariable ["LL_TaskD_Trans_Destroyed", 0]) + 1;
                missionNamespace setVariable ["LL_TaskD_Trans_Destroyed", _destroyed, true];
                private _total = missionNamespace getVariable ["LL_TaskD_Trans_Total", 1];
                
                // Si toutes les radios sont détruites, valider la tâche parente et nettoyer
                if (_destroyed >= _total) then {
                    ["task_d_transmission", "SUCCEEDED", true] call BIS_fnc_taskSetState;
                    missionNamespace setVariable ["LL_g_taskInProgress", false, true];
                    
                    private _allUnits = missionNamespace getVariable ["LL_TaskD_Trans_AllUnits", []];
                    private _guards = _allUnits select { alive _x };
                    if (count _guards > 0) then {
                        [_guards] spawn LL_fnc_taskCleanup;
                    };
                };
            };
        },
        [_radio, _taskChildId],
        10, true, true, "", "_this distance _target < 4", 4
    ];
};
