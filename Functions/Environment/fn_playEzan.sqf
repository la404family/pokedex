params [["_manualObj", objNull, [objNull]], ["_customRange", 2000, [0]]];

// =========================================================================
// 1. Appel manuel sur un objet spécifique (ex: [_speaker] call LL_fnc_playEzan)
// =========================================================================
if (!isNull _manualObj) exitWith {
    if (hasInterface) then {
        _manualObj say3D ["ezan", _customRange, 1];
    } else {
        [_manualObj, ["ezan", _customRange, 1]] remoteExec ["say3D", 0];
    };
};

// Seul le serveur exécute la boucle d'ambiance globale
if (!isServer) exitWith {};

// =========================================================================
// 2. Paramètres acoustiques et de synchronisation
// =========================================================================
private _SOUND_RANGE     = 2000;
private _SOUND_RANGE_SQR = _SOUND_RANGE * _SOUND_RANGE; // 4 000 000 m²
private _CLUSTER_DIST    = 350;                          // Distance max pour fusionner des haut-parleurs proches
private _EZAN_DURATION   = 145;                          // Durée de la piste audio (142s + marge)

// Détecter tous les objets nommés ezan_00 à ezan_50 ou avec variableName débutant par ezan_
private _minarets = [];
for "_i" from 0 to 50 do {
    private _suffix = if (_i < 10) then {format ["0%1", _i]} else {str _i};
    {
        private _obj = missionNamespace getVariable [_x, objNull];
        if (!isNull _obj) then {
            _minarets pushBackUnique _obj;
        };
    } forEach [format ["ezan_%1", _suffix], format ["ezan_%1", _i]];
};

{
    private _var = vehicleVarName _x;
    if (_var != "" && { (toLowerANSI _var) find "ezan_" == 0 }) then {
        _minarets pushBackUnique _x;
    };
} forEach (allMissionObjects "All");

if (_minarets isEqualTo []) exitWith {
    diag_log "[LL_fnc_playEzan] Aucun objet minaret trouvé (ezan_00 … ezan_50). Cycle ezan désactivé.";
};

diag_log format ["[LL_fnc_playEzan] %1 haut-parleurs détectés sur la carte.", count _minarets];

// =========================================================================
// 3. Regroupement en clusters géographiques (Anti-cacophonie locale)
//    Deux haut-parleurs à moins de 350m (même village/mosquée) font partie
//    du même cluster. Un seul d'entre eux diffusera le son !
// =========================================================================
private _clusters = []; // Format: [_centerPos, _representativeSpeaker, [_allSpeakersInCluster]]

{
    private _speaker = _x;
    private _pos = getPosATL _speaker;
    private _foundIdx = _clusters findIf {
        ((_x select 0) distance2D _pos) < _CLUSTER_DIST
    };

    if (_foundIdx != -1) then {
        private _cluster = _clusters select _foundIdx;
        (_cluster select 2) pushBack _speaker;
    } else {
        _clusters pushBack [_pos, _speaker, [_speaker]];
    };
} forEach _minarets;

diag_log format ["[LL_fnc_playEzan] %1 clusters de diffusion formés (anti-cacophonie actif).", count _clusters];

// =========================================================================
// 4. Premier délai atmosphérique (entre 5 et 10 minutes après le lancement)
// =========================================================================
sleep (300 + random 300);

// =========================================================================
// 5. Boucle principale de diffusion de l'Ezan
// =========================================================================
while {true} do {
    // Vérifier si un Ezan est déjà en cours
    if !(missionNamespace getVariable ["LL_ezan_playing", false]) then {

        private _alivePlayers = allPlayers select { alive _x };

        if (_alivePlayers isNotEqualTo []) then {

            // Identifier les clusters qui ont au moins un joueur à portée d'écoute (< 2000m)
            private _activeSpeakersToPlay = [];

            {
                private _player = _x;
                private _playerPos = getPosATL _player;

                // Trouver tous les clusters à portée d'écoute de ce joueur
                private _audibleClusters = _clusters select {
                    ((_x select 0) distance2D _playerPos) < _SOUND_RANGE
                };

                // Trier par distance au joueur (du plus proche au plus éloigné)
                _audibleClusters = [_audibleClusters, [], { (_x select 0) distance2D _playerPos }, "ASCEND"] call BIS_fnc_sortBy;

                if (count _audibleClusters > 0) then {
                    // Haut-parleur principal pour ce joueur (le plus proche)
                    private _mainCluster = _audibleClusters select 0;
                    private _mainSpeaker = _mainCluster select 1;
                    
                    // Enregistrer pour diffusion immédiate (délai 0)
                    if (_activeSpeakersToPlay findIf { (_x select 0) == _mainSpeaker } == -1) then {
                        _activeSpeakersToPlay pushBack [_mainSpeaker, 0.0];
                    };

                    // Si un 2ème village/cluster distinct est audible (> 700m du premier et < 2000m du joueur) :
                    // Ajouter un léger décalage naturel (écho de la vallée de 2.2s à 3.4s)
                    if (count _audibleClusters > 1) then {
                        private _secondCluster = _audibleClusters select 1;
                        private _secondSpeaker = _secondCluster select 1;
                        private _distBetween = (_mainCluster select 0) distance2D (_secondCluster select 0);

                        if (_distBetween >= 700 && { _activeSpeakersToPlay findIf { (_x select 0) == _secondSpeaker } == -1 }) then {
                            _activeSpeakersToPlay pushBack [_secondSpeaker, (2.2 + random 1.2)];
                        };
                    };
                };
            } forEach _alivePlayers;

            // Déclencher la diffusion sur les haut-parleurs sélectionnés
            if (_activeSpeakersToPlay isNotEqualTo []) then {
                missionNamespace setVariable ["LL_ezan_playing", true, true];

                {
                    _x params ["_speaker", "_delay"];
                    [_speaker, _delay, _SOUND_RANGE] spawn {
                        params ["_speaker", "_delay", "_range"];
                        if (_delay > 0) then { sleep _delay; };
                        if (!isNull _speaker) then {
                            [_speaker, ["ezan", _range, 1]] remoteExec ["say3D", 0];
                        };
                    };
                } forEach _activeSpeakersToPlay;

                // Attendre la fin complète de la récitation avant de libérer le verrou
                sleep _EZAN_DURATION;
                missionNamespace setVariable ["LL_ezan_playing", false, true];
            };
        };
    };

    // Intervalle entre les prières : 20 à 30 minutes
    sleep (1200 + random 600);
};
