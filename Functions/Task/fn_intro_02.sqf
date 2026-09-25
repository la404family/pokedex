params [["_selectedLocationMarker", ""], ["_dropPosCenter", [0,0,0]], ["_selectedVehClass", "CUP_I_LR_Transport_RACS"]];

disableSerialization;

// 1. Écran noir immédiat
cutText ["", "BLACK FADED", 999];
0 fadeSound 0;
0 fadeMusic 0;
showCinemaBorder true;

// 2. Détermination de la LZ
private _lzRef = _dropPosCenter;
if (_lzRef isEqualTo [0,0,0]) then { _lzRef = getMarkerPos _selectedLocationMarker; };
if (_lzRef isEqualTo [0,0,0]) then { _lzRef = getMarkerPos "marker_0"; };

private _heliports = [];
for "_i" from 0 to 200 do {
    private _hp = objNull;
    {
        private _var = missionNamespace getVariable [_x, objNull];
        if (!isNull _var) exitWith { _hp = _var; };
    } forEach [
        format ["Heliport_%1", _i],
        format ["Heliport_0%1", _i],
        format ["Heliport_00%1", _i]
    ];
    if (!isNull _hp) then { _heliports pushBack _hp; };
};

if (count _heliports == 0) then {
    private _nearPads = nearestObjects [_lzRef, ["Helipad_Invisible_F", "Land_HelipadEmpty_F", "HeliH"], 500];
    if (count _nearPads > 0) then { _heliports = _nearPads; };
};

private _destPos = _lzRef;
if (count _heliports > 0) then {
    private _chosen = [_heliports, _lzRef] call BIS_fnc_nearestPosition;
    if (!isNull _chosen) then { _destPos = getPosATL _chosen; };
};
if (_destPos isEqualTo [0,0,0]) then { _destPos = getMarkerPos "marker_0"; };
private _lzASL = ATLToASL _destPos;

MISSION_intro_lz = _destPos;
publicVariable "MISSION_intro_lz";

// 3. Véhicule d'équipe au sol (Land Rover)
private _vehPos = _destPos getPos [18, 90];
_vehPos set [2, 0];
if (!isNil "vehicule_team" && {!isNull vehicule_team}) then { deleteVehicle vehicule_team; };
private _vehClass = missionNamespace getVariable ["MISSION_var_selected_vehicle_class", _selectedVehClass];
vehicule_team = createVehicle [_vehClass, _vehPos, [], 0, "NONE"];
vehicule_team setPosATL _vehPos;
vehicule_team setDir (random 360);
publicVariable "vehicule_team";

// Fumigène vert & Arsenal
private _smokePos = _destPos getPos [6, 45];
"SmokeShellGreen" createVehicle _smokePos;
[] spawn LL_fnc_spawnStartArsenal;

// 4. Collecte et invulnérabilité des 6 unités de l'escouade (RACS Indépendant)
private _allUnits = [];
for "_i" from 0 to 5 do {
    private _u = missionNamespace getVariable [format ["player_%1", _i], objNull];
    if (isNull _u) then {
        _u = missionNamespace getVariable [format ["player_0%1", _i], objNull];
    };
    if (!isNull _u) then { _allUnits pushBackUnique _u; };
};

if (count _allUnits < 6 && !isNull player) then {
    {
        if (alive _x) then { _allUnits pushBackUnique _x; };
    } forEach (units (group player) + playableUnits + switchableUnits);
};

// Invulnérabilité totale de toute l'escouade pendant toute la cinématique
{
    _x allowDamage false;
    _x setCaptive true;
} forEach _allUnits;

// 5. Création de l'avion C-130J en vol à altitude sécurisée anti-relief
private _startDir = random 360;
private _startPos = _destPos getPos [3600, _startDir];
private _planeCruiseASL = (_lzASL select 2) + 180;
_startPos set [2, 180];

private _plane = createVehicle ["CUP_I_C130J_RACS", _startPos, [], 0, "FLY"];
_plane setPosATL _startPos;
_plane setDir (_startPos getDir _destPos);
_plane flyInHeightASL [_planeCruiseASL, _planeCruiseASL, _planeCruiseASL];
_plane flyInHeight 180;
_plane allowDamage false;
_plane setVelocityModelSpace [0, 110, 0];

createVehicleCrew _plane;
private _crew = crew _plane;
{ _x allowDamage false; } forEach _crew;

private _grpPlane = group driver _plane;
_grpPlane setBehaviour "CARELESS";
_grpPlane setCombatMode "BLUE";
_grpPlane setSpeedMode "NORMAL";

// Embarquement des 6 unités dans le C-130
{
    unassignVehicle _x;
    _x moveInCargo _plane;
    if (vehicle _x != _plane) then { _x moveInAny _plane; };
} forEach _allUnits;

// Trajectoire de survol
private _flyOverPos = _destPos getPos [8000, _startDir + 180];
_flyOverPos set [2, 180];
_plane doMove _flyOverPos;
_plane flyInHeight 180;

// 6. Post-processing cinématique
private _ppColor = ppEffectCreate ["ColorCorrections", 1500];
_ppColor ppEffectEnable true;
_ppColor ppEffectAdjust [1, 0.95, 0.04, [0.15, 0.15, 0.2, 0.0], [0.88, 0.86, 0.9, 0.65], [0.1, 0.1, 0.15, 0]];
_ppColor ppEffectCommit 0;

private _ppGrain = ppEffectCreate ["FilmGrain", 2005];
_ppGrain ppEffectEnable true;
_ppGrain ppEffectAdjust [0.05, 0.8, 0.9, 0.05, 0.9, false];
_ppGrain ppEffectCommit 0;

// 7. Plan 1 : Caméra plongeante sur la LZ
private _highCamPos = [(_destPos select 0) - 50, (_destPos select 1) - 50, (_destPos select 2) + 120];
private _lowCamPos = [(_destPos select 0) - 20, (_destPos select 1) - 20, (_destPos select 2) + 40];

private _cam = "camera" camCreate _highCamPos;
_cam cameraEffect ["INTERNAL", "BACK"];
if ((getLighting select 1) < 25) then { camUseNVG true; };

_cam camSetPos _highCamPos;
_cam camSetTarget _destPos;
_cam camSetFov 0.60;
_cam camCommit 0;
waitUntil { camCommitted _cam };

playMusic "Music_Intro";
3 fadeMusic 1;
3 fadeSound 1;
cutText ["", "BLACK IN", 3.0];

_cam camSetPos _lowCamPos;
_cam camSetTarget _destPos;
_cam camSetFov 0.45;
_cam camCommit 8.5;

sleep 3;

titleText [
    format [
        "<t size='3.2' color='#ffffff' font='PuristaBold' shadow='2' align='center'>%1</t><br/>" +
        "<t size='1.5' color='#E5B729' font='PuristaSemiBold' align='center' letterSpacing='0.15'>%2</t><br/>" +
        "<t size='1.3' color='#ffffff' font='PuristaBold' shadow='2' align='center'><t color='#2ECC71'>R</t>OYAL <t color='#2ECC71'>A</t>RMY <t color='#2ECC71'>C</t>ORPS OF <t color='#2ECC71'>S</t>AHRANI</t>",
        "<t color='#12778A'>O</t>PERATION <t color='#12778A'>R</t>OYAL <t color='#12778A'>A</t>LLIANCE",
        localize "STR_LL_Intro_Presents"
    ],
    "PLAIN", 1, true, true
];

// Plan 2 : Pivot vers le C-130 en vol
_cam camSetTarget _plane;
_cam camSetFov 0.55;
_cam camCommit 5.5;
sleep 5.5;

private _camPosNow = getPosATL _cam;
private _planePos = getPosATL _plane;
private _advTargetPos = [
    (_camPosNow select 0) + ((_planePos select 0) - (_camPosNow select 0)) * 0.75,
    (_camPosNow select 1) + ((_planePos select 1) - (_camPosNow select 1)) * 0.75,
    ((_camPosNow select 2) max (_planePos select 2)) + 150
];
_cam camSetPos _advTargetPos;
_cam camSetTarget _plane;
_cam camSetFov 0.50;
_cam camCommit 3.0;
sleep 3.0;

titleText ["", "PLAIN", 1.0];
sleep 1.0;

cutText ["", "BLACK OUT", 0.7];
sleep 0.7;
1 fadeSound 0.3;

// Téléscripteur date & heure
private _p2h = date select 3;
private _p2m = date select 4;
private _p2time = format ["%1:%2",
    if (_p2h < 10) then {"0" + str _p2h} else {str _p2h},
    if (_p2m < 10) then {"0" + str _p2m} else {str _p2m}
];
private _p2chars1 = toArray (localize "STR_LL_Intro_Location");
private _p2chars2 = toArray (" - " + _p2time);
private _p2built = "";
{
    _p2built = _p2built + toString [_x];
    [format ["<t size='1.3' color='#ffffff' font='PuristaLight' align='center' shadow='2'>%1</t>", _p2built], -1, 0.35, 5, 0, 0, 793] spawn BIS_fnc_dynamicText;
    if (_x != 32) then { playSound "readoutClick"; };
    sleep 0.08;
} forEach _p2chars1;
{
    _p2built = _p2built + toString [_x];
    [format ["<t size='1.3' color='#ffffff' font='PuristaLight' align='center' shadow='2'>%1</t>", _p2built], -1, 0.35, 5, 0, 0, 793] spawn BIS_fnc_dynamicText;
    if (_x != 32) then { playSound "readoutClick"; };
    sleep 0.12;
} forEach _p2chars2;

sleep 1.8;
["", -1, 0.35, 0.8, 0, 0, 793] spawn BIS_fnc_dynamicText;
sleep 0.8;

// 8. Plan 3 : Caméra face à l'avant de l'avion et éjection en chute libre (HALO)
// Ouverture de la rampe arrière
_plane animateDoor ["ramp_bottom", 1];
_plane animateDoor ["ramp_top", 1];

private _p1Start = time;
private _p1Duration = 14;

missionNamespace setVariable ["LL_cam_obj", _cam];
missionNamespace setVariable ["LL_plane_obj", _plane];
missionNamespace setVariable ["LL_p1_start", _p1Start];
missionNamespace setVariable ["LL_p1_dur", _p1Duration];

private _ehPlaneFront = addMissionEventHandler ["EachFrame", {
    private _cam = missionNamespace getVariable ["LL_cam_obj", objNull];
    private _plane = missionNamespace getVariable ["LL_plane_obj", objNull];
    if (isNull _cam || isNull _plane) exitWith {};

    private _t0 = missionNamespace getVariable ["LL_p1_start", time];
    private _dur = missionNamespace getVariable ["LL_p1_dur", 14];
    private _prog = ((time - _t0) / _dur) min 1;
    private _smooth = _prog * _prog * _prog * (_prog * (_prog * 6 - 15) + 10);

    private _distY = 38 + (_smooth * 57);
    private _distX = 12 + (_smooth * 8);
    private _distZ = 2.5 + (_smooth * 4);

    private _camPosAGL = _plane modelToWorldVisual [_distX, _distY, _distZ];
    _cam camSetPos _camPosAGL;
    _cam camSetTarget _plane;
    _cam camSetFov (0.65 + (_smooth * 0.12));
    _cam camCommit 0;
}];

cutText ["", "BLACK IN", 1.0];
1 fadeSound 1;

sleep 1.5;

// Éjection séquentielle en chute libre (SANS parachute immédiat)
private _trackedUnit = objNull;

{
    if (alive _x) then {
        unassignVehicle _x;
        moveOut _x;

        private _jumpPos = _plane modelToWorld [0, -22, -3];
        _x setPosATL _jumpPos;
        _x setVelocity ((velocity _plane) vectorAdd [0, -6, -4]);
        _x switchMove "HaloFreeFall_non";

        if (_forEachIndex == 1 || isNull _trackedUnit) then {
            _trackedUnit = _x;
            missionNamespace setVariable ["LL_tracked_unit", _x];
        };

        // Chute libre pendant 2.5 secondes puis ouverture du parachute
        [_x] spawn {
            params ["_unit"];
            sleep 2.5;
            if (alive _unit && { vehicle _unit == _unit }) then {
                private _uPos = getPosATL _unit;
                private _chute = createVehicle ["NonSteerable_Parachute_F", _uPos, [], 0, "FLY"];
                _chute setPosATL _uPos;
                _chute setDir (getDir _unit);
                _chute allowDamage false;
                _unit moveInAny _chute;

                if (_unit == (missionNamespace getVariable ["LL_tracked_unit", objNull])) then {
                    missionNamespace setVariable ["LL_tracked_chute", _chute];
                };
            };
        };
    };
    sleep 1.0;
} forEach _allUnits;

private _remP1 = (_p1Start + _p1Duration) - time;
if (_remP1 > 0) then { sleep _remP1; };

removeMissionEventHandler ["EachFrame", _ehPlaneFront];

// 9. Plan 4 : Transition et suivi fluide d'un parachutiste en descente
cutText ["", "BLACK OUT", 0.5];
sleep 0.5;

private _targetToFollow = missionNamespace getVariable ["LL_tracked_chute", objNull];
if (isNull _targetToFollow) then {
    _targetToFollow = missionNamespace getVariable ["LL_tracked_unit", objNull];
};
if (isNull _targetToFollow) then {
    _targetToFollow = player;
};

private _p2Start = time;
private _p2Duration = 12;

missionNamespace setVariable ["LL_target_follow", _targetToFollow];
missionNamespace setVariable ["LL_p2_start", _p2Start];
missionNamespace setVariable ["LL_p2_dur", _p2Duration];

private _ehChuteTrack = addMissionEventHandler ["EachFrame", {
    private _cam = missionNamespace getVariable ["LL_cam_obj", objNull];
    private _target = missionNamespace getVariable ["LL_target_follow", objNull];
    if (isNull _cam || isNull _target) exitWith {};

    // Si la cible est dans un parachute, suivre le parachute
    private _chute = missionNamespace getVariable ["LL_tracked_chute", objNull];
    private _activeTarget = if (!isNull _chute) then { _chute } else {
        if (vehicle _target != _target) then { vehicle _target } else { _target }
    };

    private _t0 = missionNamespace getVariable ["LL_p2_start", time];
    private _dur = missionNamespace getVariable ["LL_p2_dur", 12];
    private _prog = ((time - _t0) / _dur) min 1;
    private _smooth = _prog * _prog * _prog * (_prog * (_prog * 6 - 15) + 10);

    private _tASL = getPosASLVisual _activeTarget;
    private _camASL = [
        (_tASL select 0) + 12 - (_smooth * 3),
        (_tASL select 1) - 15 - (_smooth * 4),
        (_tASL select 2) + 3.0 - (_smooth * 1)
    ];

    private _camAGL = ASLToAGL _camASL;
    _cam camSetPos _camAGL;
    _cam camSetTarget _activeTarget;
    _cam camSetFov (0.65 - (_smooth * 0.05));
    _cam camCommit 0;
}];

cutText ["", "BLACK IN", 0.8];
sleep _p2Duration;

removeMissionEventHandler ["EachFrame", _ehChuteTrack];

// =========================================================================
// 10. FIN DU PLAN : ÉCRAN NOIR, NETTOYAGE ET REGROUPEMENT ABSOLU DES 6 PLAYERS
// =========================================================================
cutText ["", "BLACK OUT", 0.6];
sleep 0.6;

// 1. D'ABORD forcer la sortie de tout le monde de tout parachute / véhicule
for "_i" from 0 to 5 do {
    private _u = missionNamespace getVariable [format ["player_%1", _i], objNull];
    if (isNull _u) then { _u = missionNamespace getVariable [format ["player_0%1", _i], objNull]; };
    if (!isNull _u) then {
        unassignVehicle _u;
        moveOut _u;
    };
};

// Pause indispensable pendant le noir : laisser le moteur Arma 3 détacher les unités des parachutes
sleep 0.3;

// 2. Suppression propre de l'avion et des parachutes vides
{ deleteVehicle _x; } forEach _crew;
deleteVehicle _plane;

{
    if (!isNull _x && { count (crew _x) == 0 }) then {
        deleteVehicle _x;
    };
} forEach (nearestObjects [_destPos, ["ParachuteBase", "NonSteerable_Parachute_F", "Steerable_Parachute_F"], 15000]);

// 3. Référence au sol : à côté du Land Rover
private _teamRef = if (!isNil "vehicule_team" && {!isNull vehicule_team}) then { getPosATL vehicule_team } else { _destPos };

// 4. Téléportation propre au sol de toute l'escouade
private _allSquad = [];
for "_i" from 0 to 5 do {
    private _u = missionNamespace getVariable [format ["player_%1", _i], objNull];
    if (isNull _u) then { _u = missionNamespace getVariable [format ["player_0%1", _i], objNull]; };
    if (!isNull _u) then {
        _allSquad pushBack _u;
        private _pos = _teamRef getPos [3.5 + (_i * 1.5), 20 + (_i * 55)];
        _pos set [2, 0];
        _u setPosATL _pos;
        _u setVelocity [0, 0, 0];
        _u switchMove "";
        _u setDir (_pos getDir _teamRef);
    };
};

// Pause pour confirmer le statut à pied de toutes les unités
sleep 0.2;

// 5. Regroupement inconditionnel de toute l'escouade sous le joueur
private _teammates = _allSquad - [player];
_teammates joinSilent (group player);
(group player) selectLeader player;

{
    _x doFollow player;
    _x setDamage 0;
    _x allowDamage true;
    _x setCaptive false;
    _x enableAI "ALL";
} forEach _allSquad;

sleep 0.5;

_cam cameraEffect ["TERMINATE", "BACK"];
camDestroy _cam;
camUseNVG false;
ppEffectDestroy _ppColor;
ppEffectDestroy _ppGrain;

player switchCamera "INTERNAL";
showCinemaBorder false;

if ((getLighting select 1) < 25) then {
    player action ["NVGoggles", player];
};

cutText ["", "BLACK IN", 2.5];
3 fadeSound 1;

[
    format [
        "<t size='1.0' color='#bbbbbb' font='PuristaLight' align='center'>%1</t>",
        localize "STR_LL_Intro_MissionStartSubtitle"
    ],
    -1, -1, 5, 1, 0, 793
] spawn BIS_fnc_dynamicText;

missionNamespace setVariable ["MISSION_intro_finished", true, true];

// =========================================================================
// 11. PASSAGE EN BASSE ALTITUDE (Ambiance post-intro)
// =========================================================================
[_destPos] spawn {
    params ["_destPos"];
    sleep 3; // Laisse le temps au joueur de s'orienter

    // Fait apparaître un C-130 à 3 km, se dirigeant droit sur les joueurs
    private _spawnDist = 3000;
    private _dirToPlayer = random 360; 
    private _spawnPos = _destPos getPos [_spawnDist, _dirToPlayer];
    _spawnPos set [2, 100]; 

    private _flybyPlane = createVehicle ["CUP_I_C130J_RACS", _spawnPos, [], 0, "FLY"];
    _flybyPlane setPosATL _spawnPos;
    _flybyPlane setDir (_spawnPos getDir _destPos);
    _flybyPlane setVelocityModelSpace [0, 130, 0];
    
    // Altitude très basse pour un passage impressionnant
    _flybyPlane flyInHeight 60; 
    _flybyPlane allowDamage false;
    
    createVehicleCrew _flybyPlane;
    private _flybyCrew = crew _flybyPlane;
    { _x allowDamage false; } forEach _flybyCrew;

    private _grp = group driver _flybyPlane;
    _grp setBehaviour "CARELESS";
    _grp setCombatMode "BLUE";
    _grp setSpeedMode "FULL";

    _flybyPlane doMove _destPos;

    // Attend que l'avion survole la zone
    waitUntil { sleep 0.5; (_flybyPlane distance2D _destPos) < 400 || !alive _flybyPlane };
    
    // Le fait remonter et partir au loin
    private _exitPos = _destPos getPos [8000, _spawnPos getDir _destPos];
    _exitPos set [2, 350];
    _flybyPlane doMove _exitPos;
    _flybyPlane flyInHeight 350;

    // Nettoyage une fois l'avion hors de vue (4 km)
    waitUntil { sleep 2; (_flybyPlane distance2D _destPos) > 4000 || !alive _flybyPlane };
    
    { deleteVehicle _x; } forEach _flybyCrew;
    deleteVehicle _flybyPlane;
};
