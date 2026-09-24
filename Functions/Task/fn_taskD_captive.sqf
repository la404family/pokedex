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

private _spawnPos = _centerPos;

if (count _validSpawnPoints > 0) then {
    private _shuffled = _validSpawnPoints call BIS_fnc_arrayShuffle;
    _spawnPos = getPosATL (_shuffled select 0);
} else {
    _spawnPos = _centerPos getPos [random 50, random 360];
};

_usedPositions pushBack _spawnPos;
missionNamespace setVariable ["LL_g_usedTaskPos", _usedPositions];

_spawnPos set [2, (_spawnPos select 2) + 0.2];

private _allUnits = [];

private _numGroups = 3;
for "_i" from 0 to (_numGroups - 1) do {
    private _grpEnemy = createGroup [east, true];
    _grpEnemy setBehaviour "SAFE";
    _grpEnemy setCombatMode "RED";

    private _numGuards = 2 + floor (random 2);
    for "_g" from 1 to _numGuards do {
        sleep 1.5;
        private _guardPos = _spawnPos getPos [1 + random 3, random 360];
        _guardPos set [2, (_guardPos select 2) + 0.2];
        
        private _guard = _grpEnemy createUnit ["O_G_Soldier_F", _guardPos, [], 0, "CAN_COLLIDE"];
        _guard setPosATL _guardPos;
        _guard allowDamage false;
        [_guard] spawn { sleep 3; (_this select 0) allowDamage true; };
        [_guard, false, true] execVM "Functions\Civilian\fn_applyTakistaniIdentity.sqf";
        _allUnits pushBack _guard;
    };

    private _currentRadius = round (15 + (_i * 15) + (random 10));
    [_grpEnemy, _spawnPos, _currentRadius] call BIS_fnc_taskPatrol;
};

sleep 1.5;

private _grpCiv = createGroup [civilian, true];
private _hostage = _grpCiv createUnit ["C_man_polo_1_F", _spawnPos, [], 0, "CAN_COLLIDE"];
_hostage setPosATL _spawnPos;
_hostage allowDamage false;
[_hostage] spawn { sleep 3; (_this select 0) allowDamage true; };

_hostage setCaptive true;
removeAllWeapons _hostage;
removeBackpack _hostage;

_hostage setVariable ["LL_Task_Status", "WAIT"];

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
    ["task_d_captive", "FAILED", true] call BIS_fnc_taskSetState;
    missionNamespace setVariable ["LL_g_taskInProgress", false];
}];

_hostage addAction [
    format ["<t color='#FFFF00'>%1</t>", localize "STR_LL_Task_00_Action"],
    {
        params ["_target", "_caller", "_actionId", "_arguments"];
        if (missionNamespace getVariable ["LL_TaskDCaptive_Triggered", false]) exitWith {};
        missionNamespace setVariable ["LL_TaskDCaptive_Triggered", true];
        
        _target removeAction _actionId;
        _target setVariable ["LL_Task_Status", "ACTION"];
        
        [_target, _caller] spawn {
            params ["_hostage", "_caller"];
            
            _hostage setCaptive false;
            _hostage enableAI "ANIM";
            
            private _hostageFixedPos = getPosATL _hostage;
            private _hostageFixedDir = getDir _hostage;
            
            _hostage switchMove "Acts_ExecutionVictim_Unbow";
            
            private _tStart = time;
            while { alive _hostage && (_hostage getVariable ["LL_Task_Status", "WAIT"]) == "ACTION" && (time - _tStart) < 8.5 } do {
                _hostage setPosATL _hostageFixedPos;
                _hostage setDir _hostageFixedDir;
                sleep 0.05;
            };
            
            if (!alive _hostage) exitWith {};
            
            _hostage setPosATL _hostageFixedPos;
            _hostage setDir _hostageFixedDir;
            _hostage switchMove "";
            _hostage setVariable ["LL_Task_Status", "FREE"];
            
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
                params ["_h"];
                while {alive _h && group _h == group player} do {
                    if (vehicle _h == _h && _h distance2D player > 30) then {
                        _h doMove (getPosATL player);
                    };
                    sleep 5;
                };
            };
            
            ["task_d_captive", "SUCCEEDED", true] call BIS_fnc_taskSetState;
            missionNamespace setVariable ["LL_g_taskInProgress", false];
        };
    },
    nil, 6, true, true, "", "_this distance _target < 4"
];

[
    true,
    ["task_d_captive"],
    [
        localize "STR_LL_Task_00_Desc",
        localize "STR_LL_Task_00_Title",
        localize "STR_LL_Task_00_MarkerMain"
    ],
    [_hostage, true],
    "AUTOASSIGNED",
    5,
    true,
    "interact",
    false
] call BIS_fnc_taskCreate;

{
    _x createDiaryRecord ["diary", [localize "STR_LL_Diary_Task00_Title", localize "STR_LL_Diary_Task00_Text"]];
} forEach (units group player);

waitUntil {
    sleep 2;
    isNull _hostage || {!alive _hostage} || {(_hostage getVariable ["LL_Task_Status", "WAIT"]) == "FREE"}
};

private _guards = _allUnits select { alive _x };
if (count _guards > 0) then {
    [_guards] spawn LL_fnc_taskCleanup;
};
