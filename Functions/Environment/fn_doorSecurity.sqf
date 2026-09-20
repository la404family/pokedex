if (!isServer) exitWith {};

[] spawn {
    private _OPEN_DIST      = 4.0;
    private _OPEN_DIST_SQR  = _OPEN_DIST * _OPEN_DIST;      // 16.0 m²
    private _CLOSE_DIST     = 5.5;
    private _CLOSE_DIST_SQR = _CLOSE_DIST * _CLOSE_DIST;    // 30.25 m²
    private _MIN_OPEN_TIME  = 4.0;                          // Minimum open duration (seconds)
    private _COOLDOWN       = 1.5;                          // Cooldown between transitions
    private _CHECK_FREQ     = 0.4;                          // Loop evaluation period

    // Helper to retrieve or cache doors for a building
    private _fnc_getBuildingDoors = {
        params ["_bldg"];

        private _cached = _bldg getVariable ["LL_doorData", nil];
        if (!isNil "_cached") exitWith { _cached };

        private _type = typeOf _bldg;
        private _cfg = configFile >> "CfgVehicles" >> _type;
        private _numDoors = getNumber (_cfg >> "numberOfDoors");

        private _doorList = [];
        private _foundNums = [];

        // Method 1: Config numberOfDoors
        if (_numDoors > 0) then {
            for "_i" from 1 to _numDoors do {
                private _doorNum = _i;
                private _anim = format ["Door_%1_rot", _doorNum];
                if (!(_anim in animationNames _bldg)) then {
                    _anim = format ["Door_%1", _doorNum];
                    if (!(_anim in animationNames _bldg)) then {
                        _anim = format ["door_%1", _doorNum];
                    };
                };

                // Find door 3D world position
                private _doorPos = [0, 0, 0];
                private _candidates = [
                    format ["Door_%1_trigger", _doorNum],
                    format ["door_%1_trigger", _doorNum],
                    format ["Door_%1", _doorNum],
                    format ["door_%1", _doorNum],
                    format ["Door_%1_axis", _doorNum],
                    format ["door_%1_axis", _doorNum],
                    format ["Door_%1_sound", _doorNum],
                    format ["door_%1_sound", _doorNum],
                    format ["Door_%1_handle", _doorNum],
                    _anim
                ];
                {
                    private _posM = _bldg selectionPosition _x;
                    if (_posM isNotEqualTo [0, 0, 0]) exitWith {
                        _doorPos = _bldg modelToWorld _posM;
                    };
                } forEach _candidates;

                if (_doorPos isNotEqualTo [0, 0, 0]) then {
                    private _initOpen = (_bldg animationPhase _anim) > 0.5;
                    // Format: [_doorNum, _anim, _doorPos, _isOpen, _lastActionTime, _openedAt, _openedByAI]
                    _doorList pushBack [_doorNum, _anim, _doorPos, _initOpen, 0, 0, false];
                    _foundNums pushBack _doorNum;
                };
            };
        };

        // Method 2: Inspect animationNames if numberOfDoors was 0 or incomplete
        if (count _doorList == 0) then {
            private _anims = (animationNames _bldg) select {
                private _low = toLowerANSI _x;
                (_low find "door" != -1) && (_low find "handle" == -1) && (_low find "sound" == -1)
            };

            {
                private _animName = _x;
                private _animLower = toLowerANSI _animName;
                private _doorNum = 1;
                private _startIdx = _animLower find "door";
                if (_startIdx != -1) then {
                    private _sub = _animLower select [_startIdx + 4];
                    private _digits = [];
                    {
                        if (_x in ["0","1","2","3","4","5","6","7","8","9"]) then {
                            _digits pushBack _x;
                        };
                    } forEach (_sub splitString "");
                    if (count _digits > 0) then {
                        _doorNum = parseNumber (_digits joinString "");
                    };
                };

                if (!(_doorNum in _foundNums)) then {
                    _foundNums pushBack _doorNum;

                    private _doorPos = [0, 0, 0];
                    private _candidates = [
                        format ["Door_%1_trigger", _doorNum],
                        format ["door_%1_trigger", _doorNum],
                        format ["Door_%1", _doorNum],
                        format ["door_%1", _doorNum],
                        format ["Door_%1_axis", _doorNum],
                        format ["door_%1_axis", _doorNum],
                        format ["Door_%1_sound", _doorNum],
                        format ["door_%1_sound", _doorNum],
                        format ["Door_%1_handle", _doorNum],
                        _animName
                    ];
                    {
                        private _posM = _bldg selectionPosition _x;
                        if (_posM isNotEqualTo [0, 0, 0]) exitWith {
                            _doorPos = _bldg modelToWorld _posM;
                        };
                    } forEach _candidates;

                    if (_doorPos isEqualTo [0, 0, 0]) then {
                        _doorPos = getPosATL _bldg;
                    };

                    private _initOpen = (_bldg animationPhase _animName) > 0.5;
                    _doorList pushBack [_doorNum, _animName, _doorPos, _initOpen, 0, 0, false];
                };
            } forEach _anims;
        };

        _bldg setVariable ["LL_doorData", _doorList];
        _doorList
    };

    while {true} do {
        sleep _CHECK_FREQ;

        // All active on-foot units
        private _allActiveUnits = allUnits select { alive _x && vehicle _x == _x };
        private _aiUnits = _allActiveUnits select { !isPlayer _x };

        if (_aiUnits isEqualTo []) then { continue; };

        // Collect buildings near AI units (max 15m search radius around each AI)
        private _nearBuildings = [];
        {
            private _pos = getPosATL _x;
            {
                _nearBuildings pushBackUnique _x;
            } forEach (nearestObjects [_pos, ["House", "Building"], 15]);
        } forEach _aiUnits;

        private _currentTime = time;

        {
            private _bldg = _x;
            private _doors = [_bldg] call _fnc_getBuildingDoors;

            if (_doors isNotEqualTo []) then {
                {
                    _x params [
                        "_doorNum",
                        "_anim",
                        "_doorPos",
                        "_isOpen",
                        "_lastActionTime",
                        "_openedAt",
                        "_openedByAI"
                    ];

                    // Sync state with manual player interaction if needed
                    private _currentPhase = _bldg animationPhase _anim;
                    if (!_isOpen && _currentPhase > 0.6) then {
                        _isOpen = true;
                        _x set [3, true];
                    };
                    if (_isOpen && _currentPhase < 0.1) then {
                        _isOpen = false;
                        _openedByAI = false;
                        _x set [3, false];
                        _x set [6, false];
                    };

                    // Check if any AI is within 4.0m of this specific door
                    private _aiNear = _aiUnits findIf { (_x distanceSqr _doorPos) < _OPEN_DIST_SQR } != -1;

                    if (_aiNear) then {
                        // If door is closed, open it
                        if (!_isOpen) then {
                            // Check if door is locked
                            private _lockVal = _bldg getVariable [format ["bis_disabled_Door_%1", _doorNum], 0];
                            private _locked = (_lockVal isEqualTo 1) || (_lockVal isEqualTo true);

                            if (!_locked && { _currentTime - _lastActionTime >= _COOLDOWN }) then {
                                _bldg animateSource [format ["Door_%1_sound", _doorNum], 1];
                                _bldg animateSource [format ["Door_%1_source", _doorNum], 1, false];
                                _bldg animateDoor [format ["Door_%1_source", _doorNum], 1, false];
                                _bldg animateDoor [format ["Door_%1", _doorNum], 1, false];
                                _bldg animateDoor [_anim, 1, false];
                                _bldg animate [_anim, 1];

                                playSound3D ["A3\Sounds_F\environment\doors\DoorWoodSingleOpen_1.wss", objNull, false, _doorPos, 0.45, 1.0, 15];

                                _x set [3, true];           // _isOpen = true
                                _x set [4, _currentTime];   // _lastActionTime
                                _x set [5, _currentTime];   // _openedAt
                                _x set [6, true];           // _openedByAI = true
                            };
                        } else {
                            // If already open and AI is near, refresh _openedAt so it doesn't close while AI is crossing
                            _x set [5, _currentTime];
                        };
                    } else {
                        // AI is not within 4.0m. Check if we should close the door
                        if (_isOpen && _openedByAI) then {
                            // Must have been open for at least _MIN_OPEN_TIME and cooldown passed
                            if (_currentTime - _openedAt >= _MIN_OPEN_TIME && { _currentTime - _lastActionTime >= _COOLDOWN }) then {
                                // Safe check: no unit (AI or player) within _CLOSE_DIST (5.5m)
                                private _anyoneClose = _allActiveUnits findIf { (_x distanceSqr _doorPos) < _CLOSE_DIST_SQR } != -1;

                                if (!_anyoneClose) then {
                                    _bldg animateSource [format ["Door_%1_sound", _doorNum], 0];
                                    _bldg animateSource [format ["Door_%1_source", _doorNum], 0, false];
                                    _bldg animateDoor [format ["Door_%1_source", _doorNum], 0, false];
                                    _bldg animateDoor [format ["Door_%1", _doorNum], 0, false];
                                    _bldg animateDoor [_anim, 0, false];
                                    _bldg animate [_anim, 0];

                                    playSound3D ["A3\Sounds_F\environment\doors\DoorWoodSingleClose_1.wss", objNull, false, _doorPos, 0.45, 1.0, 15];

                                    _x set [3, false];          // _isOpen = false
                                    _x set [4, _currentTime];   // _lastActionTime
                                    _x set [6, false];          // _openedByAI = false
                                };
                            };
                        };
                    };
                } forEach _doors;
            };
        } forEach _nearBuildings;
    };
};
