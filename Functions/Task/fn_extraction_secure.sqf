params ["_heli"];

if (!isServer) exitWith {};
if (isNull _heli || !alive _heli) exitWith {};

_heli lock 0;
_heli lockCargo false;

// 1. Identifier l'escouade complète
private _allSquadUnits = [
    missionNamespace getVariable ["player_0", objNull],
    missionNamespace getVariable ["player_1", objNull],
    missionNamespace getVariable ["player_2", objNull],
    missionNamespace getVariable ["player_3", objNull],
    missionNamespace getVariable ["player_4", objNull],
    missionNamespace getVariable ["player_5", objNull]
] select { !isNull _x };

if (count _allSquadUnits == 0) then {
    _allSquadUnits = (allPlayers + playableUnits) select { !isNull _x };
};

// Récupérer le groupe d'origine et son camp
private _squadGroup = grpNull;
private _squadSide = independent;
{
    if (alive _x) exitWith { 
        _squadGroup = group _x; 
        _squadSide = side _squadGroup;
    };
} forEach _allSquadUnits;

private _individualGroups = [];
missionNamespace setVariable ["LL_Extraction_Boarded", false, true];
missionNamespace setVariable ["LL_Extraction_HeliObj", _heli, true];

// 2. Séparation tactique : Création d'un Waypoint GETIN robuste pour chaque IA
{
    private _u = _x;
    if (alive _u && !isPlayer _u) then {
        private _newGrp = createGroup [_squadSide, true];
        [_u] joinSilent _newGrp;
        _individualGroups pushBack _newGrp;

        _u setBehaviour "AWARE";
        _u setSpeedMode "FULL";
        _u allowDamage false; 
        
        _newGrp reveal [_heli, 4]; 

        unassignVehicle _u;
        _u assignAsCargo _heli;
        
        // Approche 2 : Utilisation d'un Waypoint natif (imparable dans Arma 3)
        private _wp = _newGrp addWaypoint [getPosATL _heli, 0];
        _wp setWaypointType "GETIN";
        _wp waypointAttachVehicle _heli;
        
        // Variables anti-blocage
        _u setVariable ["LL_lastPos", getPosATL _u];
        _u setVariable ["LL_stuckTime", 0];
    };
} forEach _allSquadUnits;

// 3. Boucle de vérification
private _allBoarded = false;

while { !_allBoarded && alive _heli } do {
    sleep 1;

    private _livingSquad = _allSquadUnits select { alive _x };
    
    // Sécurité Anti-Bug Intelligente
    {
        if (alive _x && !isPlayer _x && vehicle _x != _heli) then {
            private _lastPos = _x getVariable ["LL_lastPos", getPosATL _x];
            private _stuckTime = _x getVariable ["LL_stuckTime", 0];
            
            if (_lastPos distance2D (getPosATL _x) < 1.5) then {
                _stuckTime = _stuckTime + 1;
            } else {
                _stuckTime = 0; 
                _x setVariable ["LL_lastPos", getPosATL _x];
            };
            
            if (_stuckTime >= 10) then {
                _x moveInCargo _heli;
                if (vehicle _x != _heli) then { _x moveInAny _heli; };
                _x setVariable ["LL_stuckTime", 0];
                
                // Si elle est téléportée, on annule ses ordres pour éviter qu'elle bug et ressorte
                _x disableAI "MOVE";
                _x disableAI "PATH";
                while {count (waypoints (group _x)) > 0} do { deleteWaypoint [(group _x), 0] };
            } else {
                _x setVariable ["LL_stuckTime", _stuckTime];
            };
        };
    } forEach _allSquadUnits;

    // Est-ce que 100% des survivants sont à bord ?
    private _inCargoCount = { vehicle _x == _heli } count _livingSquad;
    if (_inCargoCount == count _livingSquad && count _livingSquad > 0) then {
        _allBoarded = true;
    };
};

if (!alive _heli) exitWith {};

missionNamespace setVariable ["LL_Extraction_Boarded", true, true];
missionNamespace setVariable ["LL_g_extractionStarted", true, true];

// --- CORRECTION DU BUG "JE RENTRE JE SORS" ---
// Il faut absolument verrouiller l'hélico et geler les IA *AVANT* de les remettre dans le groupe du joueur.
// Sinon, le moteur d'Arma les fait ressortir car elles veulent retourner en formation avec le joueur.

_heli lockCargo true;
_heli lock 2;

{
    if (alive _x && !isPlayer _x && vehicle _x == _heli) then {
        _x disableAI "MOVE";
        _x disableAI "PATH";
    };
} forEach _allSquadUnits;

// Maintenant qu'elles sont physiquement bloquées sur leur siège, on les remet dans le groupe
{
    if (alive _x && !isPlayer _x) then {
        [_x] joinSilent _squadGroup;
        _x allowDamage true; 
    };
} forEach _allSquadUnits;

{ if (!isNull _x) then { deleteGroup _x; }; } forEach _individualGroups;

// Succès des tâches
private _hostage = missionNamespace getVariable ["LL_Task00_Hostage", objNull];
if (!isNull _hostage && alive _hostage && !(missionNamespace getVariable ["LL_Task00_Failed", false])) then {
    ["task_00_exfiltration", "SUCCEEDED", true] call BIS_fnc_taskSetState;
};

private _hvt = missionNamespace getVariable ["LL_Task06_HVT", objNull];
if (!isNull _hvt && alive _hvt && !(missionNamespace getVariable ["LL_Task06_Failed", false])) then {
    ["task_06_hvt", "SUCCEEDED", true] call BIS_fnc_taskSetState;
};

{
    if (_x != driver _heli) then {
        _x setBehaviour "COMBAT";
        _x setCombatMode "RED";
        _x enableAI "AUTOTARGET";
        _x enableAI "TARGET";
        _x enableAI "WEAPONAIM";
    };
} forEach (crew _heli);
