/*
 * LL_fnc_switchToAI
 *
 * Description:
 *   Gère la mort du joueur en mode Solo exclusivement.
 *   Transfère instantanément le contrôle vers une IA de l'escouade si disponible.
 *   Déclenche l'échec de la mission si toute l'escouade est morte.
 *
 * Arguments:
 *   0: <OBJECT> L'unité morte du joueur
 */

params [
    ["_deadUnit", objNull, [objNull]]
];

private _group = group _deadUnit;

// Petite pause pour laisser l'animation de mort se jouer
sleep 3;

// Trouver toutes les IA vivantes du groupe (les coéquipiers de l'escouade)
private _livingAI = (units _group) select { alive _x && {!isPlayer _x} };

if (count _livingAI > 0) then {
    private _targetAI = selectRandom _livingAI;
    
    // Bascule immédiate vers la nouvelle unité
    selectPlayer _targetAI;
    
    // En Solo, le joueur redevient automatiquement et obligatoirement le chef de son escouade
    _group selectLeader _targetAI;
    
    // Comme le joueur "habite" un nouveau corps, on doit lui réattacher l'événement de mort
    player addEventHandler ["Killed", {
        params ["_unit"];
        [_unit] spawn LL_fnc_switchToAI;
    }];
    
    // Réappliquer le menu des Règles d'Engagement (ROE) pour le nouveau leader
    [_targetAI] call LL_fnc_addRoeActions;

} else {
    // S'il n'y a plus aucune IA vivante, c'est l'échec total de la mission
    ["MissionFailed", false] call BIS_fnc_endMission;
};
