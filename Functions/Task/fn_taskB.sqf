/*
    LL_fnc_taskB
    Protéger la population civile
*/
params [
    ["_locMarker", "", [""]],
    ["_optionalTasks", [], [[]]]
];

if (!isServer) exitWith {};

private _targetPos = getMarkerPos _locMarker;

[
    player,
    ["task_mandatory_civ"],
    [
        localize "STR_LL_Task_Man2_Desc",
        localize "STR_LL_Task_Man2_Title",
        localize "STR_LL_Task_Man2_Marker"
    ],
    objNull,
    "CREATED",
    5,
    true,
    "defend",
    false
] call BIS_fnc_taskCreate;

// -- LOGIQUE DE SPAWN DES CIVILS --
// (A adapter : on spawn 3 civils près de l'objectif par exemple)
private _civGrp = createGroup [civilian, true];
private _civList = [];
for "_i" from 1 to 3 do {
    private _spawnPos = _targetPos getPos [50 + (random 100), random 360];
    private _civ = _civGrp createUnit ["UK3CB_TKC_C_CIV", _spawnPos, [], 0, "NONE"];
    _civ allowDamage false;
    _civList pushBack _civ;
};
sleep 3;
{ _x allowDamage true; } forEach _civList;

// -- LANCEMENT DES TACHES OPTIONNELLES --
// Puisque le joueur est sur zone, on peut initialiser les tâches optionnelles choisies
{
    private _taskId = _x;
    switch (_taskId) do {
        case "TASK_CAPTIVE": { [_locMarker] spawn LL_fnc_taskD_captive; };
        case "TASK_HVT": { [_locMarker] spawn LL_fnc_taskD_hvt; };
        case "TASK_DEFUSE": { [_locMarker] spawn LL_fnc_taskD_defuse; };
        case "TASK_TRANSMISSION": { [_locMarker] spawn LL_fnc_taskD_transmission; };
        case "TASK_CHEMICAL": { [_locMarker] spawn LL_fnc_taskD_chemical; };
        case "TASK_EXTRACT_HVT": { [_locMarker] spawn LL_fnc_taskD_extract_hvt; };
        case "TASK_DOCUMENTS": { [_locMarker] spawn LL_fnc_taskD_documents; };
        case "TASK_TIGRIS": { [_locMarker] spawn LL_fnc_taskD_tigris; };
        case "TASK_MILITIA": { [_locMarker] spawn LL_fnc_taskD_militia; };
    };
} forEach _optionalTasks;

// -- VERIFICATION DE FIN DE MISSION (EXTRACTION) --
// On attend que le processus de fin soit enclenché (ex: hélico sur le point de décoller)
// Nous utiliserons une variable globale (ex: LL_g_extractionStarted)
waitUntil {
    sleep 3;
    missionNamespace getVariable ["LL_g_extractionStarted", false]
};

// Vérification si au moins un civil lié à cette tâche est mort
private _civDeadCount = { !alive _x } count _civList;

if (_civDeadCount == 0) then {
    ["task_mandatory_civ", "SUCCEEDED", true] call BIS_fnc_taskSetState;
} else {
    ["task_mandatory_civ", "FAILED", true] call BIS_fnc_taskSetState;
};
