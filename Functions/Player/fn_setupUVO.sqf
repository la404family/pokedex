/*
 * LL_fnc_setupUVO
 *
 * Description:
 *   Configure le mod Unit Voice-Overs (UVO) pour une unité.
 *   - L'équipe et les Indépendants parlent Anglais ("English").
 *   - Tous les autres (Civils, OPFOR, BLUFOR) parlent Persan ("Persian").
 *
 * Arguments:
 *   0: <OBJECT> L'unité à configurer
 */

params [
    ["_unit", objNull, [objNull]]
];

if (isNull _unit || !alive _unit) exitWith {};

// La langue dépend uniquement du camp (Indépendant = Anglais, autres = Persan)
private _uvoLang = if (side _unit == independent) then {
    "English"
} else {
    "Persian"
};

// Application des variables attendues par le mod UVO
// On force la langue, désactive l'assignation automatique, etc.
_unit setVariable ["UVO_Voice", _uvoLang, true];
_unit setVariable ["UVO_Language", _uvoLang, true];

{
    _unit setVariable [_x, true, true];
} forEach [
    "uvo_disable_auto",
    "UVO_disableAuto",
    "UVO_autoAssign",
    "uvo_autoDetect"
];
