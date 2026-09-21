if (!isServer) exitWith {};

params [
    ["_locMarker", "", [""]]
];

if (_locMarker == "") then { _locMarker = "marker_0"; };

private _centerPos = getMarkerPos _locMarker;
private _nearLogics = nearestObjects [_centerPos, ["Logic", "Land_HelipadEmpty_F"], 500];

private _hvtPos = _centerPos;
private _otherLogics = [];

if (count _nearLogics > 0) then {
    private _shuffled = _nearLogics call BIS_fnc_arrayShuffle;
    _hvtPos = getPosATL (_shuffled select 0);
    _otherLogics = _shuffled select [1, (count _shuffled - 1)];
} else {
    _hvtPos = _centerPos getPos [random 50, random 360];
};

_hvtPos set [2, (_hvtPos select 2) + 0.2];

private _allGuards = [];
private _allGroups = [];

private _sentinelLogics = _otherLogics select [0, 4];
{
    private _sPos = getPosATL _x;
    _sPos set [2, (_sPos select 2) + 0.2];
    
    private _sGrp = createGroup [east, true];
    _sGrp setBehaviour "SAFE";
    _sGrp setCombatMode "WHITE";
    _allGroups pushBack _sGrp;

    private _sentinel = _sGrp createUnit ["O_G_Soldier_F", _sPos, [], 0, "CAN_COLLIDE"];
    _sentinel setPosATL _sPos;
    _sentinel setDir (random 360);
    _sentinel disableAI "MOVE";
    _sentinel allowDamage false;
    [_sentinel] spawn { sleep 3; (_this select 0) allowDamage true; };
    [_sentinel, false, true] execVM "Functions\Civilian\fn_applyTakistaniIdentity.sqf";
    
    _allGuards pushBack _sentinel;
} forEach _sentinelLogics;

private _patrolLogics = if (count _otherLogics > 0) then { _otherLogics } else { [_nearLogics] select { count _nearLogics > 0 } };

for "_p" from 1 to 2 do {
    private _pGrp = createGroup [east, true];
    _pGrp setBehaviour "SAFE";
    _pGrp setCombatMode "WHITE";
    _pGrp setSpeedMode "LIMITED";
    _allGroups pushBack _pGrp;

    private _pStartPos = if (count _patrolLogics > 0) then {
        getPosATL (selectRandom _patrolLogics)
    } else {
        _hvtPos getPos [30 + random 50, random 360]
    };
    _pStartPos set [2, (_pStartPos select 2) + 0.2];

    for "_g" from 1 to 2 do {
        private _pGuard = _pGrp createUnit ["O_G_Soldier_F", _pStartPos, [], 0, "CAN_COLLIDE"];
        _pGuard setPosATL _pStartPos;
        _pGuard allowDamage false;
        [_pGuard] spawn { sleep 3; (_this select 0) allowDamage true; };
        [_pGuard, false, true] execVM "Functions\Civilian\fn_applyTakistaniIdentity.sqf";
        _allGuards pushBack _pGuard;
    };

    [_pGrp, _pStartPos, 80] call BIS_fnc_taskPatrol;
    sleep 1;
};

private _bgGrp = createGroup [east, true];
_bgGrp setBehaviour "SAFE";
_bgGrp setCombatMode "WHITE";
_allGroups pushBack _bgGrp;

private _angles = [0, 120, 240];
{
    private _bgPos = _hvtPos getPos [3 + random 2, _x];
    _bgPos set [2, (_bgPos select 2) + 0.2];

    private _bg = _bgGrp createUnit ["O_G_Soldier_F", _bgPos, [], 0, "CAN_COLLIDE"];
    _bg setPosATL _bgPos;
    _bg setDir (_x + 180);
    _bg allowDamage false;
    [_bg] spawn { sleep 3; (_this select 0) allowDamage true; };
    [_bg, false, true] execVM "Functions\Civilian\fn_applyTakistaniIdentity.sqf";
    _allGuards pushBack _bg;
} forEach _angles;

private _hvtGrp = createGroup [east, true];
_hvtGrp setBehaviour "SAFE";
_hvtGrp setCombatMode "WHITE";
_allGroups pushBack _hvtGrp;

private _hvt = _hvtGrp createUnit ["O_Officer_F", _hvtPos, [], 0, "CAN_COLLIDE"];
_hvt setPosATL _hvtPos;
_hvt setDir (random 360);
_hvt allowDamage false;
[_hvt] spawn { sleep 3; (_this select 0) allowDamage true; };
[_hvt, false, true] execVM "Functions\Civilian\fn_applyTakistaniIdentity.sqf";
_hvt setRank "COLONEL";

missionNamespace setVariable ["LL_g_hvtAlertTriggered", false, true];

private _fn_triggerAlert = {
    params ["_shooterPos"];
    if (missionNamespace getVariable ["LL_g_hvtAlertTriggered", false]) exitWith {};
    missionNamespace setVariable ["LL_g_hvtAlertTriggered", true, true];

    {
        if (!isNull _x) then {
            _x enableAI "MOVE";
            _x setUnitPos "AUTO";
        };
    } forEach _allGuards;

    {
        if (!isNull _x) then {
            _x setBehaviour "COMBAT";
            _x setCombatMode "RED";
            _x setSpeedMode "FULL";
        };
    } forEach _allGroups;

    if (!isNil "_shooterPos" && { count _shooterPos >= 2 }) then {
        {
            if (!isNull _x) then {
                _x reveal [_shooterPos, 2];
            };
        } forEach _allGroups;
    };
};

{
    if (!isNull _x) then {
        _x addEventHandler ["FiredNear", {
            params ["_unit", "_firer", "_distance"];
            if (_distance < 250 && { side _firer != east }) then {
                [getPosATL _firer] call _fn_triggerAlert;
            };
        }];

        _x addEventHandler ["Killed", {
            params ["_unit", "_killer"];
            [getPosATL _unit] call _fn_triggerAlert;
        }];

        _x addEventHandler ["Hit", {
            params ["_unit", "_causedBy"];
            [getPosATL _unit] call _fn_triggerAlert;
        }];
    };
} forEach (_allGuards + [_hvt]);

private _mkrName = "mkr_taskD_hvt";
deleteMarker _mkrName;
createMarker [_mkrName, _hvtPos];
_mkrName setMarkerType "mil_objective";
_mkrName setMarkerColor "ColorOrange";
_mkrName setMarkerText (localize "STR_LL_Task_D_HVT_Marker");

[
    player,
    ["task_d_hvt"],
    [
        localize "STR_LL_Task_D_HVT_Desc",
        localize "STR_LL_Task_D_HVT_Title",
        localize "STR_LL_Task_D_HVT_Marker"
    ],
    _hvtPos,
    "AUTOASSIGNED",
    5,
    true,
    "kill",
    false
] call BIS_fnc_taskCreate;

[_hvt, _mkrName] spawn {
    params ["_unit", "_mkr"];
    while { !isNull _unit && { alive _unit } } do {
        _mkr setMarkerPos (getPosATL _unit);
        sleep 5;
    };
};

waitUntil {
    sleep 2;
    isNull _hvt || {!alive _hvt}
};

["task_d_hvt", "SUCCEEDED", true] call BIS_fnc_taskSetState;
missionNamespace setVariable ["LL_g_taskInProgress", false, true];

deleteMarker _mkrName;

private _remainingGuards = _allGuards select { !isNull _x && { alive _x } };
if (count _remainingGuards > 0) then {
    [_remainingGuards] spawn LL_fnc_taskCleanup;
};
