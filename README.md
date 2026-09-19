# OPERATION ROYAL ALLIANCE — Takistan Restored

Mission Solo (Single-Player) exclusive sur Arma 3.
Faction joueur : **Indépendant — RACS (Royal Army Corps of Sahrani)**.

---

## ⚠️ DIRECTIVE STRICTE DE DÉVELOPPEMENT

> **IMPORTANT :** 
> La majorité des scripts présents dans le dossier `Functions/` **NE SONT PAS IMPLÉMENTÉS**.
> Ce sont des ébauches ou des structures provisoires. **Il ne faut pas s'y fier ni les exécuter tels quels**.
> Tout le reste du projet doit être **modifié et adapté à la réalité des entités et variables réelles de l'éditeur** (voir document de référence : `INFO_EDITOR.md`).
> 
> **RÈGLE SUR LA RADIO TTS :** Le système de radio/TTS (`LL_fnc_radioMessage`) est STRICTEMENT réservé aux communications globales (ex: QG, Soutien, Drone, Hélicoptère). Il NE DOIT JAMAIS être utilisé pour les actions locales de l'escouade ou les changements de Règles d'Engagement (ROE).

---

## 1. Fichiers RÉELLEMENT Implémentés et Actifs

Seuls les fichiers suivants sont officiellement déclarés, fonctionnels et rattachés au moteur de jeu via `description.ext` :

| Fichier | Rôle / Description |
| :--- | :--- |
| [`init.sqf`](file:///c:/Users/kevin/Documents/Arma%203/missions/takistanRestored.takistan/init.sqf) | Point d'entrée : protection immédiate des 6 unités jouables et ouverture du menu principal. |
| [`description.ext`](file:///c:/Users/kevin/Documents/Arma%203/missions/takistanRestored.takistan/description.ext) | Configuration mission, sons/musiques, inclusion du menu et déclaration stricte des fonctions actives. |
| [`Dialogs/main_menu.hpp`](file:///c:/Users/kevin/Documents/Arma%203/missions/takistanRestored.takistan/Dialogs/main_menu.hpp) | Interface graphique du menu de préparation de mission (sélection insertion, météo, véhicule, etc.). |
| [`Functions/Spawn/fn_spawn_main_menu.sqf`](file:///c:/Users/kevin/Documents/Arma%203/missions/takistanRestored.takistan/Functions/Spawn/fn_spawn_main_menu.sqf) | Logique du menu principal et lancement de la mission. |
| [`Functions/Task/fn_intro_01.sqf`](file:///c:/Users/kevin/Documents/Arma%203/missions/takistanRestored.takistan/Functions/Task/fn_intro_01.sqf) | Introduction cinématique 1 : Arrivée en hélicoptère UH-60 RACS sur la LZ. (Activation automatique des JVN de nuit). |
| [`Functions/Task/fn_intro_02.sqf`](file:///c:/Users/kevin/Documents/Arma%203/missions/takistanRestored.takistan/Functions/Task/fn_intro_02.sqf) | Introduction cinématique 2 : Insertion par avion C-130J RACS, largage HALO. (Activation automatique des JVN de nuit). |
| [`Functions/Task/fn_spawnStartArsenal.sqf`](file:///c:/Users/kevin/Documents/Arma%203/missions/takistanRestored.takistan/Functions/Task/fn_spawnStartArsenal.sqf) | Génération de l'arsenal de départ. **Comprend un verrouillage de l'uniforme et du casque** pour forcer l'identité visuelle de la Légion Étrangère. |
| [`Functions/Task/fn_initVehicleLoadout.sqf`](file:///c:/Users/kevin/Documents/Arma%203/missions/takistanRestored.takistan/Functions/Task/fn_initVehicleLoadout.sqf) | Transfert du loadout vers le véhicule de l'escouade lors de la fermeture de l'arsenal. |
| [`Functions/Environment/fn_randomWeather.sqf`](file:///c:/Users/kevin/Documents/Arma%203/missions/takistanRestored.takistan/Functions/Environment/fn_randomWeather.sqf) | Initialisation de la météo aléatoire au démarrage et gestion de son évolution dynamique. |
| [`Functions/Environment/fn_initSkills.sqf`](file:///c:/Users/kevin/Documents/Arma%203/missions/takistanRestored.takistan/Functions/Environment/fn_initSkills.sqf) | Gestion dynamique des compétences (buff, boost de vitesse, réduction de l'impact du poids pour l'escouade, et comportement kamikaze pour les ennemis). |
| [`Functions/Player/fn_initIdentity.sqf`](file:///c:/Users/kevin/Documents/Arma%203/missions/takistanRestored.takistan/Functions/Player/fn_initIdentity.sqf) | Attribution aléatoire des visages, voix et noms pour l'escouade (optimisé Solo). |
| [`Functions/Player/fn_initLoadout.sqf`](file:///c:/Users/kevin/Documents/Arma%203/missions/takistanRestored.takistan/Functions/Player/fn_initLoadout.sqf) | Customisation esthétique aléatoire de l'escouade en conservant leurs armes par défaut. |
| [`Functions/Player/fn_setupUVO.sqf`](file:///c:/Users/kevin/Documents/Arma%203/missions/takistanRestored.takistan/Functions/Player/fn_setupUVO.sqf) | Intégration et configuration optionnelle du mod Unit Voice-Overs (Anglais pour RACS, Persan pour le reste). |
| [`Functions/Team/fn_addRoeActions.sqf`](file:///c:/Users/kevin/Documents/Arma%203/missions/takistanRestored.takistan/Functions/Team/fn_addRoeActions.sqf) | Menu d'actions (addActions) permettant au joueur de changer les Règles d'Engagement (ROE). |
| [`Functions/Team/fn_applyRoE.sqf`](file:///c:/Users/kevin/Documents/Arma%203/missions/takistanRestored.takistan/Functions/Team/fn_applyRoE.sqf) | Logique comportementale de l'escouade selon la ROE sélectionnée (silencieuse, sans radio). |
| [`Functions/Team/fn_switchToAI.sqf`](file:///c:/Users/kevin/Documents/Arma%203/missions/takistanRestored.takistan/Functions/Team/fn_switchToAI.sqf) | Gestion ultra-optimisée de la mort en Solo (bascule instantanée du contrôle et du commandement vers une IA survivante). |
| [`Functions/Team/...`](file:///c:/Users/kevin/Documents/Arma%203/missions/takistanRestored.takistan/Functions/Team) | Autres fonctions actives gérant l'identité (`identityManager`, `applyIdentity`), le loadout (`randomizeLoadout`) de l'escouade, et l'application stricte de l'insigne RACS (`badgeManager`). |
| [`stringtable.xml`](file:///c:/Users/kevin/Documents/Arma%203/missions/takistanRestored.takistan/stringtable.xml) | Table de localisation (textes, sous-titres, cinématiques). |
| [`TTS/generate_radio.py`](file:///c:/Users/kevin/Documents/Arma%203/missions/takistanRestored.takistan/TTS/generate_radio.py) | Générateur audio TTS automatisé avec application de filtres immersifs "Radio Lo-Fi" dynamiques (Pydub/FFmpeg). |
| [`Functions/UI/fn_radioMessage.sqf`](file:///c:/Users/kevin/Documents/Arma%203/missions/takistanRestored.takistan/Functions/UI/fn_radioMessage.sqf) | Système d'affichage des messages radio (file d'attente native via `BIS_fnc_showSubtitle`). |
| [`Functions/Helicopter/fn_initSupport.sqf`](file:///c:/Users/kevin/Documents/Arma%203/missions/takistanRestored.takistan/Functions/Helicopter/fn_initSupport.sqf) | Initialisation du menu de Soutien (0-8) natif pour appeler l'hélicoptère. |
| [`Functions/Helicopter/fn_heliManager.sqf`](file:///c:/Users/kevin/Documents/Arma%203/missions/takistanRestored.takistan/Functions/Helicopter/fn_heliManager.sqf) | Cerveau du pilotage de l'hélico, logiques de dépose physique, CAS, Timer, RTB et extraction VIP. |
| [`Functions/Helicopter/fn_heliDispatch.sqf`](file:///c:/Users/kevin/Documents/Arma%203/missions/takistanRestored.takistan/Functions/Helicopter/fn_heliDispatch.sqf) | Gestionnaire de file d'attente pour ne pas superposer les demandes de soutien. |
| [`Functions/Helicopter/fn_addResupplyAction.sqf`](file:///c:/Users/kevin/Documents/Arma%203/missions/takistanRestored.takistan/Functions/Helicopter/fn_addResupplyAction.sqf) | IA d'escouade automatisée pour se réapprovisionner autour de la caisse de soutien larguée. |
| [`CfgSounds.hpp`](file:///c:/Users/kevin/Documents/Arma%203/missions/takistanRestored.takistan/CfgSounds.hpp) | Configuration des sons générée automatiquement par le script Python. |

---

## 2. Unités Jouables Réelles (Éditeur)

Conformément à `INFO_EDITOR.md` :
- **Mode de jeu :** Solo exclusivement (`player` = `player_0`).
- **Faction :** Indépendant - RACS (PAS BLUFOR).
- **Escouade complète (6 unités au total) :**
  1. `player_0` : Chef d'escouade (joueur)
  2. `player_1` : Soldat AAT
  3. `player_2` : Soldat MAT
  4. `player_3` : Fusilier
  5. `player_4` : Mitrailleur AR
  6. `player_5` : Tireur d'élite / Sniper

À la fin de chaque cinématique d'introduction, ces 6 unités sont systématiquement sorties de leur vecteur de transport, positionnées au sol près du véhicule d'équipe (`vehicule_team`), et rattachées sous le commandement direct du joueur (`group player selectLeader player`).

---

## 3. Reste du Projet (À modifier et adapter)

Tous les autres dossiers et fichiers présents dans `Functions/` :
- `Functions/Briefing/` (En attente de mise à jour des textes selon `INTEGR_BRIEFING.md`)
- `Functions/Civilian/`
- `Functions/Drone/`
- `Functions/Environment/` (à l'exception de `fn_randomWeather.sqf` et `fn_initSkills.sqf`)
- `Functions/Player/` (à l'exception de `fn_initIdentity.sqf` et `fn_initLoadout.sqf`)
- `Functions/Task/` (à l'exception de `fn_intro_01.sqf`, `fn_intro_02.sqf`, `fn_spawnStartArsenal.sqf`, `fn_initVehicleLoadout.sqf`)

**Sont en attente d'implémentation.**  
Ne pas présumer de leur fonctionnement. Tout développement ultérieur doit se baser exclusivement sur les spécifications de l'éditeur (`INFO_EDITOR.md`, `INFO_TASKS.md`, `INFO_MENU.md`).
