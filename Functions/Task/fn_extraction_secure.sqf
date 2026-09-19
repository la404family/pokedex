params ["_heli"];

if (!isServer) exitWith {};
if (!alive _heli) exitWith {};

private _humanPlayers = allPlayers select { alive _x && !(_x isKindOf "HeadlessClient_F") };
if (count _humanPlayers == 0 && !isNull player) then { _humanPlayers = [player]; };

private _allAllies = [];

{
    private _grp = group _x;
    {
        if (alive _x && side group _x == west && !(_x in _allAllies) && !(_x in (crew _heli))) then {
            _allAllies pushBackUnique _x;
        };
    } forEach (units _grp);
} forEach _humanPlayers;

{
    if (alive _x && side group _x == west && !(_x in _allAllies) && !(_x in (crew _heli))) then {
        _allAllies pushBackUnique _x;
    };
} forEach (playableUnits + switchableUnits);

private _hostage = missionNamespace getVariable ["LL_Task00_Hostage", objNull];
if (!isNull _hostage && alive _hostage && !(_hostage in _allAllies)) then {
    _allAllies pushBackUnique _hostage;
};

private _hvt = missionNamespace getVariable ["LL_Task06_HVT", objNull];
if (!isNull _hvt && alive _hvt && !(_hvt in _allAllies)) then {
    _allAllies pushBackUnique _hvt;
};

private _aiUnits = _allAllies select { !(_x in _humanPlayers) && vehicle _x != _heli };

if (count _aiUnits > 0) then {
    private _heliPos = getPosATL _heli;
    
    // Exécuter le code directement sur la machine du joueur qui contrôle l'IA
    // Cela contourne tous les blocages de sécurité Arma 3 (CfgRemoteExec) sur la commande joinSilent
    {
        [
            [_x, _heliPos], 
            {
                params ["_unit", "_pos"];
                if (!local _unit) exitWith {}; // Sécurité

                private _grp = createGroup [west, true];
                [_unit] joinSilent _grp;
                
                _grp setBehaviour "AWARE";
                _grp setCombatMode "RED";
                _grp setSpeedMode "FULL";

                _unit setSkill ["courage", 1.0];
                _unit enableAI "FSM";
                _unit enableAI "MOVE";
                _unit enableAI "PATH";
                _unit enableAI "TARGET";
                _unit enableAI "AUTOTARGET";
                _unit enableAI "WEAPONAIM";
                _unit disableAI "AUTOCOMBAT";
                _unit disableAI "COVER";
                _unit disableAI "SUPPRESSION";
                
                _unit setBehaviour "AWARE";
                _unit setCombatMode "RED";
                _unit setSpeedMode "FULL";
                _unit allowDamage false;
                
                _unit doMove _pos;
            }
        ] remoteExec ["spawn", _x];
    } forEach _aiUnits;
};

{
    if (vehicle _x != _heli) then {
        _x assignAsCargo _heli;
    };
} forEach _humanPlayers;

missionNamespace setVariable ["LL_Extraction_Boarded", false, true];
missionNamespace setVariable ["LL_Extraction_HeliObj", _heli, true];

[
    _heli,
    {
        params ["_targetHeli"];
        if (!hasInterface) exitWith {};
        if (isNull _targetHeli) exitWith {};

        private _oldId = missionNamespace getVariable ["LL_Extraction_Draw3D_ID", -1];
        if (_oldId != -1) then {
            removeMissionEventHandler ["Draw3D", _oldId];
        };

        private _id = addMissionEventHandler ["Draw3D", {
            private _h = missionNamespace getVariable ["LL_Extraction_HeliObj", objNull];
            if (isNull _h || !alive _h || vehicle player == _h || (missionNamespace getVariable ["LL_Extraction_Boarded", false])) exitWith {};
            private _pos = _h modelToWorld [0, 0, 1.8];
            private _dist = player distance _h;
            if (_dist < 800) then {
                private _txt = localize "STR_LL_Task_Extraction_Board";
                if (_txt == "") then { _txt = "Board Helicopter"; };
                drawIcon3D [
                    "\A3\ui_f\data\igui\cfg\simpletasks\types\getin_ca.paa",
                    [0.2, 0.9, 0.3, 0.9],
                    _pos,
                    1.2, 1.2, 0,
                    format ["%1 (%2m)", _txt, round _dist],
                    2, 0.038, "PuristaSemiBold", "center", true
                ];
            };
        }];
        missionNamespace setVariable ["LL_Extraction_Draw3D_ID", _id];
    }
] remoteExec ["spawn", 0, true];

private _allBoarded = false;
private _humanBoardedTime = 0;
private _tick = 0;

while { !_allBoarded && alive _heli } do {
    sleep 1;
    _tick = _tick + 1;

    private _aliveHumans = allPlayers select { alive _x && !(_x isKindOf "HeadlessClient_F") };
    if (count _aliveHumans == 0 && !isNull player) then { _aliveHumans = [player]; };

    private _allHumansIn = true;
    {
        if (vehicle _x != _heli) exitWith { _allHumansIn = false; };
    } forEach _aliveHumans;

    if (_allHumansIn) then {
        _humanBoardedTime = _humanBoardedTime + 1;
    } else {
        _humanBoardedTime = 0;
    };

    private _allAiIn = true;
    private _aiOutside = [];
    {
        if (alive _x && vehicle _x != _heli) then {
            _allAiIn = false;
            _aiOutside pushBack _x;
        };
    } forEach _aiUnits;

    {
        private _u = _x;
        if (_u distance2D _heli > 10) then {
            _u doMove (getPosATL _heli);
        } else {
            _u assignAsCargo _heli;
            [_u] orderGetIn true;
            // La commande action est locale ! Elle doit s'exécuter sur la machine de l'IA
            [_u, ["GetInCargo", _heli]] remoteExec ["action", _u];
        };
    } forEach _aiOutside;

    private _nearEnemies = allUnits select { side group _x == east && alive _x && (_x distance2D _heli < 700) };
    {
        private _e = _x;
        { _x reveal [_e, 4]; } forEach (crew _heli);
    } forEach _nearEnemies;

    if (_allHumansIn && _allAiIn) then {
        _allBoarded = true;
    } else {
        if (_allHumansIn && _humanBoardedTime >= 65 && count _aiOutside > 0) then {
            {
                if (alive _x && vehicle _x != _heli) then {
                    _x moveInCargo _heli;
                    if (vehicle _x != _heli) then {
                        _x moveInAny _heli;
                    };
                };
            } forEach _aiOutside;
            _allAiIn = true;
            _allBoarded = true;
        };
    };
};

missionNamespace setVariable ["LL_Extraction_Boarded", true, true];

[
    {
        if (!hasInterface) exitWith {};
        private _id = missionNamespace getVariable ["LL_Extraction_Draw3D_ID", -1];
        if (_id != -1) then {
            removeMissionEventHandler ["Draw3D", _id];
            missionNamespace setVariable ["LL_Extraction_Draw3D_ID", -1];
        };
    }
] remoteExec ["spawn", 0];

_heli lockCargo true;
_heli setVehicleLock "LOCKED";

{
    if (vehicle _x == _heli) then {
        _x disableAI "MOVE";
        _x disableAI "PATH";
    };
} forEach _aiUnits;

if (!isNull _hostage && alive _hostage && !(missionNamespace getVariable ["LL_Task00_Failed", false])) then {
    ["task_00_exfiltration", "SUCCEEDED", true] call BIS_fnc_taskSetState;
};

if (!isNull _hvt && alive _hvt && !(missionNamespace getVariable ["LL_Task06_Failed", false])) then {
    ["task_06_hvt", "SUCCEEDED", true] call BIS_fnc_taskSetState;
};

{
    if (_x != driver _heli) then {
        _x setBehaviour "COMBAT";
        _x setCombatMode "RED";
        _x enableAI "AUTOTARGET";
        _x enableAI "TARGET";
        _x enableAI "WEAPONAIM";
    };
} forEach (crew _heli);
