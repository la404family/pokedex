params [
    ["_locMarker", "", [""]],
    ["_insertion", "", [""]],
    ["_tasks", [], [[]]]
];

if (!isServer) exitWith {};

// Lancement de la tâche C (Extraction en toute sécurité - Survie de l'équipe)
// Démarrée 5 secondes après la fin de l'intro
[_locMarker] spawn {
    params ["_locMarker"];
    waitUntil { sleep 1; missionNamespace getVariable ["MISSION_intro_finished", false] };
    sleep 5;
    [_locMarker] spawn LL_fnc_taskC;
};

// Lancement de la tâche A (Se rendre sur les lieux)
// Démarrée 15 secondes après la fin de l'intro
[_locMarker, _tasks] spawn {
    params ["_locMarker", "_tasks"];
    waitUntil { sleep 1; missionNamespace getVariable ["MISSION_intro_finished", false] };
    sleep 15;
    
    // Le tableau _tasks est transmis à TaskA, 
    // qui pourra elle-même lancer TaskB ou le gestionnaire des tâches optionnelles 
    // une fois que le joueur est arrivé sur les lieux.
    [_locMarker, _tasks] spawn LL_fnc_taskA;
};
