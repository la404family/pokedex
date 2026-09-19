params [["_mode", "init", [""]], ["_args", [], [[]]]];

if (!isServer) exitWith {};

if (_mode == "init") exitWith {
    private _heliports = allMissionObjects "HeliH";
    { _heliports pushBackUnique _x; } forEach (allMissionObjects "Land_HelipadEmpty_F");
    { _heliports pushBackUnique _x; } forEach (allMissionObjects "HeliHSquare_F");
    private _allLogics = _heliports;

    if (count _allLogics < 1) exitWith {
        missionNamespace setVariable ["LL_g_taskInProgress", false, true];
    };

    private _numTrucks = 2 + floor(random 2); 
    private _selectedLogics = [];
    private _alivePlayers = allPlayers select { alive _x };
    private _logicsPool = _allLogics call BIS_fnc_arrayShuffle;
    private _minDistPlayers = 400;
    private _maxDist = 450;

    while { count _selectedLogics < _numTrucks && _maxDist <= 15000 } do {
        _selectedLogics = [];
        {
            private _candidate = _x;
            private _candidatePos = getPosASL _candidate;
            private _valid = true;
            { private _d = _x distance2D _candidatePos; if (_d < _minDistPlayers || _d > _maxDist) exitWith { _valid = false; }; } forEach _alivePlayers;
            { if (_x distance2D _candidatePos < 250) exitWith { _valid = false; }; } forEach _selectedLogics;
            if (_valid) then { _selectedLogics pushBack _candidate; };
            if (count _selectedLogics == _numTrucks) exitWith {};
        } forEach _logicsPool;

        if (count _selectedLogics < _numTrucks) then { _maxDist = _maxDist + 50; };
    };

    if (count _selectedLogics < 1) exitWith {
        [[], "LL_fnc_task04"] spawn { sleep 15; ["init"] spawn LL_fnc_task04; };
    };

    missionNamespace setVariable ["LL_Task04_RemainingTrucks", [], true];
    missionNamespace setVariable ["LL_Task04_AllUnits", [], true];
    missionNamespace setVariable ["LL_Task04_Failed", false, true];

    private _allTrucks = [];
    private _allUnits = [];

    {
        private _selectedLogic = _x;
        private _spawnPos = getPosASL _selectedLogic;
        _spawnPos set [2, (_spawnPos select 2) + 0.2];

        private _numPatrols = 4 + floor (random 3);
        private _step = (475 - 15) / (_numPatrols - 1 max 1);

        for "_p" from 0 to (_numPatrols - 1) do {
            private _radius = round (15 + (_p * _step) + (random 20 - 10)) max 15 min 475;
            private _grp = createGroup [east, true];
            _grp setBehaviour "SAFE";
            _grp setCombatMode "RED";

            private _numGuards = 2 + floor (random 3);
            for "_g" from 1 to _numGuards do {
                sleep 1.5;
                private _guardClass = "O_Soldier_F";
                private _guard = _grp createUnit [_guardClass, _spawnPos, [], 0, "NONE"];
                _guard setPosASL _spawnPos;
                _guard allowDamage false;
                [_guard] spawn { sleep 3; (_this select 0) allowDamage true; };
                [_guard] call TUE_fnc_applyEnemyEquipment;
                _allUnits pushBack _guard;
            };

            [_grp, _spawnPos, _radius] call BIS_fnc_taskPatrol;
        };

        sleep 1.5;
        private _truckClasses = ["O_Truck_02_fuel_F", "O_Truck_03_fuel_F", "I_Truck_02_fuel_F"];
        private _truck = createVehicle [selectRandom _truckClasses, _spawnPos, [], 0, "CAN_COLLIDE"];
        _truck setPosASL _spawnPos;
        _truck setDir (random 360);

        _truck setFuel 0;

        clearWeaponCargoGlobal _truck;
        clearItemCargoGlobal _truck;
        clearMagazineCargoGlobal _truck;
        clearBackpackCargoGlobal _truck;

        _allTrucks pushBack _truck;
        _allUnits pushBack _truck;

        _truck addEventHandler ["HandleDamage", {
            params ["_unit", "_selection", "_damage", "_source", "_projectile", "_hitPartIndex", "_instigator", "_hitPoint"];
            if (!alive _unit) exitWith { 0 };
            if (_unit getVariable ["LL_Task04_IsExploding", false]) exitWith { _damage };

            private _oldDmg = if (_selection != "") then { _unit getHit _selection } else { damage _unit };
            if (isNil "_oldDmg") then { _oldDmg = 0; };

            private _delta = (_damage - _oldDmg) max 0;
            if (_delta > 0) then {
                private _clampedDelta = _delta min 0.15;
                private _cumul = (_unit getVariable ["LL_Truck_AccumDamage", 0]) + (_clampedDelta * 2.5);
                _unit setVariable ["LL_Truck_AccumDamage", _cumul, true];

                if (_cumul >= 0.05 && { (_unit getVariable ["LL_Toxic_Level", 0]) < 1 }) then {
                    _unit setVariable ["LL_Toxic_Level", 1, true];

                    [[_unit], {
                        params ["_truck"];
                        if (!hasInterface || isNull _truck) exitWith {};

                        private _emitter = "#particlesource" createVehicleLocal (getPos _truck);
                        _emitter attachTo [_truck, [0, -1.5, 0.5]];

                        _emitter setParticleCircle [0.2, [0.2, 0.2, 0.1]];
                        _emitter setParticleRandom [0.5, [0.3, 0.3, 0.2], [0.3, 0.3, 0.2], 0, 0.2, [0, 0, 0, 0.05], 0, 0];
                        _emitter setParticleParams [
                            ["\A3\data_f\ParticleEffects\Universal\Universal", 16, 7, 48, 1], "", "Billboard", 1, 6,
                            [0, 0, 0], [0, 0, 0.8], 0, 1.28, 1, 0.05, [0.8, 2.5, 4.5],
                            [[0.9, 0.85, 0.1, 0.5], [0.8, 0.75, 0.08, 0.25], [0.6, 0.55, 0.05, 0]], [0.125], 1, 0, "", "", _truck
                        ];
                        _emitter setDropInterval 0.03;

                        while { alive _truck && !isNull _emitter } do {
                            private _lvl = _truck getVariable ["LL_Toxic_Level", 1];
                            if (_lvl >= 2) then {
                                _emitter setDropInterval 0.015;
                                _emitter setParticleParams [
                                    ["\A3\data_f\ParticleEffects\Universal\Universal", 16, 7, 48, 1], "", "Billboard", 1, 7,
                                    [0, 0, 0], [0, 0, 1.2], 0, 1.28, 1, 0.05, [1.5, 4.0, 7.0],
                                    [[0.92, 0.88, 0.1, 0.7], [0.82, 0.75, 0.08, 0.45], [0.6, 0.55, 0.05, 0]], [0.125], 1, 0, "", "", _truck
                                ];
                            };
                            sleep 1;
                        };

                        deleteVehicle _emitter;
                    }] remoteExec ["spawn", 0, _unit];

                    [_unit] spawn {
                        params ["_truck"];
                        while { alive _truck } do {
                            private _lvl = _truck getVariable ["LL_Toxic_Level", 0];
                            if (_lvl >= 1) then {
                                private _radius = if (_lvl >= 2) then { 14 } else { 8 };
                                private _dmg = if (_lvl >= 2) then { 0.03 } else { 0.015 };
                                {
                                    if (alive _x && _x distance2D _truck < _radius) then {
                                        _x setDamage ((damage _x) + _dmg);
                                        if (isPlayer _x) then {
                                            _x setFatigue 1;
                                            [2, 1, 15] remoteExec ["addCamShake", _x];
                                        };
                                    };
                                } forEach allUnits;
                            };
                            sleep 1;
                        };
                    };
                };

                if (_cumul >= 0.25 && { (_unit getVariable ["LL_Toxic_Level", 0]) < 2 }) then {
                    _unit setVariable ["LL_Toxic_Level", 2, true];
                };

                if (_cumul >= 0.65) then {
                    _unit setVariable ["LL_Task04_IsExploding", true, true];
                    _unit setDamage 1;
                };
            };

            if (_damage >= 0.89) then { _damage = 0.89; };

            _damage
        }];

        _truck setHitPointDamage ["HitEngine", 1];

        _truck addEventHandler ["Killed", {
            params ["_unit"];
            if (missionNamespace getVariable ["LL_Task04_Failed", false]) exitWith {};
            missionNamespace setVariable ["LL_Task04_Failed", true, true];

            ["task_04_convoy", "FAILED", true] call BIS_fnc_taskSetState;
            missionNamespace setVariable ["LL_g_taskInProgress", false, true];

            [] spawn {
                sleep 40;
                ["<t color='#ff0000' size='2'>ECHEC CRITIQUE</t><br/>Contamination chimique majeure.", "BLACK OUT", 5, true, true] remoteExec ["titleText", 0];
                sleep 5;
                ["LOSER", false] remoteExec ["BIS_fnc_endMission", 0];
            };

            private _emitter = _unit getVariable ["LL_Toxic_Smoke1", objNull];
            if (!isNull _emitter) then { deleteVehicle _emitter; };

            private _remaining = missionNamespace getVariable ["LL_Task04_RemainingTrucks", []];
            {
                private _mkr = _x getVariable ["LL_Task04_Marker", ""];
                if (_mkr != "") then { deleteMarker _mkr; };
            } forEach _remaining;

            {
                private _t = _x;
                if (!isNull _t && _t != _unit) then {
                    [_t] spawn {
                        params ["_t"];
                        waitUntil {
                            sleep 5;
                            isNull _t || !alive _t || ({ _x distance2D _t <= 800 } count (allPlayers select { alive _x })) == 0
                        };
                        if (!isNull _t) then {
                            private _em = _t getVariable ["LL_Toxic_Smoke1", objNull];
                            if (!isNull _em) then { deleteVehicle _em; };
                            deleteVehicle _t;
                        };
                    };
                };
            } forEach _remaining;

            private _posATL = getPosATL _unit;
            private _posASL = getPosASL _unit;

            "HelicopterExploBig" createVehicle _posATL;
            [_posATL, 110, 8, [0.9, 0.85, 0.1, 0.85]] remoteExec ["LL_fnc_createSmokeRing", 0];

            [_posASL] spawn {
                params ["_pos"];
                private _maxRadius = 110;
                private _duration = 8;
                private _startTime = time;
                private _damagedUnits = [];

                while { (time - _startTime) < _duration } do {
                    private _progress = (time - _startTime) / _duration;
                    private _currentRadius = _maxRadius * _progress;

                    {
                        if (alive _x && !(_x in _damagedUnits)) then {
                            private _dist = _x distance _pos;
                            if (_dist <= _currentRadius) then {
                                _damagedUnits pushBack _x;
                                
                                if (_dist <= 30) then {
                                    _x setDamage 1;
                                } else {
                                    if (_dist <= 80) then {
                                        private _dmg = 0.5 + ((80 - _dist) / 50) * 0.4;
                                        _x setDamage ((damage _x) + _dmg);
                                        
                                        if (_x isKindOf "Man") then {
                                            private _dir = _pos vectorFromTo (getPosASL _x);
                                            _dir set [2, 0.4];
                                            private _vel = velocity _x;
                                            _x setVelocity (_vel vectorAdd (_dir vectorMultiply 15));
                                        };
                                    } else {
                                        if (_dist <= 110) then {
                                            private _dmg = 0.1 + ((110 - _dist) / 30) * 0.2;
                                            _x setDamage ((damage _x) + _dmg);
                                        };
                                    };
                                };
                            };
                        };
                    } forEach (allUnits select { alive _x });

                    sleep 0.05;
                };
            };

            private _allUnits = missionNamespace getVariable ["LL_Task04_AllUnits", []];
            private _guards = _allUnits select { alive _x && _x isKindOf "Man" };
            [_guards] spawn LL_fnc_taskCleanup;
        }];

        private _idx = count _allTrucks;
        private _mkrName = format ["mkr_task04_truck_%1", _idx];
        createMarker [_mkrName, getPosASL _truck];
        _mkrName setMarkerType "mil_objective";
        _mkrName setMarkerColor "ColorOrange";
        _mkrName setMarkerText (format ["%1 (%2/%3)", localize "STR_LL_Task_04_MarkerMain", _idx, _numTrucks]);

        _truck setVariable ["LL_Task04_Marker", _mkrName, true];

        private _varName = format ["LL_Task04_Truck_%1_%2", _idx, round(random 100000)];
        _truck setVehicleVarName _varName;
        missionNamespace setVariable [_varName, _truck, true];

        [_truck, netId _truck, _varName] remoteExec ["LL_fnc_task04_addAction", 0, true];

    } forEach _selectedLogics;

    missionNamespace setVariable ["LL_Task04_RemainingTrucks", _allTrucks, true];
    missionNamespace setVariable ["LL_Task04_AllUnits", _allUnits, true];

    [
        independent,
        ["task_04_convoy"],
        [
            localize "STR_LL_Task_04_Desc",
            localize "STR_LL_Task_04_Title",
            ""
        ],
        objNull,
        "AUTOASSIGNED",
        5,
        true,
        "danger",
        false
    ] call BIS_fnc_taskCreate;

    [[], { player createDiaryRecord ["diary", [localize "STR_LL_Diary_Task04_Title", localize "STR_LL_Diary_Task04_Text"]]; }] remoteExec ["spawn", 0, true];
};

if (_mode == "extract") exitWith {
    _args params ["_truck", "_caller"];

    if (!alive _truck) exitWith {};

    private _spawnPosHeli = (getPosATL _truck) getPos [1500, random 360];
    if (_spawnPosHeli select 0 < 50 || { _spawnPosHeli select 0 > (worldSize - 50) || { _spawnPosHeli select 1 < 50 || { _spawnPosHeli select 1 > (worldSize - 50) } } }) then {
        _spawnPosHeli = [15, 15, 250];
    } else {
        _spawnPosHeli set [2, 250];
    };

    private _dropPos = _spawnPosHeli getPos [1500, random 360];
    if (_dropPos select 0 < 50 || { _dropPos select 0 > (worldSize - 50) || { _dropPos select 1 < 50 || { _dropPos select 1 > (worldSize - 50) } } }) then {
        _dropPos = [worldSize - 50, worldSize - 50, 150];
    } else {
        _dropPos set [2, 150];
    };

    [_truck, _dropPos] spawn LL_fnc_task04_heli;
};
