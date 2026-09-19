if (!isServer) exitWith {};

[] spawn {
    while {true} do {
        {
            if (!isPlayer _x && {alive _x} && {damage _x > 0.2} && {"FirstAidKit" in items _x} && {vehicle _x == _x} && {!(_x getVariable ["LL_isHealing", false])}) then {
                _x setVariable ["LL_isHealing", true];

                [_x] spawn {
                    params ["_unit"];

                    doStop _unit;
                    _unit removeItem "FirstAidKit";
                    [_unit, "AinvPknlMstpSnonWnonDnon_medic_1"] remoteExecCall ["playMoveNow", 0];

                    sleep 6;

                    if (alive _unit) then {
                        _unit setDamage 0;
                        [_unit, ""] remoteExecCall ["switchMove", 0];
                        _unit doFollow (leader group _unit);
                    };

                    _unit setVariable ["LL_isHealing", false];
                };
            };
        } forEach allUnits;

        sleep 5;
    };
};
