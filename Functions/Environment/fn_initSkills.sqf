[] spawn {
    while {true} do {
        if (hasInterface && {side player == independent}) then {
            player setFatigue 0;
            player setStamina 60; 
            player setCustomAimCoef 0.1; 
        };

        {
            if (local _x && {side _x == independent} && {alive _x} && {isNil "drone_0" || {vehicle _x != drone_0}}) then {
                _x setFatigue 0;
            };
        } forEach allUnits;

        sleep 45; 
    };
};

if (!isServer) exitWith {}; 

[] spawn {
    while {true} do {
        {
            private _unit = _x;

            if (alive _unit && {isNil "drone_0" || {vehicle _unit != drone_0}}) then {

                private _side = side _unit;

                if (_side == independent) then {
                    // Endurance et charge illimitées pour le joueur et les IA alliées (Independent)
                    if (isPlayer _unit) then {
                        _unit enableFatigue false;
                        _unit enableStamina false;
                        _unit setUnitTrait ["loadCoef", 0.1]; // Le poids de l'équipement est virtuellement divisé par 10
                        _unit setAnimSpeedCoef 1.15; // Vitesse d'animation et de course augmentée de 15%
                    } else {
                        // Pour les IA alliées indépendantes
                        _unit enableFatigue false;
                        _unit enableStamina false;
                        _unit setUnitTrait ["loadCoef", 0.1];
                        _unit setAnimSpeedCoef 1.15;
                    };

                    // Nos alliés (RACS)
                    if (str _unit == "player_5") then {
                        // Sniper = Qualité Excellente
                        _unit setSkill ["aimingAccuracy", 0.95 + random 0.05]; 
                        _unit setSkill ["aimingShake",    0.95 + random 0.05]; 
                        _unit setSkill ["aimingSpeed",    0.95 + random 0.05]; 
                        _unit setSkill ["spotDistance",   1.00]; 
                        _unit setSkill ["spotTime",       1.00]; 
                    } else {
                        // Autres = Qualité Bonne/Très Bonne
                        _unit setSkill ["aimingAccuracy", 0.80 + random 0.15]; 
                        _unit setSkill ["aimingShake",    0.80 + random 0.15]; 
                        _unit setSkill ["aimingSpeed",    0.80 + random 0.15]; 
                        _unit setSkill ["spotDistance",   0.90 + random 0.10]; 
                        _unit setSkill ["spotTime",       0.90 + random 0.10]; 
                    };
                    
                    // Commun aux indépendants : ne jamais fuir, bon commandement
                    _unit setSkill ["commanding",     1.00]; 
                    _unit setSkill ["courage",        1.00]; 
                    _unit setSkill ["general",        1.00];
                    _unit allowFleeing 0; 
                    _unit setSpeedMode "FULL";
                    
                } else {
                    // Les autres factions (BLUFOR, OPFOR, etc.) = Compétences médiocres (max 35%)
                    _unit setSkill ["aimingAccuracy", 0.10 + random 0.25]; 
                    _unit setSkill ["aimingShake",    0.10 + random 0.25]; 
                    _unit setSkill ["aimingSpeed",    0.15 + random 0.20]; 
                    _unit setSkill ["spotDistance",   0.20 + random 0.15]; 
                    _unit setSkill ["spotTime",       0.15 + random 0.20]; 
                    _unit setSkill ["commanding",     0.20 + random 0.15]; 
                    _unit setSkill ["courage",        1.00]; 
                    _unit setSkill ["general",        0.35];
                    _unit allowFleeing 0; 
                };
            };
        } forEach allUnits;

        sleep 45;
    };
};
