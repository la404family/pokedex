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

// 4. Collecte et invulnérabilité des 6 unités de l'escouade
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
} forEach _allUnits;

// 5. Création de l'hélicoptère en vol
private _startDir = random 360;
private _startPos = _destPos getPos [1600, _startDir];
_startPos set [2, 120];

private _heli = createVehicle ["CUP_I_UH60L_FFV_RACS", _startPos, [], 0, "FLY"];
_heli setPosATL _startPos;
_heli setDir (_heli getDir _destPos);

private _cruiseAltASL = (_lzASL select 2) + 120;
_heli flyInHeightASL [_cruiseAltASL, _cruiseAltASL, _cruiseAltASL];
_heli flyInHeight 120;
_heli allowDamage false;

createVehicleCrew _heli;
private _crew = crew _heli;
{ _x allowDamage false; } forEach _crew;

private _grpHeli = group driver _heli;
_grpHeli setBehaviour "CARELESS";
_grpHeli setCombatMode "BLUE";

// Embarquement des 6 unités dans l'hélicoptère
{
    unassignVehicle _x;
    _x moveInCargo _heli;
    if (vehicle _x != _heli) then { _x moveInAny _heli; };
} forEach _allUnits;

_heli doMove _destPos;
_heli limitSpeed 250;


// 6. Post-processing cinématique net et soigné
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

// Plan 2 : Pivot fluide et traveling vers l'hélicoptère
_cam camSetTarget _heli;
_cam camSetFov 0.55;
_cam camCommit 5.5;
sleep 5.5;

private _camPosNow = getPosATL _cam;
private _heliPos = getPosATL _heli;
private _advTargetPos = [
    (_camPosNow select 0) + ((_heliPos select 0) - (_camPosNow select 0)) * 0.75,
    (_camPosNow select 1) + ((_heliPos select 1) - (_camPosNow select 1)) * 0.75,
    ((_camPosNow select 2) max (_heliPos select 2)) + 150
];

_cam camSetPos _advTargetPos;
_cam camSetTarget _heli;
_cam camSetFov 0.50;
_cam camCommit 3.0;
sleep 3.0;

titleText ["", "PLAIN", 1.0];
sleep 1.0;

cutText ["", "BLACK OUT", 0.7];
sleep 0.7;
1 fadeSound 0.3;

// Affichage style téléscripteur date & heure
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

// 8. Plan 3 : Tourbillon fluide EachFrame en coordonnées ASL (aucun tremblement)
private _orbStartTime = time;
private _orbDuration = 22;

missionNamespace setVariable ["LL_cam_obj", _cam];
missionNamespace setVariable ["LL_cam_target", _heli];
missionNamespace setVariable ["LL_cam_t0", _orbStartTime];
missionNamespace setVariable ["LL_cam_dur", _orbDuration];

private _ehOrbit = addMissionEventHandler ["EachFrame", {
    private _cam = missionNamespace getVariable ["LL_cam_obj", objNull];
    private _heli = missionNamespace getVariable ["LL_cam_target", objNull];
    if (isNull _cam || isNull _heli) exitWith {};

    private _t0 = missionNamespace getVariable ["LL_cam_t0", time];
    private _dur = missionNamespace getVariable ["LL_cam_dur", 22];
    private _prog = ((time - _t0) / _dur) min 1;
    private _smooth = _prog * _prog * _prog * (_prog * (_prog * 6 - 15) + 10);

    private _angle = -90 + (_smooth * 160);
    private _distance = 35 - (_smooth * 13);
    private _fov = 0.80 - (_smooth * 0.15);

    private _hASL = getPosASLVisual _heli;
    private _hDir = getDirVisual _heli;
    private _finalAngle = _hDir + _angle;

    private _camASL = [
        (_hASL select 0) + (sin _finalAngle * _distance),
        (_hASL select 1) + (cos _finalAngle * _distance),
        (_hASL select 2) + 6
    ];

    private _camAGL = ASLToAGL _camASL;
    _cam camSetPos _camAGL;
    _cam camSetTarget _heli;
    _cam camSetFov _fov;
    _cam camCommit 0;
}];

cutText ["", "BLACK IN", 1.0];
1 fadeSound 1;

sleep _orbDuration;

removeMissionEventHandler ["EachFrame", _ehOrbit];

// 9. Plan 4 : Caméra LZ et approche finale de l'hélicoptère
cutText ["", "BLACK OUT", 0.6];
sleep 0.6;

private _camLZPos = [
    (_destPos select 0) + 30,
    (_destPos select 1) - 80,
    (_destPos select 2) + 40
];
_cam camSetPos _camLZPos;
_cam camSetTarget _heli;
_cam camSetFov 0.50;
_cam camCommit 0;
waitUntil { camCommitted _cam };

_heli animateDoor ["doorLB", 1];
_heli animateDoor ["doorRB", 1];
_heli doMove _destPos;
_heli flyInHeight 15;

cutText ["", "BLACK IN", 0.8];

private _plan4Start = time;
missionNamespace setVariable ["LL_p4_cam_lz", _destPos];
missionNamespace setVariable ["LL_p4_start", _plan4Start];

private _ehApproach = addMissionEventHandler ["EachFrame", {
    private _cam = missionNamespace getVariable ["LL_cam_obj", objNull];
    private _heli = missionNamespace getVariable ["LL_cam_target", objNull];
    if (isNull _cam || isNull _heli) exitWith {};

    private _lz = missionNamespace getVariable ["LL_p4_cam_lz", [0,0,0]];
    private _p4Start = missionNamespace getVariable ["LL_p4_start", time];
    private _prog = ((time - _p4Start) / 14) min 1;
    private _smooth = _prog * _prog * _prog * (_prog * (_prog * 6 - 15) + 10);

    _cam camSetPos [
        (_lz select 0) + 30 + (sin (time * 0.6) * 6),
        (_lz select 1) - 80 + (cos (time * 0.6) * 6),
        (_lz select 2) + 40 - (_smooth * 28)
    ];
    _cam camSetTarget _heli;
    _cam camSetFov (0.50 + (_smooth * 0.10));
    _cam camCommit 0;
}];

// Attente de l'approche basse de l'hélicoptère (altitude < 5m ou max 12s)
private _maxWaitLanding = time + 12;
waitUntil {
    sleep 0.1;
    isTouchingGround _heli || { (getPosATL _heli select 2) < 5.0 } || { time > _maxWaitLanding }
};

removeMissionEventHandler ["EachFrame", _ehApproach];

// =========================================================================
// 10. FIN DU PLAN : ÉCRAN NOIR, NETTOYAGE ET REGROUPEMENT ABSOLU DES 6 PLAYERS
// =========================================================================
cutText ["", "BLACK OUT", 0.6];
sleep 0.6;

// 1. D'ABORD forcer la sortie de tout le monde
for "_i" from 0 to 5 do {
    private _u = missionNamespace getVariable [format ["player_%1", _i], objNull];
    if (isNull _u) then { _u = missionNamespace getVariable [format ["player_0%1", _i], objNull]; };
    if (!isNull _u) then {
        unassignVehicle _u;
        moveOut _u;
    };
};

// Pause indispensable pendant le noir : laisser le moteur Arma 3 libérer les sièges passagers
sleep 0.3;

// 2. Suppression de l'hélicoptère et de son équipage (maintenant 100% vide)
{ deleteVehicle _x; } forEach _crew;
deleteVehicle _heli;

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
