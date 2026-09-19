# INFO_MENU.md — Spécification du Menu Tactique de Lancement Initial

Ce document spécifie le fonctionnement, les objectifs, la configuration Éditeur Eden et la logique de nettoyage post-lancement du **Panneau de Commandement Initial** pour la mission Takistan Restored.

---

## 1. Objectifs et Fonctionnalités du Menu Initial

Le menu initial (`Refour_Main_Menu_Dialog`) est l'interface centrale de préparation avant l'insertion tactique du joueur sur le théâtre d'opérations de Takistan.

* **Ouverture Automatique :** Dès le démarrage de la mission (`init.sqf` / `initPlayerLocal.sqf`), le jeu masque l'écran (`titleCut`) et ouvre immédiatement le panneau de commande plein écran.
* **Sélection de Mission :** Choix parmi les missions d'opération (Reconnaissance, Destruction de dépôt, Infiltration HVT) avec mise à jour dynamique du titre et du briefing.
* **Panneau Environnement & Météo :**
  * **Heure de la journée :** Réglage en direct de l'horaire.
  * **Couverture nuageuse :** Ajustement de l'ennuagement.
  * **Densité du brouillard :** Brouillard scalaire adapté au relief montagneux de Takistan (visible 1 seconde après le choix du joueur).
* **Choix du Véhicule & Aperçu 3D PiP :**
  * Sélection dynamique parmi les véhicules légers/voitures disponibles dans les addons du joueur (véhicule par défaut : *Land Rover 110 Transport* `CUP_I_LR_Transport_RACS`).
  * Flux vidéo caméra en temps réel (`rendertarget8`) affichant le véhicule sous les projecteurs de la zone de présentation (`vehicles_spawner`).
* **Déploiement Tactique & Carte :**
  * **Secteur de Déploiement :** Sélection du secteur d'opération avec affichage des coordonnées de grille militaires (`Grille 097-043`).
  * **Vecteur d'Insertion :** Dépose par Hélicoptère (`HELI`) ou Parachutage haute altitude (`TAP`).
  * **Aperçu Carte Tactique :** Animation et centrage automatique de la carte sur le secteur sélectionné.

---

## 2. Déroulement du Lancement et Nettoyage Post-Opération

Lors du clic sur **"LANCER L'OPÉRATION"**, le script (`LL_fnc_spawn_main_menu`) exécute les séquences suivantes :

### A. Suppression des Éléments de Prévisualisation (Nettoyage de Scène)
Tous les éléments temporaires de présentation situés sur le terrain sont définitivement supprimés afin de libérer de la mémoire et d'assainir la carte :
* **`post_camera` :** La caméra de prévisualisation et sa logique support.
* **`vehicles_spawner` :** La logique de spawner et la zone d'exposition du véhicule.
* **`post_lamp_0`, `post_lamp_1`, `post_lamp_2` :** Les projecteurs d'éclairage nocturne de la zone d'exposition.
* **`MISSION_var_preview_veh` & Caméra PiP :** Destruction du véhicule 3D d'aperçu et fermeture du canal vidéo `rendertarget8`.

### B. Isolation Visuelle du Secteur sur la Carte
* Tous les marqueurs de secteurs non sélectionnés (`marker_0`, `marker_1`, etc.) passent en **transparence totale (`setMarkerAlpha 0`)**.
* **Seul le marqueur du secteur choisi pour la mission reste visible sur la carte (`setMarkerAlpha 1`)**.

### C. Introductions et Déploiement Aérien
Le lancement déclenche l'une des deux séquences d'introduction tactique :
1. **Introduction Hélicoptère (`fn_intro_01.sqf`) :**
   - Rassemblement des unités jouables `player_0` à `player_5` (faction Indépendante - RACS).
   - Embarquement des joueurs dans l'hélicoptère de transport allié UH-60L (`CUP_I_UH60L_FFV_RACS`).
   - Séquence vidéo cinématique, vol d'approche tactique, ouverture des portes latérales, atterrissage et débarquement des joueurs à la LZ.
2. **Introduction Avion (`fn_intro_02.sqf`) :**
   - Largage parachutiste (HALO) depuis un C-130J à haute altitude au-dessus du secteur.

### D. Point de Dépose et Ravitaillement du Véhicule
* **Zone d'Insertion (Minimum 900m) :** Le point d'atterrissage ou de largage est déterminé à un minimum de **900 mètres** du secteur d'objectif afin de garantir une phase d'approche tactique.
* **Téléportation et Équipement du Véhicule Sélectionné :**
  - Le véhicule choisi dans le menu est généré à proximité immédiate du lieu de dépose/largage et assigné à la variable `vehicule_team`.
  - Il est accompagné sur place d'une **caisse de munitions / arsenal (`fn_spawnStartArsenal.sqf`)** et d'un **fumigène vert (`SmokeShellGreen`)** marquant le point de ralliement.

---

## 3. Configuration Requise dans l'Éditeur Eden

Pour assurer le bon fonctionnement du menu et de la scène de présentation, les éléments suivants doivent être placés dans l'Éditeur Eden :

1. **Objets de Scène Caméra & Véhicule :**
   * `post_camera` : Position et orientation de la caméra de prévisualisation du véhicule.
   * `vehicles_spawner` : Point central où le véhicule est exposé.
   * `post_lamp_0`, `post_lamp_1`, `post_lamp_2` : Éclairages orientés vers `vehicles_spawner` pour la prévisualisation de nuit.
2. **Unités Jouables :**
   * Unités jouables RACS (Indépendant) nommées `player_0` à `player_5`.
3. **Marqueurs de Secteurs :**
   * Marqueurs nommés `marker_0`, `marker_1`, `marker_2`, etc., définissant les zones d'opérations sur Takistan.

---

## 4. Architecture Fichiers & Système de Traduction

```
description.ext                 ← Inclusion de Dialogs\main_menu.hpp et CfgFunctions (LL_fnc_intro_01)
stringtable.xml                 ← Fichier compilé contenant les 15 langues Arma 3

Dialogs/
  main_menu.hpp                 ← Interface HPP plein écran (IDD 7000, PiP rendertarget8)

Functions/Spawn/
  fn_spawn_main_menu.sqf        ← Traitement SQF (OPEN, SELECT_MISSION, SELECT_VEHICLE, UPDATE_MAP, UPDATE_ENV_PREVIEW, LAUNCH)
  fn_spawn_main_menu.xml        ← Source XML des textes (15 langues traduites)

Functions/Task/
  fn_intro_01.sqf               ← Introduction Hélicoptère (UH-60L RACS, embarquement player_0 à player_5)
  fn_intro_01.xml               ← Source XML des textes de l'intro (15 langues traduites)
  fn_spawnStartArsenal.sqf      ← Génération de la caisse d'arsenal au point de dépose
```

Le projet suit la procédure **`INFO_STRINTABLE.md`** : toute modification de texte s'effectue dans les fichiers `.xml` puis est compilée dans `stringtable.xml` via `python compile_stringtable.py`.
