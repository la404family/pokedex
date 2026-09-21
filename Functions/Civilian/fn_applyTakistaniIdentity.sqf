params [
    ["_unit", objNull, [objNull]],
    ["_isFemale", false, [false]],
    ["_isEnemy", false, [false]]
];

if (isNull _unit || !local _unit) exitWith {};

private _fullName = "";
private _firstName = "";
private _lastName = "";

if (_isFemale) then {
    private _nameArr = selectRandom MISSION_CivilianNames_Female;
    _fullName = _nameArr select 0;
    _firstName = _nameArr select 1;
    _lastName = _nameArr select 2;
    _unit setSpeaker "NoVoice";
    _unit setFace "";
} else {
    private _nameArr = selectRandom MISSION_CivilianNames_Male;
    _fullName = _nameArr select 0;
    _firstName = _nameArr select 1;
    _lastName = _nameArr select 2;
    _unit setFace (selectRandom MISSION_CivilianMaleFaces);
    _unit setSpeaker (selectRandom ["Male01PER", "Male02PER", "Male03PER"]);
};

_unit setName [_fullName, _firstName, _lastName];
_unit setNameSound _firstName;

private _pitch = if (_isFemale) then { selectRandom [1.3, 1.4] } else { 1.0 };
_unit setPitch _pitch;

removeAllWeapons _unit;
removeAllItems _unit;
removeAllAssignedItems _unit;
removeUniform _unit;
removeVest _unit;
removeBackpack _unit;
removeHeadgear _unit;
removeGoggles _unit;

if (_isFemale) then {
    _unit forceAddUniform (selectRandom MISSION_CivilianUniforms_Female);
} else {
    _unit forceAddUniform (selectRandom MISSION_CivilianUniforms_Male);
    
    // 100% de chapeaux pour les hommes
    _unit addHeadgear (selectRandom MISSION_CivilianHats);
    
    if (random 1 > 0.4) then {
        _unit addGoggles (selectRandom MISSION_CivilianBeards);
    };
    
    // Les vestes civiles (Jacket) sont ajoutées aléatoirement pour varier
    if (random 1 > 0.3) then {
        _unit addVest (selectRandom MISSION_CivilianVests);
    };
};

if (_isEnemy) then {
    private _weapon = selectRandom MISSION_BanditWeapons;
    _unit addWeapon _weapon;
    
    _unit addPrimaryWeaponItem (selectRandom ["CUP_acc_Flashlight","CUP_acc_Zenit_2DS"]);
    _unit addHandgunItem (selectRandom ["CUP_acc_CZ_M3X","acc_Flashlight_pistol"]);
    
    private _magazines = getArray (configFile >> "CfgWeapons" >> _weapon >> "magazines");
    if (count _magazines > 0) then {
        private _mag = _magazines select 0;
        _unit addMagazine _mag;
        _unit addMagazine _mag;
        _unit addMagazine _mag;
        _unit addMagazine _mag;
    };

    _unit addBackpack (selectRandom MISSION_BanditBackpacks);
    
    if (!_isFemale) then {
        for "_i" from 1 to 2 do { _unit addItem "FirstAidKit"; };
        _unit addItem "SmokeShell";
        _unit linkItem "ItemMap";
        _unit linkItem "ItemCompass";
        _unit linkItem "ItemWatch";
        _unit linkItem "ItemRadio";
    };
};
