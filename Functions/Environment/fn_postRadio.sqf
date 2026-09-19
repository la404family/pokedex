/*
    Author: IA
    Description:
    Joue la musique "intro1HP.ogg" en boucle sur l'enceinte du poste de commandement.
    S'arrête automatiquement si l'enceinte est détruite ou supprimée (notamment lors de l'éloignement des joueurs).
    
    Arguments:
    0: OBJECT - L'enceinte (par défaut: post_speaker)
    1: NUMBER - Durée de la boucle en secondes (doit correspondre à la durée du fichier audio intro1HP.ogg)
    
    Exemple d'utilisation (dans initServer.sqf ou init.sqf) :
    [post_speaker, 159] call LL_fnc_postRadio;
*/

params [
    ["_speaker", post_speaker, [objNull]],
    ["_duration", 159, [0]] // Durée exacte : 2 minutes 39 secondes
];

if (isNull _speaker) exitWith {
    diag_log "LL_fnc_postRadio : Enceinte introuvable.";
};

    // Utilisation de say3D via remoteExec pour que tous les joueurs l'entendent.
    // L'avantage de say3D est que le son s'arrête instantanément si l'objet est supprimé.
    [_speaker, ["intro1HP", 40, 1]] remoteExec ["say3D", 0];
