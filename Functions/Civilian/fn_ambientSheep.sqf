if (!isServer) exitWith {};

params [
    ["_centerPos", [0,0,0], [[]]],
    ["_count", 10, [0]]
];

if (_centerPos isEqualTo [0,0,0]) exitWith {};

private _bestFlockPos = [];
private _bestScore = 99999;

for "_attempt" from 1 to 80 do {
    private _candPos = _centerPos getPos [30 + random 120, random 360];
    
    if (!surfaceIsWater _candPos) then {
        private _nearLogics = nearestObjects [_candPos, ["Logic", "Land_HelipadEmpty_F"], 10];
        private _nearBuildings = nearestObjects [_candPos, ["House", "Building"], 6];
        
        private _score = (count _nearLogics * 100) + (count _nearBuildings * 10);
        
        if (_score < _bestScore) then {
            _bestScore = _score;
            _bestFlockPos = _candPos;
        };
        
        if (_score == 0) exitWith {};
    };
};

if (count _bestFlockPos == 0) then {
    _bestFlockPos = _centerPos getPos [40, random 360];
};

private _spawnedSheep = [];
private _globalSheep = missionNamespace getVariable ["MISSION_var_ambientSheep", []];
private _grp = createGroup [civilian, true];

for "_i" from 1 to _count do {
    private _pos = _bestFlockPos getPos [random 10, random 360];
    _pos set [2, 0];
    
    private _sheep = _grp createUnit ["Sheep_random_F", _pos, [], 0, "CAN_COLLIDE"];
    if (!isNull _sheep) then {
        _sheep setPosATL _pos;
        
        _sheep disableAI "TARGET";
        _sheep disableAI "AUTOTARGET";
        _sheep disableAI "MINEDETECTION";
        _sheep disableAI "SUPPRESSION";
        _sheep disableAI "COVER";
        _sheep disableAI "AUTOCOMBAT";
        
        _spawnedSheep pushBack _sheep;
        _globalSheep pushBack _sheep;
        
        [_sheep, _bestFlockPos] spawn {
            params ["_unit", "_flockCenter"];
            while { !isNull _unit && { alive _unit } } do {
                private _dest = _flockCenter getPos [random 20, random 360];
                _unit doMove _dest;
                sleep (15 + random 25);
            };
        };
    };
};

missionNamespace setVariable ["MISSION_var_ambientSheep", _globalSheep];

if (isNil "MISSION_var_sheepDespawnLoopStarted") then {
    MISSION_var_sheepDespawnLoopStarted = true;

    [] spawn {
        waitUntil {
            sleep 2;
            private _targetPos = missionNamespace getVariable ["MISSION_var_targetPos", [0,0,0]];
            !(_targetPos isEqualTo [0,0,0]) && { (player distance2D _targetPos) <= 800 }
        };

        while { true } do {
            sleep 120;
            private _allSheep = missionNamespace getVariable ["MISSION_var_ambientSheep", []];
            _allSheep = _allSheep select { !isNull _x && { alive _x } };

            private _remainingSheep = [];
            {
                if ((player distance2D _x) >= 1500) then {
                    deleteVehicle _x;
                } else {
                    _remainingSheep pushBack _x;
                };
            } forEach _allSheep;

            missionNamespace setVariable ["MISSION_var_ambientSheep", _remainingSheep];
        };
    };
};
