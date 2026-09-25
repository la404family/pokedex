if (!isServer) exitWith {};

params [
    ["_locMarker", "", [""]],
    ["_optionalTasks", [], [[]]]
];

private _targetPos = getMarkerPos _locMarker;

[
    group player,
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
    "interact",
    false
] call BIS_fnc_taskCreate;

missionNamespace setVariable ["LL_g_civKilledByPlayers", false, true];

private _civGrp = createGroup [civilian, true];
private _civList = [];

for "_i" from 1 to 3 do {
    private _spawnPos = _targetPos getPos [30 + (random 80), random 360];
    _spawnPos set [2, (_spawnPos select 2) + 0.2];

    private _civ = _civGrp createUnit ["UK3CB_TKC_C_CIV", _spawnPos, [], 0, "NONE"];
    _civ setPosATL _spawnPos;
    _civ allowDamage false;

    [_civ, false, false] execVM "Functions\Civilian\fn_applyTakistaniIdentity.sqf";

    _civ addEventHandler ["Killed", {
        params ["_unit", "_killer", "_instigator"];
        if (isNull _instigator) then { _instigator = _killer; };
        if (!isNull _instigator && { side (group _instigator) == west || _instigator in (allPlayers + (switchableUnits select { !isNull _x })) }) then {
            missionNamespace setVariable ["LL_g_civKilledByPlayers", true, true];
        };
    }];

    _civList pushBack _civ;
};

[_civList] spawn {
    sleep 3;
    { if (!isNull _x) then { _x allowDamage true; }; } forEach (_this select 0);
};

missionNamespace setVariable ["LL_g_usedTaskPos", []];

{
    private _taskId = _x;
    switch (_taskId) do {
        case "TASK_CAPTIVE": { [_locMarker] spawn LL_fnc_taskD_captive; };
        case "TASK_HVT": { [_locMarker] spawn LL_fnc_taskD_hvt; };
        case "TASK_TRANSMISSION": { [_locMarker] spawn LL_fnc_taskD_transmission; };
        case "TASK_CHEMICAL": { [_locMarker] spawn LL_fnc_taskD_chemical; };
        case "TASK_DOCUMENTS": { [_locMarker] spawn LL_fnc_taskD_documents; };
        case "TASK_TIGRIS": { [_locMarker] spawn LL_fnc_taskD_tigris; };
    };
} forEach _optionalTasks;

waitUntil {
    sleep 1;
    missionNamespace getVariable ["LL_g_extractionStarted", false]
};

private _hasBavure = missionNamespace getVariable ["LL_g_civKilledByPlayers", false];

if (!_hasBavure) then {
    ["task_mandatory_civ", "SUCCEEDED", true] call BIS_fnc_taskSetState;
} else {
    ["task_mandatory_civ", "FAILED", true] call BIS_fnc_taskSetState;
};
