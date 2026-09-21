# INFO_MENU.md — Spécification du Menu Tactique de Lancement Initial

Ce document spécifie le fonctionnement, l'architecture GUI, la configuration Éditeur Eden, les identifiants de contrôle (IDCs) et la logique de nettoyage post-lancement du **Panneau de Commandement Initial** (`Refour_Main_Menu_Dialog`, IDD 7000) pour la mission *Takistan Restored*.

---

## 1. Objectifs et Fonctionnalités du Menu Initial

Le menu initial (`Refour_Main_Menu_Dialog`) est l'interface centrale 3 panneaux de préparation avant l'insertion tactique du joueur sur le théâtre d'opérations de Takistan.

* **Ouverture Automatique :** Dès le démarrage (`init.sqf`), le script [`fn_spawn_main_menu.sqf`](file:///c:/Users/kevin/Documents/Arma%203/missions/takistanRestored.takistan/Functions/Spawn/fn_spawn_main_menu.sqf) est exécuté avec l'argument `"OPEN"`.
* **Disposition 3 Panneaux :**
  1. **Panneau Gauche :** Sélection des Tâches Obligatoires (cochées/bloquées) et Optionnelles (cochables).
  2. **Panneau Central :** Réglages environnementaux (Heure, Nuages, Brouillard) et Aperçu Véhicule en temps réel PiP 3D (`rendertarget8`).
  3. **Panneau Droit :** Choix du secteur d'opération (Grille militaire), vecteur d'insertion (Hélicoptère / HALO C-130) et carte tactique interactive.

---

## 2. Structure GUI et Contrôles IDCs (`Dialogs/main_menu.hpp`)

**Dialog IDD :** `7000` (`Refour_Main_Menu_Dialog`)

### 🔹 Panneau Gauche : Sélection des Objectifs de Mission
| IDC | Type | Description / Rôle |
| :--- | :--- | :--- |
| **`7100`** | `RscCheckBox` | **Tâche Obligatoire 1 (TaskA)** : Se rendre sur zone (Cochée & verrouillée). |
| **`7101`** | `RscCheckBox` | **Tâche Obligatoire 2 (TaskB)** : Protection population (Cochée & verrouillée). |
| **`7102`** | `RscCheckBox` | **Tâche Obligatoire 3 (TaskC)** : Protection escouade & Extraction (Cochée & verrouillée). |
| **`7110`** | `RscCheckBox` | **Optionnelle 1 :** Captif (`TASK_CAPTIVE`) |
| **`7111`** | `RscCheckBox` | **Optionnelle 2 :** Cible HVT (`TASK_HVT`) |
| **`7112`** | `RscCheckBox` | **Optionnelle 3 :** Déminage (`TASK_DEFUSE`) |
| **`7113`** | `RscCheckBox` | **Optionnelle 4 :** Émetteur Radio (`TASK_TRANSMISSION`) |
| **`7114`** | `RscCheckBox` | **Optionnelle 5 :** Dépôt Chimique (`TASK_CHEMICAL`) |
| **`7115`** | `RscCheckBox` | **Optionnelle 6 :** Extraction HVT (`TASK_EXTRACT_HVT`) |
| **`7116`** | `RscCheckBox` | **Optionnelle 7 :** Documents Secrets (`TASK_DOCUMENTS`) |
| **`7117`** | `RscCheckBox` | **Optionnelle 8 :** Épave Tigris (`TASK_TIGRIS`) |
| **`7118`** | `RscCheckBox` | **Optionnelle 9 :** Milice Insurgée (`TASK_MILITIA`) |

### 🔹 Panneau Central : Environnement & Studio Véhicule 3D (PiP)
| IDC | Type | Description / Rôle |
| :--- | :--- | :--- |
| **`7200`** | `RscCombo` | **Heure de la journée :** Liste déroulante de 00:00 à 23:00. |
| **`7201`** | `RscCombo` | **Couverture nuageuse :** Pourcentage d'ennuagement (0% à 100%). |
| **`7202`** | `RscCombo` | **Densité du brouillard :** Intensité du brouillard (0% à 100%). |
| **`7204`** | `RscCombo` | **Sélection du Véhicule :** Liste auto-remplie des véhicules légers issus de `CfgVehicles` (par défaut `CUP_I_LR_Transport_RACS`). |
| **`7203`** | `RscPicture` | **Écran Caméra PiP :** Rendu 3D temps réel du véhicule d'exposition (`#(argb,512,512,1)r2t(rendertarget8,1.0)`). |

### 3️⃣ Panneau Droit : Déploiement Tactique & Carte Interactive
| IDC | Type | Description / Rôle |
| :--- | :--- | :--- |
| **`7300`** | `RscCombo` | **Secteur de Déploiement :** Sélection parmi les marqueurs carte (`marker_*`) avec affichage des coordonnées de grille militaires (`Grille XXX-YYY`). |
| **`7301`** | `RscCombo` | **Vecteur d'Insertion :** Dépose par Hélicoptère (`HELI` / `fn_intro_01`) ou Parachutage C-130 HALO (`TAP` / `fn_intro_02`). |
| **`7302`** | `RscMapControl` | **Carte Tactique Interactive :** Zoom et centrage automatique sur le secteur sélectionné. |

---

## 3. Éléments Obligatoires dans l'Éditeur Eden (Studio PiP)

Pour assurer le fonctionnement du rendu 3D du véhicule dans l'écran PiP du menu :

1. **`vehicles_spawner` (`Game Logic`) :** Marqueur de position de spawn pour le véhicule de prévisualisation du menu.
2. **`post_camera` (`Game Logic`) :** Position et orientation de la caméra du studio de prévisualisation.
3. **`post_lamp_0`, `post_lamp_1`, `post_lamp_2` (`Game Logics`) :** Eclairages/projecteurs du studio d'exposition du véhicule.

---

## 4. Logique de Lancement & Nettoyage (`LAUNCH`)

Lorsque le joueur clique sur le bouton **Lancer l'opération** :

1. **Collecte des Tâches :** Vérification des cases cocher optionnelles. Si aucune tâche optionnelle n'est sélectionnée, une alerte est affichée.
2. **Clôture du GUI :** Fermeture du dialogue (`closeDialog 0`).
3. **Nettoyage Automatique du Studio PiP :**
   * Destruction de l'objet véhicule de prévisualisation (`MISSION_var_preview_veh`).
   * Suppression de la caméra PiP (`MISSION_var_veh_cam`) et déconnexion de `rendertarget8`.
   * Suppression des GameLogics `vehicles_spawner`, `post_camera` et des projecteurs `post_lamp_*`.
4. **Application des Conditions Météo :** Horodatage (`setDate`), ennuagement (`setOvercast`), brouillard (`setFog`) et synchronisation (`simulWeatherSync`).
5. **Calcul de la Zone d'Atterrissage (LZ) :** Détermination dynamique d'une LZ distante d'au moins **900 m** de l'objectif principal.
6. **Lancement des Systèmes de Mission :**
   * Exécution de la cinématique sélectionnée (`fn_intro_01` pour hélicoptère ou `fn_intro_02` pour parachutage HALO).
   * Lancement de la faune et de la population civile ambiante (`fn_ambientCivilians`).
   * Lancement du générateur de scénarios (`fn_task_generator`).
