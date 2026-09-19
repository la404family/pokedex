params [["_taskPos", [0,0,0], [[]]]];

if (!isServer) exitWith {};

if (missionNamespace getVariable ["LL_g_extractionActive", false]) exitWith {};
missionNamespace setVariable ["LL_g_extractionActive", true, true];

if (_taskPos isEqualTo [0,0,0]) then {
    private _players = allPlayers select { alive _x };
    if (count _players > 0) then {
        _taskPos = getPosATL (_players select 0);
    } else {
        _taskPos = getPosATL player;
    };
};

private _heliports = allMissionObjects "HeliH";
{ _heliports pushBackUnique _x; } forEach (allMissionObjects "Land_HelipadEmpty_F");
{ _heliports pushBackUnique _x; } forEach (allMissionObjects "HeliHSquare_F");

private _closestLZ = objNull;
private _minDist = 99999;
{
    private _d = _x distance2D _taskPos;
    if (_d < _minDist) then {
        _minDist = _d;
        _closestLZ = _x;
    };
} forEach _heliports;

private _lzPos = if (!isNull _closestLZ) then { getPos _closestLZ } else { _taskPos };
_lzPos set [2, 0];

[
    independent,
    ["task_extraction"],
    [
        localize "STR_LL_Task_Extraction_Desc",
        localize "STR_LL_Task_Extraction_Title",
        localize "STR_LL_Task_Extraction_Marker"
    ],
    _lzPos,
    "ASSIGNED",
    1,
    true,
    "takeoff",
    false
] call BIS_fnc_taskCreate;

private _mkrLZ = createMarker ["mkr_extraction_lz", _lzPos];
_mkrLZ setMarkerType "hd_pickup";
_mkrLZ setMarkerColor "ColorGreen";
_mkrLZ setMarkerText "EXTRACTION";

private _heliClass = "B_Heli_Transport_01_F";
if (!isNil "heli_BLUFOR" && { !isNull heli_BLUFOR }) then {
    _heliClass = typeOf heli_BLUFOR;
};

private _startDir = random 360;
private _startPos = [
    (_lzPos select 0) + 2500 * sin _startDir,
    (_lzPos select 1) + 2500 * cos _startDir,
    200
];

private _heli = createVehicle [_heliClass, _startPos, [], 0, "FLY"];
_heli setPos _startPos;
_heli setDir (_startPos getDir _lzPos);
_heli flyInHeight 150;
_heli allowDamage false;

[_heli] spawn {
    params ["_heli"];
    private _mkrHeli = createMarker ["mkr_extraction_heli", getPos _heli];
    _mkrHeli setMarkerType "b_air";
    _mkrHeli setMarkerColor "ColorBlue";
    _mkrHeli setMarkerText "HELI";

    while { alive _heli && missionNamespace getVariable ["LL_g_extractionActive", false] } do {
        _mkrHeli setMarkerPos (getPos _heli);
        sleep 0.5;
    };
    deleteMarker _mkrHeli;
};

createVehicleCrew _heli;
private _crew = crew _heli;
private _pilot = driver _heli;
private _gunners = _crew select { _x != _pilot };

{ _x allowDamage false; } forEach _crew;

private _grp = group _pilot;
_grp setBehaviour "CARELESS";
_grp setCombatMode "BLUE";

{
    _x disableAI "FSM";
    _x disableAI "TARGET";
    _x disableAI "AUTOTARGET";
    _x disableAI "AUTOCOMBAT";
    _x disableAI "CHECKVISIBLE";
    _x disableAI "COVER";
} forEach _crew;

while { count (waypoints _grp) > 0 } do { deleteWaypoint [_grp, 0]; };

_heli flyInHeight 70;
_heli limitSpeed 220;

private _wp = _grp addWaypoint [_lzPos, 0];
_wp setWaypointType "MOVE";
_wp setWaypointBehaviour "CARELESS";
_wp setWaypointSpeed "FULL";
_heli doMove _lzPos;

private _apTimer = 0;
waitUntil {
    sleep 0.4;
    _apTimer = _apTimer + 0.4;
    (_heli distance2D _lzPos < 150) || _apTimer > 180 || !alive _heli
};

if (!alive _heli) exitWith {};

while { count (waypoints _grp) > 0 } do { deleteWaypoint [_grp, 0]; };

private _nearLzEnemies = allUnits select { side group _x == east && alive _x && (_x distance2D _lzPos < 500) };

if (count _nearLzEnemies > 0) then {
    _heli flyInHeight 45;
    _heli limitSpeed 80;
    _heli setVehicleAmmo 1;

    private _wpCombat = _grp addWaypoint [_lzPos, 0];
    _wpCombat setWaypointType "LOITER";
    _wpCombat setWaypointLoiterRadius 120;
    _wpCombat setWaypointLoiterType "CIRCLE_L";
    _wpCombat setWaypointSpeed "LIMITED";

    _grp setBehaviour "COMBAT";
    _grp setCombatMode "RED";

    _pilot setBehaviour "CARELESS";
    _pilot disableAI "AUTOCOMBAT";
    _pilot disableAI "TARGET";
    _pilot disableAI "AUTOTARGET";
    _pilot disableAI "FSM";

    {
        _x setBehaviour "COMBAT";
        _x setCombatMode "RED";
        _x enableAI "TARGET";
        _x enableAI "AUTOTARGET";
        _x enableAI "AUTOCOMBAT";
        _x enableAI "FSM";
        _x enableAI "WEAPONAIM";
        _x enableAI "CHECKVISIBLE";
        _x setSkill ["aimingAccuracy", 1.0];
        _x setSkill ["aimingSpeed", 1.0];
        _x setSkill ["aimingShake", 0.01];
        _x setSkill ["spotDistance", 1.0];
        _x setSkill ["spotTime", 1.0];
        _x setSkill ["courage", 1.0];
        _x setSkill ["commanding", 1.0];
        _x setSkill ["general", 1.0];
    } forEach _gunners;

    private _combatTimer = 0;
    while { _combatTimer < 45 && alive _heli } do {
        private _enemies = allUnits select { side group _x == east && alive _x && (_x distance2D _lzPos < 500 || _x distance2D _heli < 500) };
        if (count _enemies == 0) exitWith {};

        _heli setVehicleAmmo 1;

        {
            _grp reveal [_x, 4];
            _heli reveal [_x, 4];
            private _e = _x;
            {
                _x reveal [_e, 4];
                _x commandTarget _e;
                _heli fireAtTarget [_e];
            } forEach _gunners;
        } forEach _enemies;

        sleep 1.5;
        _combatTimer = _combatTimer + 1.5;
    };

    while { count (waypoints _grp) > 0 } do { deleteWaypoint [_grp, 0]; };
};

if (!alive _heli) exitWith {};

_grp setBehaviour "CARELESS";
_grp setCombatMode "BLUE";

_pilot disableAI "TARGET";
_pilot disableAI "AUTOTARGET";
_pilot disableAI "AUTOCOMBAT";
_pilot disableAI "FSM";
_pilot disableAI "SUPPRESSION";

private _lzASL = (getPosASL _closestLZ select 2) max (getTerrainHeightASL _lzPos);
if (isNull _closestLZ) then { _lzASL = getTerrainHeightASL _lzPos; };

private _transitAlt = 65;
_heli flyInHeight _transitAlt;
_heli flyInHeightASL [_lzASL + _transitAlt, _lzASL + _transitAlt, _lzASL + _transitAlt];
_heli limitSpeed 70;

while { count (waypoints _grp) > 0 } do { deleteWaypoint [_grp, 0]; };
private _wpTransit = _grp addWaypoint [_lzPos, 0];
_wpTransit setWaypointType "MOVE";
_wpTransit setWaypointBehaviour "CARELESS";
_wpTransit setWaypointSpeed "NORMAL";
_heli doMove _lzPos;

private _transitTimer = 0;
waitUntil {
    sleep 0.2;
    _transitTimer = _transitTimer + 0.2;
    (_heli distance2D _lzPos < 30) || _transitTimer > 35 || !alive _heli
};

if (!alive _heli) exitWith {};

_heli limitSpeed 25;
private _alignTimer = 0;
waitUntil {
    sleep 0.1;
    _alignTimer = _alignTimer + 0.1;

    private _d2d = _heli distance2D _lzPos;
    private _dirTo = _heli getDir _lzPos;
    private _vel = velocity _heli;

    if (_d2d > 2.0) then {
        private _force = (_d2d * 0.2) min 4;
        _heli setVelocity [
            (_vel select 0) * 0.88 + (sin _dirTo * _force),
            (_vel select 1) * 0.88 + (cos _dirTo * _force),
            ((_lzASL + _transitAlt) - (getPosASL _heli select 2)) * 0.6
        ];
        _heli doMove _lzPos;
    } else {
        doStop _heli;
        _heli setVelocity [
            (_vel select 0) * 0.75,
            (_vel select 1) * 0.75,
            ((_lzASL + _transitAlt) - (getPosASL _heli select 2)) * 0.5
        ];
    };

    (_d2d < 3.0 && abs ((getPosASL _heli select 2) - (_lzASL + _transitAlt)) < 3.0) || _alignTimer > 15 || !alive _heli
};

if (!alive _heli) exitWith {};

[_heli, ["doorLB", 1]] remoteExec ["animateDoor", 0, _heli];
[_heli, ["doorRB", 1]] remoteExec ["animateDoor", 0, _heli];
_heli animateDoor ["doorLB", 1];
_heli animateDoor ["doorRB", 1];

_heli limitSpeed 35;
_heli land "LAND";

private _landWait = 0;
waitUntil {
    sleep 0.2;
    _landWait = _landWait + 0.2;
    isTouchingGround _heli || ((getPosATL _heli select 2) < 0.35 && (vectorMagnitude velocity _heli) < 0.5) || _landWait > 60 || !alive _heli
};

if (!alive _heli) exitWith {};

_heli setVelocity [0, 0, 0];
doStop _heli;
_heli setFuel 0; // Cut the engine for cinematic wait

_grp setBehaviour "COMBAT";
_grp setCombatMode "RED";

_pilot disableAI "MOVE";
_pilot disableAI "PATH";
_pilot disableAI "FSM";
_pilot disableAI "TARGET";
_pilot disableAI "AUTOTARGET";
_pilot setBehaviour "CARELESS";

{
    _x setBehaviour "COMBAT";
    _x setCombatMode "RED";
    _x enableAI "AUTOTARGET";
    _x enableAI "TARGET";
    _x enableAI "WEAPONAIM";
} forEach _gunners;

[_heli] call LL_fnc_extraction_secure;

sleep 2;

{ 0 fadeMusic 1; playMusic "LeadTrack01_F"; } remoteExec ["call", 0];

[_heli, ["doorLB", 0]] remoteExec ["animateDoor", 0, _heli];
[_heli, ["doorRB", 0]] remoteExec ["animateDoor", 0, _heli];
_heli animateDoor ["doorLB", 0];
_heli animateDoor ["doorRB", 0];

_heli setFuel 1;
_heli engineOn true;

_heli land "NONE";
while { count (waypoints _grp) > 0 } do { deleteWaypoint [_grp, 0]; };

_pilot enableAI "MOVE";
_pilot enableAI "PATH";
_pilot enableAI "FSM";
_pilot disableAI "AUTOCOMBAT";
_pilot disableAI "SUPPRESSION";
_pilot disableAI "TARGET";
_pilot disableAI "AUTOTARGET";
_pilot setBehaviour "CARELESS";

private _endDir = random 360;
private _endPos = [
    (_lzPos select 0) + 3500 * sin _endDir,
    (_lzPos select 1) + 3500 * cos _endDir,
    200
];

_grp setBehaviour "CARELESS";
_grp setCombatMode "BLUE";

_heli flyInHeight 85;
_heli limitSpeed 80;

private _wpClimb = _grp addWaypoint [_endPos, 0];
_wpClimb setWaypointType "MOVE";
_wpClimb setWaypointSpeed "NORMAL";
_wpClimb setWaypointBehaviour "CARELESS";
_heli doMove _endPos;

{
    _x enableAI "FSM";
    _x enableAI "TARGET";
    _x enableAI "AUTOTARGET";
    _x enableAI "WEAPONAIM";
    _x enableAI "CHECKVISIBLE";
    _x setBehaviour "COMBAT";
    _x setCombatMode "RED";
    _x setSkill ["aimingAccuracy", 1.0];
    _x setSkill ["aimingSpeed", 1.0];
    _x setSkill ["aimingShake", 0.01];
    _x setSkill ["spotDistance", 1.0];
    _x setSkill ["spotTime", 1.0];
    _x setSkill ["courage", 1.0];
    _x setSkill ["commanding", 1.0];
} forEach _gunners;

private _postTakeoffCombatTimer = 0;
while { _postTakeoffCombatTimer < 15 && alive _heli } do {
    private _enemies = allUnits select { side group _x == east && alive _x && (_x distance2D _heli < 650) };

    _heli setVehicleAmmo 1;
    _heli doMove _endPos;

    {
        private _e = _x;
        _grp reveal [_e, 4];
        _heli reveal [_e, 4];
        {
            _x reveal [_e, 4];
            _x commandTarget _e;
            _heli fireAtTarget [_e];
        } forEach _gunners;
    } forEach _enemies;

    sleep 1.5;
    _postTakeoffCombatTimer = _postTakeoffCombatTimer + 1.5;
};

if (!alive _heli) exitWith {};

{
    _x disableAI "FSM";
    _x disableAI "TARGET";
    _x disableAI "AUTOTARGET";
    _x disableAI "AUTOCOMBAT";
    _x disableAI "COVER";
} forEach _crew;

_heli flyInHeight 150;
_heli limitSpeed 260;

while { count (waypoints _grp) > 0 } do { deleteWaypoint [_grp, 0]; };
private _wpEnd = _grp addWaypoint [_endPos, 0];
_wpEnd setWaypointType "MOVE";
_wpEnd setWaypointSpeed "FULL";
_wpEnd setWaypointBehaviour "CARELESS";
_wpEnd setWaypointCombatMode "BLUE";
_heli doMove _endPos;

["task_extraction", "SUCCEEDED", true] call BIS_fnc_taskSetState;

private _tTimeout = time + 60;
waitUntil {
    sleep 1;
    (_heli distance2D _lzPos) > 1200 || time > _tTimeout
};

private _endType = "End1";
private _win = true;
if (missionNamespace getVariable ["LL_Task06_Failed", false] || missionNamespace getVariable ["LL_Task00_Failed", false] || missionNamespace getVariable ["LL_Task04_Failed", false]) then {
    _endType = "End2";
    _win = false;
};
[_endType, _win, 5] remoteExec ["BIS_fnc_endMission", 0];

waitUntil {
    sleep 2;
    private _players = allPlayers select { alive _x };
    ({ _x distance2D _heli <= 1500 } count _players) == 0
};

{ deleteVehicle _x; } forEach crew _heli;
deleteVehicle _heli;
deleteGroup _grp;
