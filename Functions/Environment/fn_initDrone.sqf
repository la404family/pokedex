params ["_drone"];
if (!isServer) exitWith {};
if (isNil "_drone" || {isNull _drone}) exitWith {};

_drone allowDamage false;
_drone setCaptive true;

if (count crew _drone == 0) then {
    createVehicleCrew _drone;
};

private _grp = group _drone;
_grp setBehaviour "CARELESS";
_grp setCombatMode "BLUE";

{
    _x disableAI "FSM";
    _x disableAI "TARGET";
    _x disableAI "AUTOTARGET";
    _x disableAI "AUTOCOMBAT";
} forEach (crew _drone);

while {(count (waypoints _grp)) > 0} do {
    deleteWaypoint ((waypoints _grp) select 0);
};

[_drone, _grp] spawn {
    params ["_drone", "_grp"];

    waitUntil {
        sleep 0.3;
        !isNil "MISSION_start_crate" || { (missionNamespace getVariable ["MISSION_intro_lz", [0,0,0]]) isNotEqualTo [0,0,0] }
    };

    private _crate = missionNamespace getVariable ["MISSION_start_crate", objNull];
    private _cratePos = if (!isNull _crate) then { getPosATL _crate } else { (missionNamespace getVariable ["MISSION_intro_lz", [0,0,0]]) vectorAdd [12, 12, 0] };

    _drone setPosATL [(_cratePos select 0) + 1.5, (_cratePos select 1) + 1.5, 1.8];
    _drone setDir 45;
    _drone engineOn true;
    _drone flyInHeight 1.8;

    while {(count (waypoints _grp)) > 0} do { deleteWaypoint ((waypoints _grp) select 0); };
    private _wpInit = _grp addWaypoint [[(_cratePos select 0) + 1.5, (_cratePos select 1) + 1.5, 1.8], 0];
    _wpInit setWaypointType "HOLD";
    _drone doMove [(_cratePos select 0) + 1.5, (_cratePos select 1) + 1.5, 1.8];

    waitUntil {
        sleep 0.3;
        missionNamespace getVariable ["MISSION_players_disembarked", false]
    };

    sleep 1.0;

    private _squad = [];
    for "_i" from 0 to 5 do {
        private _u = missionNamespace getVariable [format["Player_%1", _i], objNull];
        if (!isNull _u && {alive _u}) then { _squad pushBack _u; };
    };

    if (_squad isEqualTo []) then {
        _squad = (allPlayers select { alive _x }) select { isNull objectParent _x };
    };

    private _targetCenter = if (_squad isNotEqualTo []) then { getPos (_squad select 0) } else { getPos _drone };

    _drone flyInHeight 1;

    while {(count (waypoints _grp)) > 0} do { deleteWaypoint ((waypoints _grp) select 0); };
    private _wpMove = _grp addWaypoint [_targetCenter, 0];
    _wpMove setWaypointType "MOVE";
    _wpMove setWaypointSpeed "NORMAL";

    for "_tour" from 1 to 3 do {
        for "_angle" from 0 to 315 step 45 do {
            if (!alive _drone) exitWith {};
            if (_squad isNotEqualTo [] && {alive (_squad select 0)}) then {
                _targetCenter = getPos (_squad select 0);
            };
            private _orbitPos = _targetCenter getPos [2.5, _angle];
            _drone doMove _orbitPos;
            sleep 1.0;
        };
    };

    _drone flyInHeight 5;
    [_drone] remoteExec ["LL_fnc_droneRadar", 0, "DroneRadar_JIP"];
    sleep 4;

    _drone flyInHeight 12;

    private _leaderStoppedTime = 0;
    private _currentState = "NONE";

    while {alive _drone} do {
        sleep 2;

        private _squadNow = [];
        for "_i" from 0 to 5 do {
            private _u = missionNamespace getVariable [format["Player_%1", _i], objNull];
            if (!isNull _u && {alive _u}) then { _squadNow pushBack _u; };
        };

        private _leader = if (_squadNow isNotEqualTo []) then { leader group (_squadNow select 0) } else { objNull };

        if (!isNull _leader) then {
            if (speed _leader < 1) then {
                _leaderStoppedTime = _leaderStoppedTime + 2;
            } else {
                _leaderStoppedTime = 0;
            };

            private _leaderPos = getPos _leader;

            if (_leaderStoppedTime >= 12) then {
                if (_currentState != "HOLD") then {
                    _currentState = "HOLD";
                    while {(count (waypoints _grp)) > 0} do { deleteWaypoint ((waypoints _grp) select 0); };
                    private _wpH = _grp addWaypoint [_leaderPos, 0];
                    _wpH setWaypointType "HOLD";
                } else {
                    [_grp, 0] setWaypointPosition [_leaderPos, 0];
                };
            } else {
                if (_currentState != "LOITER") then {
                    _currentState = "LOITER";
                    while {(count (waypoints _grp)) > 0} do { deleteWaypoint ((waypoints _grp) select 0); };
                    private _wpL = _grp addWaypoint [_leaderPos, 0];
                    _wpL setWaypointType "LOITER";
                    _wpL setWaypointLoiterRadius 25;
                } else {
                    [_grp, 0] setWaypointPosition [_leaderPos, 0];
                };
            };
        };
    };
};
