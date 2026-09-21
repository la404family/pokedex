if (!isServer) exitWith {};

private _fnSetState = {
    params ["_s"];
    missionNamespace setVariable ["LL_HELI_state", _s, true];
};

private _fnInitState = {

    ["IDLE"] call _fnSetState;
    missionNamespace setVariable ["LL_HELI_type",     "",      true];
    missionNamespace setVariable ["LL_HELI_priority", 0,       true];
    missionNamespace setVariable ["LL_HELI_caller",   objNull, true];
    missionNamespace setVariable ["LL_HELI_obj",      objNull, true];
    missionNamespace setVariable ["LL_HELI_cargo",    objNull, true];
    missionNamespace setVariable ["LL_HELI_group",    grpNull, true];
    missionNamespace setVariable ["LL_HELI_crew",     [],      true];
    missionNamespace setVariable ["LL_HELI_abort",    false,   false];
    missionNamespace setVariable ["LL_missionHelicopter", objNull, true];
    missionNamespace setVariable ["TAG_AirSupport_Active",  false, true];
};

private _fnAborted = {
    missionNamespace getVariable ["LL_HELI_abort", false]
};

private _fnGetSpawnPos = {
    params ["_targetPos", "_height"];

    private _alivePlayers = allPlayers select { alive _x };
    private _spawnRadius = 2500;
    private _foundPos = [];
    private _mapSize = worldSize;

    while { count _foundPos == 0 && _spawnRadius <= 8000 } do {
        private _attempts = 0;
        while { _attempts < 30 && count _foundPos == 0 } do {
            private _angle = random 360;
            private _testPos = _targetPos getPos [_spawnRadius, _angle];
            _testPos set [2, 350]; 

            if ((_testPos select 0) > 0 && (_testPos select 0) < _mapSize && (_testPos select 1) > 0 && (_testPos select 1) < _mapSize) then {
                private _tooClose = false;
                {
                    if (_x distance2D _testPos < 2000) exitWith { _tooClose = true; };
                } forEach _alivePlayers;

                if (!_tooClose) then { _foundPos = _testPos; };
            };
            _attempts = _attempts + 1;
        };
        if (count _foundPos == 0) then { _spawnRadius = _spawnRadius + 500; };
    };

    if (count _foundPos == 0) then {
        private _angle = random 360;
        _foundPos = _targetPos getPos [2500, _angle];
        _foundPos set [2, 350];
    };

    _foundPos
};

private _fnGetLZ = {

    params ["_caller", "_type"];
    private _lzPos = getPosATL _caller;
    if (_type in ["LIVRAISON", "VEHICULE", "DEBARQUEMENT", "EMBARQUEMENT"]) then {
        private _heliports = nearestObjects [_caller, ["Land_HelipadEmpty_F", "HeliHEmpty"], 3000];
        if (count _heliports > 0) then {
            private _ref     = getPosATL _caller;
            private _nearest = _heliports # 0;
            private _minD    = _nearest distance2D _ref;
            {
                private _d = _x distance2D _ref;
                if (_d < _minD) then { _minD = _d; _nearest = _x; };
            } forEach _heliports;
            _lzPos = getPos _nearest;
        } else {
        };
    };
    _lzPos
};

private _fnCreateMarker = {
    params ["_type", "_pos"];
    private _data = switch (_type) do {
        case "LIVRAISON":    { ["mil_box",     "ColorBlue",   localize "STR_TAG_Marker_Heli_Ammo"]    };
        case "VEHICULE":     { ["mil_box",     "ColorBlue",   localize "STR_TAG_Marker_Heli_Vehicle"] };
        case "DEBARQUEMENT": { ["mil_end",     "ColorGreen",  localize "STR_TAG_Marker_Heli_Debark"]  };
        case "EMBARQUEMENT": { ["mil_pickup",  "ColorYellow", localize "STR_TAG_Marker_Heli_Extract"] };
        case "CAS":          { ["mil_warning", "ColorRed",    localize "STR_TAG_Marker_Heli_CAS"]     };
        default              { ["mil_dot",     "ColorBlack",  ""]                                     };
    };
    private _name = format ["heli_%1_%2", _type, floor (random 100000)];
    private _mrk  = createMarker [_name, _pos];
    _mrk setMarkerType  (_data # 0);
    _mrk setMarkerColor (_data # 1);
    _mrk setMarkerText  (_data # 2);

    if (_type == "CAS") then {
        private _areaName = _name + "_area";
        private _mrkArea = createMarker [_areaName, _pos];
        _mrkArea setMarkerShape "ELLIPSE";

        _mrkArea setMarkerSize [200, 200];
        _mrkArea setMarkerColor "ColorRed";
        _mrkArea setMarkerAlpha 0.3;
        _mrkArea setMarkerBrush "SolidBorder";
    };

    _name
};

private _fnSpawnHeli = {

    params ["_spawnPos", "_targetPos", "_flyHeight"];
    ["SPAWNING"] call _fnSetState;

    private _heli  = objNull;
    private _tries = 0;
    while { isNull _heli && { _tries < 5 } } do {
        _tries = _tries + 1;
        _heli = createVehicle ["CUP_I_UH60L_FFV_RACS", _spawnPos, [], 0, "FLY"];
        if (!isNull _heli) then {
            _heli setPos      _spawnPos;
            _heli setDir      (_spawnPos getDir _targetPos);
            _heli flyInHeight _flyHeight;
            _heli allowDamage false;
            _heli setFuel 1;
        } else { sleep 1; };
    };

    if (isNull _heli) exitWith {
        []
    };

    createVehicleCrew _heli;
    sleep 0.3;
    _heli setVehicleAmmo 1;

    private _crew    = crew _heli;
    private _group   = group (_crew # 0);
    private _pilot   = driver _heli;
    private _copilot = _heli turretUnit [0];
    private _gunners = _crew select { _x != _pilot && { _x != _copilot } };

    _group setBehaviour  "CARELESS";
    _group setCombatMode "RED";
    _group setSpeedMode  "FULL";

    { _x disableAI "FSM"; _x allowDamage false; } forEach [_pilot, _copilot];

    {
        private _g = _x;
        _g allowDamage  false;
        _g allowFleeing 0;
        {
            _g setSkill [_x, 1.0];
        } forEach ["aimingAccuracy","aimingShake","aimingSpeed","spotDistance","spotTime","courage","commanding"];
    } forEach _gunners;

    missionNamespace setVariable ["LL_HELI_obj",   _heli,  true];
    missionNamespace setVariable ["LL_HELI_group",  _group, true];
    missionNamespace setVariable ["LL_HELI_crew",   _crew,  true];
    missionNamespace setVariable ["LL_missionHelicopter", _heli, true];
    missionNamespace setVariable ["TAG_AirSupport_Active", true, true];

    [_heli, _crew, _group]
};

private _fnApproach = {

    params ["_heli", "_group", "_targetPos", "_flyHeight"];
    ["APPROACHING"] call _fnSetState;

    _heli flyInHeight _flyHeight;
    _heli limitSpeed  200;

    while { count (waypoints _group) > 0 } do { deleteWaypoint [_group, 0]; };
    private _wp = _group addWaypoint [_targetPos, 0];
    _wp setWaypointType       "MOVE";
    _wp setWaypointBehaviour  "CARELESS";
    _wp setWaypointCombatMode "RED";
    _wp setWaypointSpeed      "FULL";
    _heli doMove _targetPos;

    private _timer = 0;
    private _abort = false;
    waitUntil {
        sleep 1; _timer = _timer + 1;
        _abort = call _fnAborted;
        (_heli distance2D _targetPos < 200) || _timer > 180 || !alive _heli || _abort
    };

    while { count (waypoints _group) > 0 } do { deleteWaypoint [_group, 0]; };

    if (!_abort && _timer <= 180 && alive _heli) then {
        _group setBehaviour  "CARELESS";
        _group setCombatMode "BLUE";
        _group setSpeedMode  "FULL";
    };
    _abort
};

private _fnRTB = {

    params [
        "_heli", "_group", "_crew", "_homeBase", "_flyHeight",
        ["_withCargo",        false],
        ["_applyCASCooldown", false]
    ];

    if (_withCargo) then { ["RTB_WITH_CARGO"] call _fnSetState; } else { ["RTB"] call _fnSetState; };

    missionNamespace setVariable ["TAG_AirSupport_Active", false, true];

    while { count (waypoints _group) > 0 } do { deleteWaypoint [_group, 0]; };

    if (alive _heli) then {
        _group setBehaviour "CARELESS";
        _group setCombatMode "BLUE";
        _heli flyInHeight _flyHeight;
        _heli limitSpeed  300;
        private _rtbDest = _homeBase;
        private _wpRTB = _group addWaypoint [_rtbDest, 0];
        _wpRTB setWaypointType       "MOVE";
        _wpRTB setWaypointBehaviour  "CARELESS";
        _wpRTB setWaypointCombatMode "BLUE";
        _wpRTB setWaypointSpeed      "FULL";
        _group setCurrentWaypoint _wpRTB;
        _heli doMove _rtbDest;

        private _rtbStart = time;
        waitUntil {
            sleep 5;
            private _playersSafe = ({ _x distance2D _heli < 1200 } count allPlayers) == 0;
            ((_heli distance2D _rtbDest < 100) && _playersSafe) || !alive _heli
        };

        while { count (waypoints _group) > 0 } do { deleteWaypoint [_group, 0]; };
    };

    if (_withCargo) then {
        private _cargo = missionNamespace getVariable ["LL_HELI_cargo", objNull];
        if (!isNull _cargo) then {
            { ropeDestroy _x; } forEach (ropes _heli);
            sleep 0.3;
            if (!isNull _cargo && { !isNull _cargo }) then { deleteVehicle _cargo; };
            missionNamespace setVariable ["LL_HELI_cargo", objNull, true];
        };
        ["STR_LL_Heli_Msg_CargoAborted"] call LL_fnc_radioMessage;
    };

    if (alive _heli) then {
        { deleteVehicle _x; } forEach (crew _heli);
        deleteVehicle _heli;
    };
    if (!isNull _group) then { deleteGroup _group; };

    if (_applyCASCooldown) then {
        missionNamespace setVariable ["TAG_CAS_Cooldown_Until", time + 300, true];
    };

};

private _fnExecCAS = {

    params ["_heli", "_group", "_caller", "_targetPos", "_loiterHeight", "_loiterRadius", "_loiterDuration"];
    ["CAS"] call _fnSetState;

    _heli flyInHeight    _loiterHeight;
    _heli flyInHeightASL [_loiterHeight, _loiterHeight, _loiterHeight];
    _heli limitSpeed 80;

    while { count (waypoints _group) > 0 } do { deleteWaypoint [_group, 0]; };
    private _wpCAS = _group addWaypoint [_targetPos, 0];
    _wpCAS setWaypointType         "LOITER";
    _wpCAS setWaypointLoiterType   "CIRCLE";
    _wpCAS setWaypointLoiterRadius _loiterRadius;
    _wpCAS setWaypointBehaviour    "CARELESS";
    _wpCAS setWaypointCombatMode   "RED";
    _wpCAS setWaypointSpeed        "LIMITED";
    _heli doMove _targetPos;

    waitUntil {
        sleep 1;
        !alive _heli || (_heli distance2D _targetPos < (_loiterRadius + 150)) || call _fnAborted
    };

    ["STR_LL_Heli_Msg_Active"] call LL_fnc_radioMessage;

    private _endTime    = time + _loiterDuration;
    private _lastReveal = 0;
    private _abort      = false;

    while { time < _endTime && { alive _heli } && { !_abort } } do {
        sleep 1;
        _abort = call _fnAborted;
        if (time - _lastReveal >= 5) then {
            _lastReveal = time;
            {
                if (side (group _x) == east) then { _group reveal [_x, 4]; };
            } forEach (_heli nearEntities [["Man","Car","Tank"], 800]);
        };
    };

    while { count (waypoints _group) > 0 } do { deleteWaypoint [_group, 0]; };
    _abort
};

private _fnExecDelivery = {

    params ["_heli", "_group", "_crew", "_caller", "_type", "_targetPos", "_hoverHeight", "_side"];
    ["DELIVERING"] call _fnSetState;

    if (_type == "VEHICULE") then { _hoverHeight = 10; };

    private _cargo = missionNamespace getVariable ["LL_HELI_cargo", objNull];
    if (isNull _cargo) then {
        private _cargoClass = if (_type == "VEHICULE") then { "CUP_I_LR_MG_RACS" } else { "B_supplyCrate_F" };
        _cargo = createVehicle [_cargoClass, [0,0,0], [], 0, "NONE"];
        _cargo setPos   (_heli modelToWorld [0,0,-15]);
        _cargo allowDamage false;
        private _origMass = getMass _cargo;
        _cargo setVariable ["LL_origMass", _origMass];
        _cargo setMass (if (_type == "LIVRAISON") then { 500 } else { 800 });
        _heli setSlingLoad _cargo;
        missionNamespace setVariable ["LL_HELI_cargo", _cargo, true];
    };

    private _origMass = _cargo getVariable ["LL_origMass", getMass _cargo];

    _heli flyInHeight _hoverHeight;
    _heli flyInHeightASL [_hoverHeight, _hoverHeight, _hoverHeight];

    while { count (waypoints _group) > 0 } do { deleteWaypoint [_group, 0]; };
    private _wp2 = _group addWaypoint [_targetPos, 0];
    _wp2 setWaypointType      "MOVE";
    _wp2 setWaypointBehaviour "CARELESS";
    _wp2 setWaypointSpeed     "FULL";
    _heli doMove _targetPos;

    private _apTimer = 0;
    private _abort   = false;
    waitUntil {
        sleep 0.5; _apTimer = _apTimer + 0.5;
        _abort = call _fnAborted;
        (_heli distance2D _targetPos < 5) || _apTimer > 30 || !alive _heli || !alive _cargo || _abort
    };
    while { count (waypoints _group) > 0 } do { deleteWaypoint [_group, 0]; };

    if (_abort) exitWith { true };

    if (!alive _heli || !alive _cargo) exitWith {
        if (!isNull _cargo && { !isNull _cargo }) then { deleteVehicle _cargo; };
        missionNamespace setVariable ["LL_HELI_cargo", objNull, true];
        false
    };

    if (_type in ["VEHICULE", "LIVRAISON"]) then {
        private _enemies = _targetPos nearEntities [["Man", "Car", "Tank"], 500] select { side _x == east };
        if (count _enemies > 0) then {
            _abort = true;
            ["STR_LL_Heli_Msg_LZ_Hot_Abort"] call LL_fnc_radioMessage;
        };
    };

    if (_abort) exitWith { true };

    doStop _heli;
    private _minH        = if (_type == "VEHICULE") then { 3 } else { 5 };
    private _cargoThresh = if (_type == "VEHICULE") then { 0.5 } else { 3 };
    private _heliThresh  = if (_type == "VEHICULE") then { 3 } else { 4 };
    private _descTimer   = 0;

    waitUntil {
        sleep 0.5; _descTimer = _descTimer + 0.5;
        _abort = call _fnAborted;
        if (_abort) exitWith { true };
        private _newH = (_hoverHeight - _descTimer) max _minH;
        _heli flyInHeight _newH;
        _heli flyInHeightASL [_newH, _newH, _newH];
        private _cargoH = getPosATL _cargo select 2;
        private _heliH  = getPosATL _heli  select 2;
        _cargoH < _cargoThresh || _heliH < _heliThresh || _descTimer > 30 || !alive _heli || !alive _cargo || _abort
    };

    if (_abort) exitWith { true };

    if (!alive _heli || !alive _cargo) exitWith {
        if (!isNull _cargo && { !isNull _cargo }) then { deleteVehicle _cargo; };
        missionNamespace setVariable ["LL_HELI_cargo", objNull, true];
        false
    };

    sleep 0.5;
    { ropeDestroy _x; } forEach (ropes _heli);
    _heli setSlingLoad objNull;
    sleep 0.5;
    _cargo setVelocity [0,0,0];
    _cargo setVectorUp [0,0,1];
    _cargo setMass     _origMass;
    _cargo allowDamage true;
    missionNamespace setVariable ["LL_HELI_cargo", objNull, true];

    if (_type == "LIVRAISON") then {
        ["STR_TAG_Msg_Ammo_Dropped"] call LL_fnc_radioMessage;
        [_cargo] remoteExec ["LL_fnc_addResupplyAction", 0, true];

        [_cargo] spawn {
            params ["_crate"];
            if (isNull _crate) exitWith {};
            private _smoke = createVehicle ["SmokeShellGreen", getPos _crate, [], 0, "CAN_COLLIDE"];
            private _dead = false;
            for "_i" from 1 to 59 do {
                sleep 10;
                if (!alive _crate) exitWith { _dead = true; };
            };
            if (_dead) exitWith {
                if (!isNull _smoke && { alive _smoke }) then { deleteVehicle _smoke; };
            };
            if (alive _crate) then {
                private _smks = [];
                for "_d" from 0 to 315 step 45 do {
                    _smks pushBack (createVehicle ["SmokeShell", (_crate getPos [2, _d]), [], 0, "CAN_COLLIDE"]);
                };
                sleep 10;
                if (alive _crate)                          then { deleteVehicle _crate; };
                if (!isNull _smoke && { alive _smoke })    then { deleteVehicle _smoke; };
                sleep 120;
                { if (!isNull _x && { alive _x }) then { deleteVehicle _x; }; } forEach _smks;
            };
        };
    } else {
        ["STR_TAG_Msg_Vehicle_Dropped"] call LL_fnc_radioMessage;

        missionNamespace setVariable ["vehicule_team", _cargo, true];
    };

    false  
};


private _fnExecExtract = {

    params ["_heli", "_group", "_crew", "_caller", "_targetPos", "_homeBase", "_flyHeight"];
    ["EXTRACTING"] call _fnSetState;

    private _hostaged = missionNamespace getVariable ["LL_Task02b_Hostage", objNull];
    private _isTask02bActive = !isNull _hostaged && { alive _hostaged } && { !(missionNamespace getVariable ["LL_Task02b_Freed_Done", false]) };
    if (_isTask02bActive) then {
        ["task_02b_informateur", _targetPos] call BIS_fnc_taskSetDestination;

        deleteMarker "LL_mkr_t02b_extraction"; 
        private _extMkr = createMarker ["LL_mkr_t02b_extraction", _targetPos];
        _extMkr setMarkerType "mil_pickup";
        _extMkr setMarkerColor "ColorYellow";
        _extMkr setMarkerText (localize "STR_TAG_Marker_Heli_Extract");
    };

    _heli flyInHeight 15;
    _heli flyInHeightASL [15, 15, 15];
    while { count (waypoints _group) > 0 } do { deleteWaypoint [_group, 0]; };
    private _wpEmb = _group addWaypoint [_targetPos, 0];
    _wpEmb setWaypointType       "MOVE";
    _wpEmb setWaypointBehaviour  "CARELESS";
    _wpEmb setWaypointCombatMode "BLUE";
    _wpEmb setWaypointSpeed      "FULL";
    _heli doMove _targetPos;

    private _posTimer = 0;
    waitUntil {
        sleep 0.5; _posTimer = _posTimer + 0.5;
        (_heli distance2D _targetPos < 5) || _posTimer > 30 || !alive _heli || call _fnAborted
    };
    if (!alive _heli || call _fnAborted) exitWith { false };
    while { count (waypoints _group) > 0 } do { deleteWaypoint [_group, 0]; };

    doStop _heli;
    _heli flyInHeight 15;

    private _descentTimer = 0;
    waitUntil {
        sleep 0.5; _descentTimer = _descentTimer + 0.5;
        private _newH = (15 - _descentTimer) max 3;
        _heli flyInHeight _newH;
        _heli flyInHeightASL [_newH, _newH, _newH];
        (getPosATL _heli select 2) <= 5 || _descentTimer > 30 || !alive _heli || call _fnAborted
    };
    if (!alive _heli || call _fnAborted) exitWith { false };

    while { count (waypoints _group) > 0 } do { deleteWaypoint [_group, 0]; };
    _heli flyInHeight 0;
    _heli land "LAND";
    private _landTimeout = time + 30;
    waitUntil { sleep 0.5; !alive _heli || isTouchingGround _heli || time > _landTimeout || call _fnAborted };
    if (call _fnAborted) exitWith { false };
    if (!isTouchingGround _heli && alive _heli) then {
        _heli setVelocity [0,0,0];
        _heli setPos [_targetPos # 0, _targetPos # 1, 0];
    };
    sleep 1;
    if (!alive _heli) exitWith { false };

    _heli setVehicleLock "UNLOCKED";
    _heli animateSource ["door_rear_source", 1];
    _heli animateDoor   ["door_rear_source", 1];
    ["STR_LL_Heli_Msg_Landed_Extract"] call LL_fnc_radioMessage;

    [_heli] call LL_fnc_extraction_secure;

    if (call _fnAborted) exitWith {
        false
    };

    if (!alive _heli) exitWith {
        false
    };

    _heli animateSource ["door_rear_source", 0];
    _heli animateDoor   ["door_rear_source", 0];
    _heli land "NONE";
    _heli setFuel 1;
    _heli engineOn true;
    sleep 3;
    _group setBehaviour "CARELESS";
    _group setCombatMode "BLUE";
    _group setSpeedMode  "FULL";
    ["STR_LL_Heli_Msg_Departing"] call LL_fnc_radioMessage;

    private _boardedPlayers = crew _heli select { isPlayer _x && { alive _x } };

    if (count _boardedPlayers > 0) then {

        _heli flyInHeight _flyHeight;
        
        // Prolongement du point de destination pour ne pas qu'il s'arrête
        private _farAway = _heli getPos [10000, _heli getDir _homeBase];
        private _wpVic = _group addWaypoint [_farAway, 0];
        _wpVic setWaypointType       "MOVE";
        _wpVic setWaypointBehaviour  "CARELESS";
        _wpVic setWaypointCombatMode "BLUE";
        _wpVic setWaypointSpeed      "FULL";
        _heli doMove _farAway;
        _heli lock 2;
        
        // Musique et attente finale
        { 0 fadeMusic 1; playMusic "Music_Track_02"; } remoteExec ["call", 0];
        sleep 75;
        
        if (alive _heli) then {
            ["MissionSuccess", true, true] call BIS_fnc_endMission;
        };
        true
    } else {

        _heli flyInHeight _flyHeight;
        _heli doMove _homeBase;
        _heli lock 2; 

        private _hostage2b = missionNamespace getVariable ["LL_Task02b_Hostage", objNull];
        private _hostage00 = missionNamespace getVariable ["LL_Task00_Hostage", objNull];
        private _hvt06     = missionNamespace getVariable ["LL_Task06_HVT", objNull];
        {
            private _h = _x;
            if (!isNull _h) then {
                [_h] spawn {
                    params ["_unit"];
                    sleep 15;
                    if (!isNull _unit) then { deleteVehicle _unit; };
                };
            };
        } forEach [_hostage2b, _hostage00, _hvt06];

        missionNamespace setVariable ["LL_Task00_Hostage", objNull, true];
        missionNamespace setVariable ["LL_Task06_HVT", objNull, true];
        missionNamespace setVariable ["LL_Task02b_Hostage", objNull, true];
        missionNamespace setVariable ["LL_g_taskInProgress", false, true];

        false
    };
};

call _fnInitState;
missionNamespace setVariable ["LL_HELI_pending", [], false];  

while { true } do {
    sleep 0.5;

    private _pending = missionNamespace getVariable ["LL_HELI_pending", []];
    if (count _pending > 0) then {

        _pending params ["_type", "_pos", "_caller", "_priority"];

        missionNamespace setVariable ["LL_HELI_pending", [], false];

        missionNamespace setVariable ["LL_HELI_type",     _type,     true];
        missionNamespace setVariable ["LL_HELI_priority", _priority, true];
        missionNamespace setVariable ["LL_HELI_caller",   _caller,   true];
        missionNamespace setVariable ["LL_HELI_abort",    false,     false];


        private _flyHeight      = 150;
        private _hoverHeight    = 15;
        private _loiterHeight   = 60;
        private _loiterRadius   = 250;
        private _loiterDuration = 180;

        if (count _pos < 3) then { _pos resize 3; };
        { if (isNil "_pos") exitWith {}; if (isNil { _pos # _forEachIndex }) then { _pos set [_forEachIndex, 0]; }; } forEach _pos;
        private _lzPos = [_caller, _type] call _fnGetLZ;
        if (_type == "CAS") then { _lzPos = if (count _pos >= 2 && { (_pos # 0) != 0 }) then { _pos } else { getPosATL _caller }; };

        private _spawnPos    = [_lzPos, _flyHeight] call _fnGetSpawnPos;
        private _homeBase    = +_spawnPos;
        private _spawnResult = [_spawnPos, _lzPos, _flyHeight] call _fnSpawnHeli;

        if (count _spawnResult == 0) then {
            private _errMsg = switch (_type) do {
                case "VEHICULE": { "STR_TAG_Msg_Vehicle_Error" };
                case "CAS":      { "STR_TAG_Msg_CAS_Error"     };
                default          { "STR_TAG_Msg_Ammo_Error"    };
            };
            [_errMsg] call LL_fnc_radioMessage;
            call _fnInitState;
        } else {
            _spawnResult params ["_heli", "_crew", "_group"];
            private _side = side _group;

            if (_type in ["LIVRAISON", "VEHICULE"]) then {
                private _cargoClass = if (_type == "VEHICULE") then { "CUP_I_LR_MG_RACS" } else { "B_supplyCrate_F" };
                private _cargo = createVehicle [_cargoClass, [0, 0, 1000], [], 0, "FLY"];
                _cargo setPos (_heli modelToWorld [0, 0, -15]);
                _cargo allowDamage false;
                private _origMass = getMass _cargo;
                _cargo setVariable ["LL_origMass", _origMass];
                _cargo setMass (if (_type == "LIVRAISON") then { 500 } else { 800 });
                _heli setSlingLoad _cargo;
                missionNamespace setVariable ["LL_HELI_cargo", _cargo, true];

                clearWeaponCargoGlobal   _cargo;
                clearMagazineCargoGlobal _cargo;
                clearItemCargoGlobal     _cargo;
                clearBackpackCargoGlobal _cargo;

                private _leader = missionNamespace getVariable ["player_0", objNull];
                if (isNull _leader) then { _leader = missionNamespace getVariable ["player_00", objNull]; };
                if (isNull _leader) then { _leader = player; };

                if (!isNull _leader) then {
                    private _uniqueMags = [];
                    {
                        if (alive _x) then {
                            if (primaryWeapon _x != "") then {
                                private _comp = [primaryWeapon _x] call BIS_fnc_compatibleMagazines;
                                if (count _comp > 0) then { _uniqueMags pushBackUnique (_comp select 0); };
                            };
                            if (secondaryWeapon _x != "") then {
                                private _comp = [secondaryWeapon _x] call BIS_fnc_compatibleMagazines;
                                if (count _comp > 0) then { _uniqueMags pushBackUnique (_comp select 0); };
                            };
                            if (handgunWeapon _x != "") then {
                                private _comp = [handgunWeapon _x] call BIS_fnc_compatibleMagazines;
                                if (count _comp > 0) then { _uniqueMags pushBackUnique (_comp select 0); };
                            };
                        };
                    } forEach (units group _leader);

                    private _magMultiplier = if (_type == "LIVRAISON") then { 15 } else { 3 };
                    {
                        _cargo addMagazineCargoGlobal [_x, _magMultiplier];
                    } forEach _uniqueMags;
                };
            };

            private _markerName = [_type, _lzPos] call _fnCreateMarker;

            private _aborted = [_heli, _group, _lzPos, _flyHeight] call _fnApproach;

            if (!alive _heli) then {

                deleteMarker _markerName; deleteMarker (_markerName + "_area");
                ["STR_LL_Heli_Msg_Killed"] call LL_fnc_radioMessage;
                private _c = missionNamespace getVariable ["LL_HELI_cargo", objNull];
                if (!isNull _c) then { deleteVehicle _c; };
                missionNamespace setVariable ["LL_HELI_cargo", objNull, true];
                if (!isNull _group) then { deleteGroup _group; };
                call _fnInitState;
            } else {
                if (_aborted) then {

                    deleteMarker _markerName; deleteMarker (_markerName + "_area");
                    [_heli, _group, _crew, _homeBase, _flyHeight, (_type in ["LIVRAISON", "VEHICULE"]), false] call _fnRTB;
                    call _fnInitState;
                } else {

                    private _victoryTriggered  = false;
                    private _deadDuringMission = false;

                    switch (_type) do {

                        case "CAS": {
                            private _casAborted = [
                                _heli, _group, _caller, _lzPos,
                                _loiterHeight, _loiterRadius, _loiterDuration
                            ] call _fnExecCAS;

                            deleteMarker _markerName; deleteMarker (_markerName + "_area");

                            if (!alive _heli) then {
                                _deadDuringMission = true;
                            } else {
                                if (!_casAborted) then {
                                    ["STR_TAG_Msg_CAS_RTB"] call LL_fnc_radioMessage;
                                };

                                [_heli, _group, _crew, _homeBase, _flyHeight, false, !_casAborted] call _fnRTB;
                            };
                        };

                        case "LIVRAISON";
                        case "VEHICULE": {
                            private _needCargoRTB = [
                                _heli, _group, _crew, _caller, _type,
                                _lzPos, _hoverHeight, _side
                            ] call _fnExecDelivery;

                            deleteMarker _markerName; deleteMarker (_markerName + "_area");

                            if (!alive _heli) then {
                                _deadDuringMission = true;
                            } else {
                                [_heli, _group, _crew, _homeBase, _flyHeight, _needCargoRTB, false] call _fnRTB;
                            };
                        };



                        case "EMBARQUEMENT": {
                            private _extractResult = [
                                _heli, _group, _crew, _caller,
                                _lzPos, _homeBase, _flyHeight
                            ] call _fnExecExtract;
                            _victoryTriggered = _extractResult;

                            deleteMarker _markerName; deleteMarker (_markerName + "_area");

                            if (!alive _heli) then {
                                _deadDuringMission = true;
                            } else {
                                if (!_victoryTriggered) then {
                                    [_heli, _group, _crew, _homeBase, _flyHeight, false, false] call _fnRTB;
                                };
                            };
                        };
                    };

                    if (_deadDuringMission) then {
                        ["STR_LL_Heli_Msg_Killed"] call LL_fnc_radioMessage;
                        if (!isNull _group) then { deleteGroup _group; };
                    };

                    if (!_victoryTriggered) then { call _fnInitState; };
                };
            };
        };
    };
};
