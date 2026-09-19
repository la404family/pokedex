params ["_cargo", "_dropPos"];

if (!isServer) exitWith {};
if (!alive _cargo) exitWith {};

west setFriend [east, 0];
east setFriend [west, 0];

private _spawnPosHeli = (getPosATL _cargo) getPos [1200, random 360];
if (_spawnPosHeli select 0 < 50 || { _spawnPosHeli select 0 > (worldSize - 50) || { _spawnPosHeli select 1 < 50 || { _spawnPosHeli select 1 > (worldSize - 50) } } }) then {
    _spawnPosHeli = [50, 50, 250];
} else {
    _spawnPosHeli set [2, 250];
};

if (isNil "_dropPos") then {
    _dropPos = _spawnPosHeli getPos [1500, random 360];
    if (_dropPos select 0 < 50 || { _dropPos select 0 > (worldSize - 50) || { _dropPos select 1 < 50 || { _dropPos select 1 > (worldSize - 50) } } }) then {
        _dropPos = [worldSize - 50, worldSize - 50, 150];
    } else {
        _dropPos set [2, 150];
    };
};

private _heli = createVehicle ["B_Heli_Transport_03_F", _spawnPosHeli, [], 0, "FLY"];
_heli setPosATL _spawnPosHeli;
createVehicleCrew _heli;

private _grp = group driver _heli;
private _crew = crew _heli;
private _pilot = driver _heli;
private _gunners = _crew select { _x != _pilot };

{ _x allowDamage false; } forEach _crew;
_heli allowDamage false;

_heli disableCollisionWith _cargo;
_cargo disableCollisionWith _heli;

_grp setBehaviour "CARELESS";
_grp setCombatMode "BLUE";

{
    _x disableAI "FSM";
    _x disableAI "TARGET";
    _x disableAI "AUTOTARGET";
    _x disableAI "AUTOCOMBAT";
    _x disableAI "COVER";
} forEach _crew;

private _targetPos = getPosATL _cargo;
_heli flyInHeight 70;
_heli setVehicleAmmo 1;

while { count (waypoints _grp) > 0 } do { deleteWaypoint [_grp, 0]; };
private _wp = _grp addWaypoint [_targetPos, 0];
_wp setWaypointType "MOVE";
_wp setWaypointBehaviour "CARELESS";
_wp setWaypointSpeed "FULL";
_heli doMove _targetPos;

private _apTimer = 0;
waitUntil {
    sleep 0.3;
    _apTimer = _apTimer + 0.3;
    (_heli distance2D _targetPos < 180) || _apTimer > 45 || !alive _heli || !alive _cargo
};

if (!alive _heli || !alive _cargo) exitWith {
    { deleteVehicle _x; } forEach crew _heli;
    deleteVehicle _heli;
    deleteGroup _grp;
};

private _nearEnemies = allUnits select { side group _x == east && alive _x && (_x distance2D _targetPos < 500) };

if (count _nearEnemies > 0) then {
    _heli flyInHeight 45;
    _heli limitSpeed 75;
    _heli setVehicleAmmo 1;

    _grp setBehaviour "COMBAT";
    _grp setCombatMode "RED";

    {
        _x enableAI "FSM";
        _x enableAI "TARGET";
        _x enableAI "AUTOTARGET";
        _x enableAI "AUTOCOMBAT";
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

    _pilot disableAI "TARGET";
    _pilot disableAI "AUTOTARGET";
    _pilot disableAI "AUTOCOMBAT";
    _pilot disableAI "COVER";
    _pilot setBehaviour "CARELESS";

    while { count (waypoints _grp) > 0 } do { deleteWaypoint [_grp, 0]; };
    private _wpCombat = _grp addWaypoint [_targetPos, 0];
    _wpCombat setWaypointType "LOITER";
    _wpCombat setWaypointLoiterRadius 120;
    _wpCombat setWaypointLoiterType "CIRCLE_L";
    _wpCombat setWaypointSpeed "LIMITED";

    private _combatTimer = 0;
    while { _combatTimer < 45 && alive _heli && alive _cargo } do {
        private _enemies = allUnits select { side group _x == east && alive _x && (_x distance2D _targetPos < 500 || _x distance2D _heli < 500) };
        if (count _enemies == 0) exitWith {};

        _heli setVehicleAmmo 1;

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
        _combatTimer = _combatTimer + 1.5;
    };

    while { count (waypoints _grp) > 0 } do { deleteWaypoint [_grp, 0]; };
};

if (!alive _heli || !alive _cargo) exitWith {
    { deleteVehicle _x; } forEach crew _heli;
    deleteVehicle _heli;
    deleteGroup _grp;
};

_grp setBehaviour "CARELESS";
_grp setCombatMode "BLUE";

{
    _x disableAI "FSM";
    _x disableAI "TARGET";
    _x disableAI "AUTOTARGET";
    _x disableAI "AUTOCOMBAT";
    _x disableAI "COVER";
} forEach _crew;

private _cargoPosASL = getPosASL _cargo;
private _cargoASL = _cargoPosASL select 2;
private _transitAlt = 65;
private _hoverHeight = 5;

_heli flyInHeight _transitAlt;
_heli flyInHeightASL [_cargoASL + _transitAlt, _cargoASL + _transitAlt, _cargoASL + _transitAlt];
_heli limitSpeed 70;

while { count (waypoints _grp) > 0 } do { deleteWaypoint [_grp, 0]; };
private _wpTransit = _grp addWaypoint [getPos _cargo, 0];
_wpTransit setWaypointType "MOVE";
_wpTransit setWaypointBehaviour "CARELESS";
_wpTransit setWaypointSpeed "NORMAL";
_heli doMove (getPos _cargo);

private _transitTimer = 0;
waitUntil {
    sleep 0.2;
    _transitTimer = _transitTimer + 0.2;
    (_heli distance2D _cargo < 30) || _transitTimer > 35 || !alive _heli || !alive _cargo
};

if (!alive _heli || !alive _cargo) exitWith {
    { deleteVehicle _x; } forEach crew _heli;
    deleteVehicle _heli;
    deleteGroup _grp;
};

_heli limitSpeed 20;
private _alignTimer = 0;
waitUntil {
    sleep 0.1;
    _alignTimer = _alignTimer + 0.1;

    private _d2d = _heli distance2D _cargo;
    private _dirTo = _heli getDir _cargo;
    private _vel = velocity _heli;

    if (_d2d > 2.0) then {
        private _force = (_d2d * 0.2) min 4;
        _heli setVelocity [
            (_vel select 0) * 0.88 + (sin _dirTo * _force),
            (_vel select 1) * 0.88 + (cos _dirTo * _force),
            ((_cargoASL + _transitAlt) - (getPosASL _heli select 2)) * 0.6
        ];
        _heli doMove (getPos _cargo);
    } else {
        doStop _heli;
        _heli setVelocity [
            (_vel select 0) * 0.75,
            (_vel select 1) * 0.75,
            ((_cargoASL + _transitAlt) - (getPosASL _heli select 2)) * 0.5
        ];
    };

    (_d2d < 2.5 && abs ((getPosASL _heli select 2) - (_cargoASL + _transitAlt)) < 2.5) || _alignTimer > 15 || !alive _heli || !alive _cargo
};

if (!alive _heli || !alive _cargo) exitWith {
    { deleteVehicle _x; } forEach crew _heli;
    deleteVehicle _heli;
    deleteGroup _grp;
};

private _currentTgtAlt = _cargoASL + _transitAlt;
private _finalTgtAlt = _cargoASL + _hoverHeight;
private _descendTimer = 0;

while { _currentTgtAlt > _finalTgtAlt && _descendTimer < 35 && alive _heli && alive _cargo } do {
    sleep 0.15;
    _descendTimer = _descendTimer + 0.15;

    _currentTgtAlt = (_currentTgtAlt - 0.25) max _finalTgtAlt;
    _heli flyInHeightASL [_currentTgtAlt, _currentTgtAlt, _currentTgtAlt];

    private _d2d = _heli distance2D _cargo;
    private _dirTo = _heli getDir _cargo;
    private _vel = velocity _heli;
    private _force = (_d2d * 0.25) min 3;

    _heli setVelocity [
        (_vel select 0) * 0.85 + (sin _dirTo * _force),
        (_vel select 1) * 0.85 + (cos _dirTo * _force),
        ((_currentTgtAlt - (getPosASL _heli select 2)) * 0.7) min 0.5 max -2.0
    ];
};

if (!alive _heli || !alive _cargo) exitWith {
    { deleteVehicle _x; } forEach crew _heli;
    deleteVehicle _heli;
    deleteGroup _grp;
};

private _hoverStabilizeTimer = 0;
waitUntil {
    sleep 0.1;
    _hoverStabilizeTimer = _hoverStabilizeTimer + 0.1;

    private _d2d = _heli distance2D _cargo;
    private _dirTo = _heli getDir _cargo;
    private _vel = velocity _heli;
    private _force = (_d2d * 0.2) min 2;

    _heli setVelocity [
        (_vel select 0) * 0.8 + (sin _dirTo * _force),
        (_vel select 1) * 0.8 + (cos _dirTo * _force),
        ((_finalTgtAlt - (getPosASL _heli select 2)) * 0.6) min 0.5 max -0.5
    ];

    (_d2d < 2.0 && abs ((getPosASL _heli select 2) - _finalTgtAlt) < 1.2) || _hoverStabilizeTimer > 5 || !alive _heli || !alive _cargo
};

if (!alive _heli || !alive _cargo) exitWith {
    { deleteVehicle _x; } forEach crew _heli;
    deleteVehicle _heli;
    deleteGroup _grp;
};

_cargo allowDamage false;
_cargo enableRopeAttach true;
_heli enableRopeAttach true;

private _originalMass = getMass _cargo;
_cargo setMass 10;

private _attachedWithRopes = false;
private _ropes = [];

_heli setSlingLoad _cargo;

private _slingTimer = 0;
waitUntil {
    sleep 0.1;
    _slingTimer = _slingTimer + 0.1;
    !isNull (getSlingLoad _heli) || _slingTimer > 2.0 || !alive _heli || !alive _cargo
};

if (!alive _heli || !alive _cargo) exitWith {
    _cargo setMass _originalMass;
    { deleteVehicle _x; } forEach crew _heli;
    deleteVehicle _heli;
    deleteGroup _grp;
};

if (isNull (getSlingLoad _heli)) then {
    _attachedWithRopes = true;
    _cargo setMass 1;

    _cargo attachTo [_heli, [0, 0, -5]];
    _cargo setVectorUp [0, 0, 1];

    private _r1 = ropeCreate [_heli, [-1.5, 0, -1], _cargo, [-1.2, 2.5, 1.2], 5];
    private _r2 = ropeCreate [_heli, [1.5, 0, -1], _cargo, [1.2, 2.5, 1.2], 5];
    private _r3 = ropeCreate [_heli, [-1.5, 0, -1], _cargo, [-1.2, -2.5, 1.2], 5];
    private _r4 = ropeCreate [_heli, [1.5, 0, -1], _cargo, [1.2, -2.5, 1.2], 5];
    _ropes = [_r1, _r2, _r3, _r4];
};

_cargo removeAllEventHandlers "Killed";
_cargo removeAllEventHandlers "HandleDamage";

[_heli, _cargo, _dropPos, _grp] spawn {
    params ["_heli", "_cargo", "_dropPos", "_grp"];

    sleep 120;

    if (!isNull _heli && { alive _heli }) then {
        private _nearPlayers = { alive _x && _x distance2D _heli < 800 } count allPlayers;

        if (_nearPlayers > 0 || !isNull (getSlingLoad _heli) || !isNull (attachedTo _cargo)) then {
            {
                _x disableAI "FSM";
                _x disableAI "TARGET";
                _x disableAI "AUTOTARGET";
                _x disableAI "AUTOCOMBAT";
                _x disableAI "COVER";
                _x setBehaviour "CARELESS";
                _x setCombatMode "BLUE";
            } forEach (crew _heli);

            _grp setBehaviour "CARELESS";
            _grp setCombatMode "BLUE";

            while { count (waypoints _grp) > 0 } do { deleteWaypoint [_grp, 0]; };
            private _wpEscape = _grp addWaypoint [_dropPos, 0];
            _wpEscape setWaypointType "MOVE";
            _wpEscape setWaypointSpeed "FULL";
            _wpEscape setWaypointBehaviour "CARELESS";
            _heli doMove _dropPos;
            _heli flyInHeight 120;
            _heli limitSpeed 300;

            private _timeout = time + 60;
            waitUntil {
                sleep 2;
                isNull _heli || !alive _heli || { ({ alive _x && _x distance2D _heli < 1200 } count allPlayers) == 0 } || time > _timeout
            };
        };

        if (!isNull _cargo) then {
            detach _cargo;
            if (!isNull (getSlingLoad _heli)) then { _heli setSlingLoad objNull; };
            deleteVehicle _cargo;
        };

        if (!isNull _heli) then {
            { deleteVehicle _x; } forEach (crew _heli);
            deleteVehicle _heli;
        };

        if (!isNull _grp) then {
            deleteGroup _grp;
        };
    };
};

private _climbTgtAlt = _cargoASL + _hoverHeight;
private _climbMaxAlt = _cargoASL + _transitAlt;
private _climbTimer = 0;

_heli limitSpeed 25;

while { _climbTgtAlt < _climbMaxAlt && _climbTimer < 30 && alive _heli && alive _cargo } do {
    sleep 0.15;
    _climbTimer = _climbTimer + 0.15;

    _climbTgtAlt = (_climbTgtAlt + 0.35) min _climbMaxAlt;
    _heli flyInHeightASL [_climbTgtAlt, _climbTgtAlt, _climbTgtAlt];

    private _d2d = _heli distance2D _cargo;
    private _dirTo = _heli getDir _cargo;
    private _vel = velocity _heli;
    private _force = (_d2d * 0.2) min 2.5;

    _heli setVelocity [
        (_vel select 0) * 0.85 + (sin _dirTo * _force),
        (_vel select 1) * 0.85 + (cos _dirTo * _force),
        ((_climbTgtAlt - (getPosASL _heli select 2)) * 0.8) min 2.5 max 0
    ];
};

if (!alive _heli || !alive _cargo) exitWith {
    { deleteVehicle _x; } forEach crew _heli;
    deleteVehicle _heli;
    deleteGroup _grp;
};

_heli flyInHeight 75;
_heli limitSpeed 70;

_grp setBehaviour "CARELESS";
_grp setCombatMode "BLUE";

while { count (waypoints _grp) > 0 } do { deleteWaypoint [_grp, 0]; };
private _wpMove = _grp addWaypoint [_dropPos, 0];
_wpMove setWaypointType "MOVE";
_wpMove setWaypointSpeed "NORMAL";
_wpMove setWaypointBehaviour "CARELESS";
_heli doMove _dropPos;

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

private _postClimbCombatTimer = 0;
while { _postClimbCombatTimer < 15 && alive _heli && alive _cargo } do {
    private _enemies = allUnits select { side group _x == east && alive _x && (_x distance2D _heli < 650 || _x distance2D _cargo < 650) };

    _heli setVehicleAmmo 1;
    _heli doMove _dropPos;

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
    _postClimbCombatTimer = _postClimbCombatTimer + 1.5;
};

if (!alive _heli || !alive _cargo) exitWith {
    { deleteVehicle _x; } forEach crew _heli;
    deleteVehicle _heli;
    deleteGroup _grp;
};

{
    _x disableAI "FSM";
    _x disableAI "TARGET";
    _x disableAI "AUTOTARGET";
    _x disableAI "AUTOCOMBAT";
    _x disableAI "COVER";
} forEach _crew;

_heli flyInHeight 85;
_heli limitSpeed 140;

while { count (waypoints _grp) > 0 } do { deleteWaypoint [_grp, 0]; };
private _wpEnd = _grp addWaypoint [_dropPos, 0];
_wpEnd setWaypointType "MOVE";
_wpEnd setWaypointSpeed "FULL";
_wpEnd setWaypointBehaviour "CARELESS";
_heli doMove _dropPos;

private _remaining = missionNamespace getVariable ["LL_Task04_RemainingTrucks", []];
_remaining = _remaining - [_cargo];
missionNamespace setVariable ["LL_Task04_RemainingTrucks", _remaining, true];

private _mkr = _cargo getVariable ["LL_Task04_Marker", ""];
if (_mkr != "") then { deleteMarker _mkr; };

if (count _remaining == 0) then {
    ["task_04_convoy", "SUCCEEDED", true] call BIS_fnc_taskSetState;
    missionNamespace setVariable ["LL_g_taskInProgress", false, true];
};

waitUntil { sleep 1; (_heli distance2D _dropPos < 200) || !alive _heli };

if (_attachedWithRopes) then {
    detach _cargo;
    { ropeDestroy _x; } forEach _ropes;
} else {
    _heli setSlingLoad objNull;
};

sleep 2;

waitUntil {
    sleep 1;
    private _players = allPlayers select { alive _x };
    ({ _x distance2D _cargo <= 800 } count _players) == 0
};
deleteVehicle _cargo;

waitUntil {
    sleep 2;
    private _players = allPlayers select { alive _x };
    ({ _x distance2D _heli <= 1500 } count _players) == 0
};

{ deleteVehicle _x; } forEach crew _heli;
deleteVehicle _heli;
deleteGroup _grp;
