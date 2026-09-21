/*
    LL_fnc_taskC
    Extraction en toute sécurité
*/
params [
    ["_locMarker", "", [""]]
];

if (!isServer) exitWith {};

[
    player,
    ["task_mandatory_ext"],
    [
        localize "STR_LL_Task_Man3_Desc",
        localize "STR_LL_Task_Man3_Title",
        localize "STR_LL_Task_Man3_Marker"
    ],
    objNull,
    "CREATED",
    5,
    true,
    "heli",
    false
] call BIS_fnc_taskCreate;

// -- VERIFICATION DE FIN DE MISSION (EXTRACTION) --
// On attend que l'hélicoptère d'extraction décolle ou que la mission se termine
waitUntil {
    sleep 3;
    missionNamespace getVariable ["LL_g_extractionStarted", false]
};

// Vérifier si toute l'équipe de départ est en vie
// Pour cet exemple, on regarde tous les joueurs (ou toutes les unités jouables)
private _allPlayers = playableUnits + (switchableUnits select { _x != player });
if (isMultiplayer) then {
    _allPlayers = playableUnits;
} else {
    // Solo
    _allPlayers = units group player;
};

private _deadTeammates = { !alive _x } count _allPlayers;

if (_deadTeammates == 0) then {
    ["task_mandatory_ext", "SUCCEEDED", true] call BIS_fnc_taskSetState;
} else {
    ["task_mandatory_ext", "FAILED", true] call BIS_fnc_taskSetState;
};
