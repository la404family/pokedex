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
    "takeoff",
    false
] call BIS_fnc_taskCreate;

waitUntil {
    sleep 1;
    missionNamespace getVariable ["LL_g_extractionStarted", false]
};

private _unitsToCheck = [
    missionNamespace getVariable ["player_0", objNull],
    missionNamespace getVariable ["player_1", objNull],
    missionNamespace getVariable ["player_2", objNull],
    missionNamespace getVariable ["player_3", objNull],
    missionNamespace getVariable ["player_4", objNull],
    missionNamespace getVariable ["player_5", objNull]
] select { !isNull _x };

if (count _unitsToCheck == 0) then {
    _unitsToCheck = (playableUnits + switchableUnits) select { !isNull _x };
};
if (count _unitsToCheck == 0) then {
    _unitsToCheck = (allPlayers) select { !isNull _x };
};

private _deadCount = { !alive _x } count _unitsToCheck;

if (_deadCount == 0) then {
    ["task_mandatory_ext", "SUCCEEDED", true] call BIS_fnc_taskSetState;
} else {
    ["task_mandatory_ext", "FAILED", true] call BIS_fnc_taskSetState;
};
