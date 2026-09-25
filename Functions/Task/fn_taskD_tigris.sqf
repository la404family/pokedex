params [
    ["_locMarker", "", [""]]
];

if (_locMarker == "" || _locMarker == "init") then { _locMarker = "marker_0"; };

private _centerPos = getMarkerPos _locMarker;
private _radius = (markerSize _locMarker) select 0;
if (_radius == 0) then { _radius = 250; };

private _nearHelipads = nearestObjects [_centerPos, ["Land_HelipadEmpty_F"], _radius];
private _usedPositions = missionNamespace getVariable ["LL_g_usedTaskPos", []];
private _validSpawnPoints = _nearHelipads select {
    private _candidate = _x;
    (_usedPositions findIf { _x distance2D _candidate < 15 }) == -1
};

if (count _validSpawnPoints == 0) then { _validSpawnPoints = _nearHelipads; };
if (count _validSpawnPoints == 0) then {
    private _fallback = _centerPos findEmptyPosition [10, 150, "B_Truck_01_transport_F"];
    if (count _fallback == 0) then { _fallback = _centerPos getPos [40, random 360]; };
    private _dummy = "Land_HelipadEmpty_F" createVehicle _fallback;
    _validSpawnPoints = [_dummy];
};

private _posVeh = getPosATL (_validSpawnPoints select 0);
if (typeOf (_validSpawnPoints select 0) == "Land_HelipadEmpty_F") then { deleteVehicle (_validSpawnPoints select 0); };

_usedPositions pushBack _posVeh;
missionNamespace setVariable ["LL_g_usedTaskPos", _usedPositions];

_posVeh set [2, (_posVeh select 2) + 0.2];

private _numGroups = 2 + floor(random 3); // 2 to 4 groups
private _groupSizes = [];
for "_i" from 1 to _numGroups do {
    _groupSizes pushBack 2; // Each group has exactly 2 enemies
};
private _enemies = [];
private _groups = [];
private _classes = ["O_G_Soldier_F", "O_G_Soldier_GL_F", "O_G_Soldier_AR_F", "O_G_Soldier_LAT_F"];

for "_gIdx" from 0 to (_numGroups - 1) do {
    private _sz = _groupSizes select _gIdx;
    private _grp = createGroup [east, true];
    _grp setBehaviour "SAFE";
    _grp setSpeedMode "LIMITED";
    _grp setCombatMode "YELLOW";

    for "_u" from 1 to _sz do {
        private _cls = selectRandom _classes;
        private _spawnSpot = _posVeh getPos [15 + random 20, random 360];
        private _unit = _grp createUnit [_cls, _spawnSpot, [], 0, "CAN_COLLIDE"];
        _unit setPosASL _spawnSpot;
        _unit allowDamage false;
        [_unit] spawn { sleep 3; (_this select 0) allowDamage true; };
        [_unit, false, true] call LL_fnc_applyTakistaniIdentity;

        _unit setSkill ["courage", 1];
        _unit allowFleeing 0;
        _enemies pushBack _unit;
    };

    if (_gIdx == 0) then {
        private _wp = _grp addWaypoint [_posVeh getPos [20, random 360], 0];
        _wp setWaypointType "MOVE";
        _wp setWaypointBehaviour "SAFE";
        private _wp2 = _grp addWaypoint [_posVeh getPos [30, random 360], 0];
        _wp2 setWaypointType "MOVE";
        private _wp3 = _grp addWaypoint [waypointPosition _wp, 0];
        _wp3 setWaypointType "CYCLE";
    } else {
        private _wp = _grp addWaypoint [_posVeh getPos [50, random 360], 0];
        _wp setWaypointType "MOVE";
        _wp setWaypointBehaviour "SAFE";
        private _wp2 = _grp addWaypoint [_posVeh getPos [60, random 360], 0];
        _wp2 setWaypointType "MOVE";
        private _wp3 = _grp addWaypoint [_posVeh getPos [50, random 360], 0];
        _wp3 setWaypointType "MOVE";
        private _wp4 = _grp addWaypoint [waypointPosition _wp, 0];
        _wp4 setWaypointType "CYCLE";
    };
    _groups pushBack _grp;
};

private _dca = createVehicle ["O_APC_Tracked_02_AA_F", _posVeh, [], 0, "CAN_COLLIDE"];
_dca setPosATL _posVeh;
_dca allowDamage false;
[_dca] spawn { sleep 3; (_this select 0) allowDamage true; };
createVehicleCrew _dca;

{
    [_x, false, true] call LL_fnc_applyTakistaniIdentity;
} forEach (crew _dca);

(group (driver _dca)) setCombatMode "YELLOW";
(group (driver _dca)) setBehaviour "SAFE";
_dca setFuel 0; 
_dca setVariable ["LL_Task_Status", "WAIT"];

missionNamespace setVariable ["LL_Heli_Jammed", true];
missionNamespace setVariable ["LL_TaskDTigris_Finished", false];

private _subVehicles = "task_tigris_vehicles";

[
    true,
    ["task_tigris"],
    [
        localize "STR_LL_Task_08_Desc",
        localize "STR_LL_Task_08_Title",
        ""
    ],
    objNull,
    "AUTOASSIGNED",
    5,
    true,
    "destroy",
    false
] call BIS_fnc_taskCreate;

[
    true,
    [_subVehicles, "task_tigris"],
    [
        localize "STR_LL_Task_08_MarkerVehicles",
        localize "STR_LL_Task_08_MarkerVehicles",
        ""
    ],
    [_dca, true],
    "CREATED",
    -1,
    false,
    "destroy",
    false
] call BIS_fnc_taskCreate;

{ _x createDiaryRecord ["diary", [localize "STR_LL_Diary_Task08_Title", localize "STR_LL_Diary_Task08_Text"]]; } forEach (units group player);

LL_fnc_taskD_tigris_smokeRing = {
    params [
        ["_center", [0,0,0], [[]]],
        ["_maxRadius", 40, [0]],
        ["_duration", 3, [0]],
        ["_color", [0.8, 0.8, 0.8, 1], [[]]]
    ];

    private _source = createVehicleLocal ["#particlesource", _center];
    _source setParticleCircle [0.1, [2, 2, 0.1]];
    _source setParticleRandom [0.3, [0.2, 0.2, 0.1], [0.3, 0.3, 0.1], 0, 0.3, [0,0,0,0.05], 0, 0];
    _source setParticleParams [
        ["\A3\data_f\ParticleEffects\Universal\Universal", 16, 7, 48, 1], "", "Billboard",
        1, 2.5, [0,0,0], [0,0,0], 0, 1.275, 1, 0.2,
        [1.5, 6, 10], 
        [
            [_color select 0, _color select 1, _color select 2, (_color select 3) * 0.8],
            [_color select 0, _color select 1, _color select 2, (_color select 3) * 0.4],
            [_color select 0, _color select 1, _color select 2, 0]
        ],
        [0.5], 0.1, 0, "", "", _source
    ];
    _source setDropInterval 0.01;

    private _startTime = time;
    private _radius = 0.1;
    while { _radius < _maxRadius && (time - _startTime) < _duration } do {
        private _progress = (time - _startTime) / _duration;
        _radius = 0.1 + (_maxRadius - 0.1) * _progress;
        _source setParticleCircle [_radius, [2 * (1 - _progress), 2 * (1 - _progress), 0.1]];
        sleep 0.03;
    };
    deleteVehicle _source;
};

private _addActionCode = {
    params ["_target"];
    _target addAction [
        format ["<t color='#FFFF00'>%1</t>", localize "STR_LL_Task_03_Action"],
        {
            params ["_target", "_caller", "_actionId"];
            if (_target getVariable ["LL_TaskDTigris_Triggered", false]) exitWith {};
            _target setVariable ["LL_TaskDTigris_Triggered", true];
            _target removeAction _actionId;
            
            _caller playMove "AinvPknlMstpSnonWnonDnon_medic_1";
            ["STR_LL_Task_03_Warning", [], 6, false] spawn LL_fnc_radioMessage;

            private _pos = getPosATL _target;
            private _charge = createVehicle ["DemoCharge_F", _pos, [], 0, "CAN_COLLIDE"];
            _charge setPosATL _pos;

            [_target, _charge] spawn {
                params ["_tgt", "_chg"];
                sleep 40;
                if (!isNull _chg) then { deleteVehicle _chg; };
                if (!isNull _tgt && alive _tgt) then {
                    private _p = getPos _tgt;
                    "Bo_GBU12_LGB" createVehicle _p;
                    _tgt setDamage 1;
                };
            };
        },
        nil, 6.0, true, true, "", "alive _target && _this distance _target < 6 && (_target getVariable ['LL_Task_Status', 'WAIT'] == 'WAIT')", 6
    ];
};

[_dca] call _addActionCode;

[_posVeh, _dca, _subVehicles] spawn {
    params ["_posVeh", "_dca", "_subVehicles"];
    private _delay = 1200 + random 600; 
    private _startTime = time;
    private _endTime = _startTime + _delay;

    private _lastMin = -1;
    while { time < _endTime && !(missionNamespace getVariable ["LL_TaskDTigris_Finished", false]) } do {
        private _timeLeft = _endTime - time;
        private _min = floor (_timeLeft / 60);
        
        if (_min != _lastMin) then {
            _lastMin = _min;
            private _timerStr = format ["ETA %1 min", _min];
            
            if (["task_tigris_vehicles"] call BIS_fnc_taskState != "SUCCEEDED" && ["task_tigris_vehicles"] call BIS_fnc_taskState != "FAILED") then {
                [_subVehicles, [localize "STR_LL_Task_08_MarkerVehicles", format ["%1 (%2)", localize "STR_LL_Task_08_MarkerVehicles", _timerStr], ""]] call BIS_fnc_taskSetDescription;
            };
        };
        sleep 5;
    };

    if (missionNamespace getVariable ["LL_TaskDTigris_Finished", false]) exitWith {};

    ["STR_LL_Task_08_Plane_Incoming"] spawn LL_fnc_radioMessage;

    private _angleIn = random 360;
    private _dist = 3000;
    private _spawnPos = _posVeh getPos [_dist, _angleIn];
    _spawnPos set [2, 1000];
    private _targetPos = _posVeh getPos [_dist, _angleIn + 180];
    _targetPos set [2, 300];

    private _grpPlane = createGroup [independent, true];
    private _plane = createVehicle ["CUP_I_C130J_Cargo_RACS", _spawnPos, [], 0, "FLY"];
    _plane setPosASL _spawnPos;
    _plane setDir (_spawnPos getDir _posVeh);
    _plane setVelocityModelSpace [0, 150, 0]; 
    _plane flyInHeight 300; 
    createVehicleCrew _plane;
    (crew _plane) joinSilent _grpPlane;

    private _wp1 = _grpPlane addWaypoint [_posVeh, 0];
    _wp1 setWaypointType "MOVE";
    _wp1 setWaypointSpeed "NORMAL";
    _wp1 setWaypointBehaviour "CARELESS"; 
    private _wp2 = _grpPlane addWaypoint [_targetPos, 0];
    _wp2 setWaypointType "MOVE";

    waitUntil { sleep 3; !alive _plane || _plane distance2D _targetPos < 500 || (missionNamespace getVariable ["LL_TaskDTigris_Finished", false]) };

    if (!alive _plane) then {
        ["STR_LL_Task_08_Plane_ShotDown"] spawn LL_fnc_radioMessage;
        ["task_tigris", "FAILED", true] call BIS_fnc_taskSetState;
        missionNamespace setVariable ["LL_TaskDTigris_Finished", true];
    } else {
        { deleteVehicle _x; } forEach (crew _plane);
        deleteVehicle _plane;
    };
    deleteGroup _grpPlane;
};

[_dca, _subVehicles, _enemies, _groups] spawn {
    params ["_dca", "_subVehicles", "_enemies", "_groups"];

    waitUntil { sleep 2; !alive _dca || (missionNamespace getVariable ["LL_TaskDTigris_Finished", false]) };

    if (!alive _dca && !(missionNamespace getVariable ["LL_TaskDTigris_Finished", false])) then {
        missionNamespace setVariable ["LL_Heli_Jammed", false];
        [_subVehicles, "SUCCEEDED", true] call BIS_fnc_taskSetState;
        ["task_tigris", "SUCCEEDED", true] call BIS_fnc_taskSetState;
        missionNamespace setVariable ["LL_TaskDTigris_Finished", true];
        
        ["STR_LL_Heli_Action_Unjammed"] spawn LL_fnc_radioMessage;
        sleep 5;
        ["STR_LL_Task_08_Plane_Safe"] spawn LL_fnc_radioMessage;
    };

    if (["task_tigris"] call BIS_fnc_taskState == "FAILED") then {
        if (!isNull _dca && alive _dca) then {
            { unassignVehicle _x; moveOut _x; } forEach (crew _dca);
        };
        [_dca] spawn {
            params ["_dca"];
            sleep 20;
            if (!isNull _dca) then {
                private _pos = getPosATL _dca;
                [_pos, 15, 5, [0.2, 0.2, 0.2, 0.8]] spawn LL_fnc_taskD_tigris_smokeRing;
                { deleteVehicle _x; } forEach (crew _dca);
                deleteVehicle _dca;
            };
        };
    };

    private _allEnemies = [];
    { if (!isNull _x && alive _x) then { _allEnemies pushBack _x; }; } forEach _enemies;
    if (!isNull _dca) then {
        { if (!isNull _x && alive _x && !(_x in _allEnemies)) then { _allEnemies pushBack _x; }; } forEach (crew _dca);
    };

    [_allEnemies] spawn LL_fnc_taskCleanup;
    missionNamespace setVariable ["LL_Heli_Jammed", false];
};
