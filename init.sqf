[] spawn LL_fnc_initSkills;
[] execVM "Functions\Player\fn_initIdentity.sqf";
[] execVM "Functions\Player\fn_initLoadout.sqf";

if (isServer) then {
    [] spawn LL_fnc_randomWeather;
    [] spawn LL_fnc_heliManager;
    [] spawn LL_fnc_doorSecurity;
    [] spawn LL_fnc_playEzan;
};

if (!hasInterface) exitWith {};

MISSION_var_debug = true;

// Protection immédiate des 6 unités jouables dès le chargement de la mission
for "_i" from 0 to 5 do {
    private _u = missionNamespace getVariable [format ["player_%1", _i], objNull];
    if (isNull _u) then { _u = missionNamespace getVariable [format ["player_0%1", _i], objNull]; };
    if (!isNull _u) then {
        _u allowDamage false;
    };
};

[] spawn {
    titleCut ["", "BLACK FADED", 999];
    waitUntil { !isNull player && time > 0 };
    ["OPEN"] spawn LL_fnc_spawn_main_menu;

    waitUntil { sleep 1; missionNamespace getVariable ["MISSION_intro_finished", false] };

    private _lastPlayer = objNull;
    while {true} do {
        waitUntil { sleep 1; player != _lastPlayer && { !isNull player } };
        _lastPlayer = player;
        [_lastPlayer] call LL_fnc_addRoeActions;
        [] call LL_fnc_initSupport;
    };
};
