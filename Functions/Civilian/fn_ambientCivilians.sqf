/*
    LL_fnc_ambientCivilians
    Spawne des civils qui se déplacent de GameLogic en GameLogic avec comportement de fuite.
*/
if (!isServer) exitWith {};

params [
    ["_centerPos", [0,0,0], [[]]],
    ["_radius", 400, [0]],
    ["_maxCivs", 35, [0]],
    ["_globalNodes", [], [[]]]
];

if (_centerPos isEqualTo [0,0,0]) exitWith {};

// Récupérer les GameLogic locaux (pour le spawn initial)
private _nodes = nearestObjects [_centerPos, ["Logic", "Land_HelipadEmpty_F"], _radius];
if (count _nodes == 0) then {
    _nodes = nearestObjects [_centerPos, ["House", "Building"], _radius];
};

if (count _nodes == 0) exitWith {};

// Si aucun noeud global n'est fourni, on utilise les noeuds locaux
private _patrolNodes = if (count _globalNodes > 0) then { _globalNodes } else { _nodes };

private _spawnCount = (count _nodes) min _maxCivs;
private _spawnedCivs = [];
private _grp = createGroup [civilian, true];

for "_i" from 1 to _spawnCount do {
    private _node = selectRandom _nodes;
    private _pos = getPosATL _node;
    
    // Si c'est un bâtiment, on prend une position intérieure aléatoire, sinon la position du Logic
    if (_node isKindOf "House" || _node isKindOf "Building") then {
        private _bPosList = _node buildingPos -1;
        if (count _bPosList > 0) then { _pos = selectRandom _bPosList; };
    };
    
    // Spawn du civil
    private _civ = _grp createUnit ["C_man_1", _pos, [], 0, "NONE"];
    _civ setPosATL _pos;
    
    // Ratio de femmes
    private _isFemale = (random 1) < 0.10;
    [_civ, _isFemale, false] execVM "Functions\Civilian\fn_applyTakistaniIdentity.sqf";
    
    // Event Handler pour la peur
    _civ addEventHandler ["FiredNear", {
        params ["_unit", "_firer", "_distance", "_weapon", "_muzzle", "_mode", "_ammo", "_gunner"];
        if (_distance < 150) then {
            _unit setVariable ["LL_fleeTime", time + 60 + random 60];
        };
    }];
    
    // Désactiver temporairement les dégâts pour éviter les collisions au spawn
    _civ allowDamage false;
    [_civ] spawn { sleep 3; (_this select 0) allowDamage true; };
    
    _spawnedCivs pushBack _civ;
    sleep 0.2;
};

// Logique FSM pour chaque civil
{
    [_x, _patrolNodes] spawn {
        params ["_civ", "_patrolNodes"];
        
        while { alive _civ } do {
            // Nettoyage si le joueur s'éloigne (uniquement après s'être approché une première fois)
            if (!(_civ getVariable ["LL_hasBeenSeen", false])) then {
                if (player distance2D _civ < 800) then {
                    _civ setVariable ["LL_hasBeenSeen", true];
                };
            } else {
                if (player distance2D _civ > 1000) exitWith {
                    deleteVehicle _civ;
                };
            };
            
            // Si le civil a été supprimé par la condition ci-dessus
            if (!alive _civ) exitWith {};
            
            private _fleeTime = _civ getVariable ["LL_fleeTime", 0];
            private _isFleeing = time < _fleeTime;
            
            private _targetNode = selectRandom _patrolNodes;
            private _targetPos = getPosATL _targetNode;
            if (_targetNode isKindOf "House" || _targetNode isKindOf "Building") then {
                private _bPosList = _targetNode buildingPos -1;
                if (count _bPosList > 0) then { _targetPos = selectRandom _bPosList; };
            };
            
            if (_isFleeing) then {
                // Comportement de FUITE
                _civ setBehaviour "CARELESS";
                _civ setSpeedMode "FULL";
                _civ setUnitPos "UP";
                _civ doMove _targetPos;
                
                // On attend d'arriver ou fin de la fuite
                waitUntil {
                    sleep 1;
                    !alive _civ || {(_civ distance2D _targetPos) < 4} || {time > _civ getVariable ["LL_fleeTime", 0]}
                };
                
                if (alive _civ && time < _civ getVariable ["LL_fleeTime", 0]) then {
                    // Si arrivé et toujours effrayé : on se cache (les logics étant des maisons)
                    _civ setUnitPos "DOWN";
                    sleep (5 + random 15);
                };
            } else {
                // Comportement CALME
                _civ setBehaviour "SAFE";
                _civ setSpeedMode "LIMITED";
                _civ setUnitPos "UP";
                _civ doMove _targetPos;
                
                private _timeout = time + 120; // 2 min max pour atteindre le point
                waitUntil {
                    sleep 2;
                    !alive _civ || {(_civ distance2D _targetPos) < 4} || {time > _timeout} || {time < _civ getVariable ["LL_fleeTime", 0]}
                };
                
                if (alive _civ && time >= _civ getVariable ["LL_fleeTime", 0]) then {
                    // Pause ambiante
                    sleep (10 + random 40);
                };
            };
            
            sleep 1;
        };
    };
} forEach _spawnedCivs;
