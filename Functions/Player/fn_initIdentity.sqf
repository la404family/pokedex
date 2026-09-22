// fn_initIdentity.sqf - Optimized for Solo
private _names_african = [
    ["Moussa Diallo", "Moussa", "Diallo"], ["Mamadou Traoré", "Mamadou", "Traoré"], ["Ibrahim Keita", "Ibrahim", "Keita"],
    ["Sekou Diop", "Sekou", "Diop"], ["Ousmane Sy", "Ousmane", "Sy"], ["Bakary Sow", "Bakary", "Sow"], ["Ismaël Koné", "Ismaël", "Koné"]
];

private _names_arab = [
    ["Mehdi Benali", "Mehdi", "Benali"], ["Sofiane Haddad", "Sofiane", "Haddad"], ["Karim Mansouri", "Karim", "Mansouri"],
    ["Mohamed Trabelsi", "Mohamed", "Trabelsi"], ["Walid Belkacem", "Walid", "Belkacem"], ["Hicham Bouzid", "Hicham", "Bouzid"],
    ["Adel Gharbi", "Adel", "Gharbi"], ["Nassim Saïdi", "Nassim", "Saïdi"], ["Rachid Ziani", "Rachid", "Ziani"],
    ["Adam Khayat", "Adam", "Khayat"], ["Rayane Meriah", "Rayane", "Meriah"]
];

private _names_asian = [
    ["Minh Tuan Nguyen", "Minh Tuan", "Nguyen"], ["Kevin Chang", "Kevin", "Chang"], ["Thomas Vo", "Thomas", "Vo"],
    ["Nicolas Hoang", "Nicolas", "Hoang"], ["Pierre Dang", "Pierre", "Dang"], ["Jun Li", "Jun", "Li"],
    ["Hao Wang", "Hao", "Wang"], ["Kenji Sato", "Kenji", "Sato"], ["Jun-ho Kang", "Jun-ho", "Kang"],
    ["Si-woo Cho", "Si-woo", "Cho"], ["Yer Xiong", "Yer", "Xiong"]
];

private _names_pacific = [
    ["Teiva Tehuiotoa", "Teiva", "Tehuiotoa"], ["Manaarii Puarai", "Manaarii", "Puarai"], ["Teva Rohi", "Teva", "Rohi"],
    ["Manua Tuihani", "Manua", "Tuihani"], ["Keanu Loa", "Keanu", "Loa"], ["Tamatoa Arii", "Tamatoa", "Arii"],
    ["Ariitea Tehei", "Ariitea", "Tehei"]
];

private _names_standard = [
    ["Julien Martin", "Julien", "Martin"], ["Thomas Bernard", "Thomas", "Bernard"], ["Nicolas Petit", "Nicolas", "Petit"],
    ["Alexandre Dubois", "Alexandre", "Dubois"], ["Maxime Moreau", "Maxime", "Moreau"], ["Guillaume Laurent","Guillaume", "Laurent"],
    ["Lucas Girard", "Lucas", "Girard"], ["Romain Roux", "Romain", "Roux"], ["Clément Fournier", "Clément", "Fournier"],
    ["Mathieu Bonnet", "Mathieu", "Bonnet"], ["Erwan Le Gall", "Erwan", "Le Gall"], ["Enzo Rossi", "Enzo", "Rossi"]
];

private _allNamesTyped = [];
{ _allNamesTyped pushBack [_x, "Black"]; } forEach _names_african;
{ _allNamesTyped pushBack [_x, "Arab"]; } forEach _names_arab;
{ _allNamesTyped pushBack [_x, "Asian"]; } forEach _names_asian;
{ _allNamesTyped pushBack [_x, "Pacific"]; } forEach _names_pacific;
{ _allNamesTyped pushBack [_x, "White"]; } forEach _names_standard;

private _usedNames = [];

private _squad = [
    missionNamespace getVariable ["player_0", objNull],
    missionNamespace getVariable ["player_1", objNull],
    missionNamespace getVariable ["player_2", objNull],
    missionNamespace getVariable ["player_3", objNull],
    missionNamespace getVariable ["player_4", objNull],
    missionNamespace getVariable ["player_5", objNull]
] select { !isNull _x };

{
    private _unit = _x;
    
    // Select a unique name
    private _available = _allNamesTyped select { !((_x select 0 select 0) in _usedNames) };
    if (_available isEqualTo []) then { _usedNames = []; _available = _allNamesTyped; };
    private _entry = selectRandom _available;
    private _nameData = _entry select 0;
    private _faceType = _entry select 1;
    _usedNames pushBack (_nameData select 0);

    // Face
    private _faces = switch (_faceType) do {
        case "Black": { ["AfricanHead_01","AfricanHead_02","AfricanHead_03"] };
        case "Arab": { ["PersianHead_A3_01","PersianHead_A3_02","PersianHead_A3_03","GreekHead_A3_01","GreekHead_A3_02","GreekHead_A3_03","GreekHead_A3_04","GreekHead_A3_05","GreekHead_A3_06"] };
        case "Asian": { ["AsianHead_A3_01","AsianHead_A3_02","AsianHead_A3_03"] };
        case "Pacific": { ["TanoanHead_A3_01","TanoanHead_A3_02","TanoanHead_A3_03","TanoanHead_A3_04","TanoanHead_A3_05"] };
        default { ["WhiteHead_01","WhiteHead_02","WhiteHead_03","WhiteHead_04","WhiteHead_05","WhiteHead_06","WhiteHead_07","WhiteHead_08","WhiteHead_09","WhiteHead_10","WhiteHead_11","WhiteHead_12","WhiteHead_13","WhiteHead_14","WhiteHead_15","WhiteHead_16","WhiteHead_17","WhiteHead_18","WhiteHead_19","WhiteHead_20","WhiteHead_21"] };
    };
    private _face = selectRandom _faces;

    // Voice
    private _speaker = switch (_faceType) do {
        case "White": { selectRandom ["Male01ENG", "Male02ENG", "Male03ENG", "Male04ENG"] };
        case "Black": { selectRandom ["Male05ENG", "Male06ENG", "Male07ENG"] };
        default { selectRandom ["Male08ENG", "Male09ENG", "Male10ENG", "Male11ENG", "Male12ENG"] };
    };
    private _pitch = 0.90 + random 0.20;

    // Apply identity locally instantly
    _unit setFace _face;
    _unit setSpeaker _speaker;
    _unit setPitch _pitch;
    _unit setName [(_nameData select 0), (_nameData select 1), (_nameData select 2)];
    
    // Configuration dynamique des voix avec le mod UVO (Anglais pour RACS)

    
} forEach _squad;

// Assign specific ranks
if (!isNull (missionNamespace getVariable ["player_0", objNull])) then { player_0 setUnitRank "SERGEANT"; };
if (!isNull (missionNamespace getVariable ["player_1", objNull])) then { player_1 setUnitRank "CORPORAL"; };
