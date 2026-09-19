/*
    Auteur: Antigravity
    Description:
    Supprime tous les objets post_ et tous les éléments dans taskspace_00_00
    lorsqu'un joueur (Player_0 à Player_5) quitte la zone.
    Exécution silencieuse.
*/

if (!isServer) exitWith {};

[] spawn {
    // Attend qu'au moins un des joueurs (s'il est en vie) sorte de la zone taskspace_00_00
    waitUntil {
        sleep 2;
        private _players = [];
        {
            private _p = missionNamespace getVariable [_x, objNull];
            if (!isNull _p && {alive _p}) then {
                _players pushBack _p;
            };
        } forEach ["player_0", "player_1", "player_2", "player_3", "player_4", "player_5"];
        
        private _someoneLeft = false;
        {
            if (!(_x inArea "taskspace_00_00")) exitWith {
                _someoneLeft = true;
            };
        } forEach _players;
        
        _someoneLeft
    };

    // 1. Suppression des objets "post_" listés dans INFO_POST.md
    private _postVars = [
        "post_speaker", "post_desk_00",
        "post_lamp_00", "post_lamp_01", "post_lamp_02", "post_lamp_03", "post_lamp_04",
        "post_heli", "post_camera", "post_tableau",
        "post_flag_00", "post_flag_01", "post_AMF",
        "post_tree_00", "post_tree_01",
        "post_document_00", "post_document_01",
        "post_laptop_00", "post_laptop_01",
        "post_chair_00", "post_chair_01",
        "post_bottle_00", "post_bottle_01"
    ];

    {
        private _obj = missionNamespace getVariable [_x, objNull];
        if (!isNull _obj) then {
            deleteVehicle _obj;
        };
    } forEach _postVars;

    // 2. Suppression de tous les éléments de jeu restants dans "taskspace_00_00"
    private _center = markerPos "taskspace_00_00";
    private _size = markerSize "taskspace_00_00";
    private _radius = sqrt ((_size select 0)^2 + (_size select 1)^2);

    // On récupère tous les objets éditeur dans le rayon maximum
    private _objectsInZone = nearestObjects [_center, ["All"], _radius];

    {
        // On s'assure de ne pas supprimer les joueurs (au cas où d'autres y seraient encore)
        if (!isPlayer _x && !(_x in playableUnits)) then {
            if (_x inArea "taskspace_00_00") then {
                deleteVehicle _x;
            };
        };
    } forEach _objectsInZone;
};
