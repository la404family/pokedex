# OPERATION ROYAL ALLIANCE — Takistan Restored

Mission Solo (Single-Player) exclusive sur Arma 3.
Faction joueur : **Indépendant — RACS (Royal Army Corps of Sahrani)**.

---

## ⚠️ DIRECTIVE STRICTE DE DÉVELOPPEMENT

> **IMPORTANT :** 
> Ce sont des ébauches ou des structures provisoires. **Il ne faut pas s'y fier ni les exécuter tels quels**.
> Tout le reste du projet doit être **modifié et adapté à la réalité des entités et variables réelles de l'éditeur** (voir document de référence : `INFO_EDITOR.md`).
> 
> **RÈGLE SUR LA RADIO TTS :** Le système de radio/TTS (`LL_fnc_radioMessage`) est STRICTEMENT réservé aux communications globales (ex: QG, Soutien, Drone, Hélicoptère). Il NE DOIT JAMAIS être utilisé pour les actions locales de l'escouade ou les changements de Règles d'Engagement (ROE).

---

## 1. Fichiers RÉELLEMENT Implémentés et Actifs

Seuls les fichiers suivants sont officiellement déclarés, fonctionnels et rattachés au moteur de jeu via `description.ext` et `init.sqf` :

| Fichier | Rôle / Description |
| :--- | :--- |
| [`init.sqf`](file:///c:/Users/kevin/Documents/Arma%203/missions/takistanRestored.takistan/init.sqf) | Point d'entrée : protection immédiate des 6 unités jouables, lancement des gestionnaires serveur (météo, hélicoptère, portes, ezan) et ouverture du menu principal. |
| [`description.ext`](file:///c:/Users/kevin/Documents/Arma%203/missions/takistanRestored.takistan/description.ext) | Configuration mission, sons/musiques, `CfgCommunicationMenu`, inclusion du menu et déclaration stricte des fonctions actives dans `CfgFunctions`. |
| [`Dialogs/main_menu.hpp`](file:///c:/Users/kevin/Documents/Arma%203/missions/takistanRestored.takistan/Dialogs/main_menu.hpp) | Interface graphique du menu de préparation de mission (sélection insertion, météo, véhicule, etc.). |
| [`Functions/Spawn/fn_spawn_main_menu.sqf`](file:///c:/Users/kevin/Documents/Arma%203/missions/takistanRestored.takistan/Functions/Spawn/fn_spawn_main_menu.sqf) | Logique du menu principal et lancement de la mission. |
| [`Functions/Task/fn_intro_01.sqf`](file:///c:/Users/kevin/Documents/Arma%203/missions/takistanRestored.takistan/Functions/Task/fn_intro_01.sqf) | Introduction cinématique 1 : Arrivée en hélicoptère UH-60 RACS sur la LZ. (Activation automatique des JVN de nuit). |
| [`Functions/Task/fn_intro_02.sqf`](file:///c:/Users/kevin/Documents/Arma%203/missions/takistanRestored.takistan/Functions/Task/fn_intro_02.sqf) | Introduction cinématique 2 : Insertion par avion C-130J RACS, largage HALO. (Activation automatique des JVN de nuit). |
| [`Functions/Task/fn_spawnStartArsenal.sqf`](file:///c:/Users/kevin/Documents/Arma%203/missions/takistanRestored.takistan/Functions/Task/fn_spawnStartArsenal.sqf) | Génération de l'arsenal de départ. **Comprend un verrouillage de l'uniforme et du casque** pour forcer l'identité visuelle de la Légion Étrangère. |
| [`Functions/Task/fn_initVehicleLoadout.sqf`](file:///c:/Users/kevin/Documents/Arma%203/missions/takistanRestored.takistan/Functions/Task/fn_initVehicleLoadout.sqf) | Transfert du loadout vers le véhicule de l'escouade lors de la fermeture de l'arsenal. |
| [`Functions/Environment/fn_randomWeather.sqf`](file:///c:/Users/kevin/Documents/Arma%203/missions/takistanRestored.takistan/Functions/Environment/fn_randomWeather.sqf) | Initialisation de la météo aléatoire au démarrage et gestion de son évolution dynamique. |
| [`Functions/Environment/fn_initSkills.sqf`](file:///c:/Users/kevin/Documents/Arma%203/missions/takistanRestored.takistan/Functions/Environment/fn_initSkills.sqf) | Gestion dynamique des compétences (buff, boost de vitesse, réduction de l'impact du poids pour l'escouade, et comportement kamikaze pour les ennemis). |
| [`Functions/Environment/fn_doorSecurity.sqf`](file:///c:/Users/kevin/Documents/Arma%203/missions/takistanRestored.takistan/Functions/Environment/fn_doorSecurity.sqf) | Gestion automatique et immersive des portes pour l'IA (ouverture par porte individuelle à 4 m, tampon anti-claquement, élimination des traversées de porte). |
| [`Functions/Environment/fn_playEzan.sqf`](file:///c:/Users/kevin/Documents/Arma%203/missions/takistanRestored.takistan/Functions/Environment/fn_playEzan.sqf) | Gestion acoustique de l'appel à la prière (Ezan) : spatialisation 3D mono, détection des minarets/haut-parleurs, clustering anti-cacophonie et écho naturel de vallée. |
| [`Functions/Player/fn_initIdentity.sqf`](file:///c:/Users/kevin/Documents/Arma%203/missions/takistanRestored.takistan/Functions/Player/fn_initIdentity.sqf) | Attribution aléatoire des visages, voix et noms pour l'escouade (optimisé Solo). |
| [`Functions/Player/fn_initLoadout.sqf`](file:///c:/Users/kevin/Documents/Arma%203/missions/takistanRestored.takistan/Functions/Player/fn_initLoadout.sqf) | Customisation esthétique aléatoire de l'escouade en conservant leurs armes par défaut. |
| [`Functions/Player/fn_setupUVO.sqf`](file:///c:/Users/kevin/Documents/Arma%203/missions/takistanRestored.takistan/Functions/Player/fn_setupUVO.sqf) | Intégration et configuration optionnelle du mod Unit Voice-Overs (Anglais pour RACS, Persan pour le reste). |
| [`Functions/Team/fn_addRoeActions.sqf`](file:///c:/Users/kevin/Documents/Arma%203/missions/takistanRestored.takistan/Functions/Team/fn_addRoeActions.sqf) | Menu d'actions (addActions) permettant au joueur de changer les Règles d'Engagement (ROE). |
| [`Functions/Team/fn_applyRoE.sqf`](file:///c:/Users/kevin/Documents/Arma%203/missions/takistanRestored.takistan/Functions/Team/fn_applyRoE.sqf) | Logique comportementale de l'escouade selon la ROE sélectionnée (silencieuse, sans radio). |
| [`Functions/Team/fn_switchToAI.sqf`](file:///c:/Users/kevin/Documents/Arma%203/missions/takistanRestored.takistan/Functions/Team/fn_switchToAI.sqf) | Gestion ultra-optimisée de la mort en Solo (bascule instantanée du contrôle et du commandement vers une IA survivante). |
| [`Functions/Team/...`](file:///c:/Users/kevin/Documents/Arma%203/missions/takistanRestored.takistan/Functions/Team) | Autres fonctions actives gérant l'identité (`identityManager`, `applyIdentity`), le loadout (`randomizeLoadout`) de l'escouade, et l'application stricte de l'insigne RACS (`badgeManager`). |
| [`stringtable.xml`](file:///c:/Users/kevin/Documents/Arma%203/missions/takistanRestored.takistan/stringtable.xml) | Table de localisation complète (textes, sous-titres, appuis, cinématiques) compilée automatiquement via `compile_stringtable.py`. |
| [`TTS/generate_radio.py`](file:///c:/Users/kevin/Documents/Arma%203/missions/takistanRestored.takistan/TTS/generate_radio.py) | Générateur audio TTS automatisé avec application de filtres immersifs "Radio Lo-Fi" dynamiques (Pydub/FFmpeg). |
| [`Functions/UI/fn_radioMessage.sqf`](file:///c:/Users/kevin/Documents/Arma%203/missions/takistanRestored.takistan/Functions/UI/fn_radioMessage.sqf) | Système d'affichage des messages radio (file d'attente native via `BIS_fnc_showSubtitle`). |
| [`Functions/Helicopter/fn_initSupport.sqf`](file:///c:/Users/kevin/Documents/Arma%203/missions/takistanRestored.takistan/Functions/Helicopter/fn_initSupport.sqf) | Initialisation du menu de Soutien natif (`CfgCommunicationMenu`, touches 0-8) entièrement localisé via stringtable (`fn_initSupport.xml`). |
| [`Functions/Helicopter/fn_heliDispatch.sqf`](file:///c:/Users/kevin/Documents/Arma%203/missions/takistanRestored.takistan/Functions/Helicopter/fn_heliDispatch.sqf) | Dispatcher et gestionnaire de priorités (cooldowns, annulations avec redirection, retours radio TTS). |
| [`Functions/Helicopter/fn_heliManager.sqf`](file:///c:/Users/kevin/Documents/Arma%203/missions/takistanRestored.takistan/Functions/Helicopter/fn_heliManager.sqf) | Gestionnaire complet du cycle de vie de l'hélicoptère UH-60 RACS (spawn hors de vue en élingue, dépose physique, CAS, extraction VIP, RTB). |
| [`Functions/Helicopter/fn_addResupplyAction.sqf`](file:///c:/Users/kevin/Documents/Arma%203/missions/takistanRestored.takistan/Functions/Helicopter/fn_addResupplyAction.sqf) | Action addAction en jaune (`#FFFF00`) synchronisée en réseau, animant le réapprovisionnement automatique et réaliste des IA d'escouade. |
| [`CfgSounds.hpp`](file:///c:/Users/kevin/Documents/Arma%203/missions/takistanRestored.takistan/CfgSounds.hpp) | Configuration des sons incluant l'appel à la prière (`ezan`) et les voix TTS. |

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

## 3. Système de Soutien Hélicoptère (RACS Air Support)

Le système d'appui aérien est accessible par le joueur chef d'escouade via le menu de communication natif d'Arma 3 (**Touche 0 puis 8 : Soutien**) défini dans [`description.ext`](file:///c:/Users/kevin/Documents/Arma%203/missions/takistanRestored.takistan/description.ext) sous `CfgCommunicationMenu`.

### Les 4 Types de Soutiens Disponibles :
1. **Soutien : Ravitaillement (`LIVRAISON`) :**
   * Largage d'une caisse de munitions `B_supplyCrate_F`.
   * Dès le spawn lointain de l'hélicoptère, la caisse est attachée en élingue (`setSlingLoad`) et remplie automatiquement avec les munitions exactes correspondant aux armes principales, secondaires et de poing de toutes les unités de l'escouade.
   * L'hélicoptère arrive sur zone avec la charge déjà sous lui (aucun pop-in à vue). Il descend en vol stationnaire bas (15m), pose délicatement la caisse au sol et détache les câbles.
   * Déclenchement d'un fumigène vert à l'atterrissage, puis de fumigènes blancs de fin de vie.
2. **Soutien : Véhicule Léger (`VEHICULE`) :**
   * Livraison d'un Land Rover armé `CUP_I_LR_MG_RACS`.
   * Comme pour la caisse, le véhicule est attaché en élingue dès le spawn hors de vue de l'hélicoptère, avec stock de munitions de secours, descendu en douceur et détaché au sol.
   * Limité à un seul véhicule livré par mission pour l'immersion.
3. **Soutien : Extraction (`EMBARQUEMENT`) :**
   * Priorité absolue dans le dispatcher (peut interrompre un CAS ou une livraison).
   * Gestion de l'embarquement et du sauvetage des VIPs et otages de mission (`LL_Task00_Hostage`, `LL_Task02b_Hostage`, `LL_Task06_HVT`).
   * Avertit et éjecte les unités non autorisées, attend le VIP ciblé et déclenche la condition de victoire après vol de retour.
4. **Soutien : CAS (`CAS`) :**
   * Appui aérien rapproché avec orbite (Loiter) à 60 m d'altitude dans un rayon de 250 m pendant 180 secondes.
   * Vitesse régulée à 80 km/h pour stabiliser les tirs des mitrailleurs de bord.
   * Cooldown de 300 secondes après exécution.

### Caractéristiques Techniques :
* **Spawn et Despawn Dynamiques :** Recherche d'une position sûre entre 2500 m et 8000 m de la LZ (`_fnGetSpawnPos`), hors de portée visuelle. L'hélicoptère repart à sa base (`_fnRTB`) et n'est supprimé qu'une fois hors de vue des joueurs (> 1200 m).
* **Zéro Pop-in :** Les cargaisons (caisse ou véhicule) sont instanciées et attachées en élingue dès l'apparition à la base de départ. L'appareil traverse la carte en portant visiblement sa charge.
* **Action de Ravitaillement d'Escouade (`fn_addResupplyAction.sqf`) :**
  * Action molette affichée en jaune vif (`<t color='#FFFF00'>%1</t>`) et localisée (`STR_LL_Action_Resupply`).
  * Diffusée en réseau via `remoteExec` pour être visible par tous les clients.
  * Déclenche un comportement d'escouade réaliste : le leader ordonne l'avance (`gestureAdvance`), les IA alliées se déplacent une par une vers la caisse, se tournent vers elle, jouent l'animation de rechargement (`ReloadMagazine`), récupèrent leurs munitions, grenades, fumigènes et trousses de secours, puis reprennent leur formation.
* **Localisation Multi-langues :** L'intégralité des menus d'appuis, des marqueurs et des messages vocaux/textuels du QG est localisée dans les 12 langues d'Arma 3 via les fichiers XML (`fn_initSupport.xml`, `fn_heliDispatch.xml`, `fn_heliManager.xml`, `fn_addResupplyAction.xml`).

---

## 4. Système de Sécurité et Automatisation des Portes IA (`fn_doorSecurity.sqf`)

Exécuté côté serveur dès le démarrage (`init.sqf`), ce système garantit une navigation fluide, réaliste et immersive pour toutes les unités d'infanterie IA à l'approche des bâtiments.

### Fonctionnement & Résolution des Défauts du Moteur :
* **Détection 3D Précise par Porte Individuelle :**
  * Au lieu de mesurer la distance par rapport au centre de gravité du bâtiment, le système calcule les coordonnées 3D exactes de chaque battant de porte (`_doorPos`) via les sélections mémoires du modèle (`Door_%1_trigger`, `Door_%1`, `Door_%1_axis`, etc.).
  * Seule la porte spécifique approchée par l'IA s'ouvre, évitant l'ouverture collective et irréaliste de toutes les portes d'un bâtiment.
* **Ouverture Anticipée à 4 Mètres (Élimination du Clipping) :**
  * Dès qu'une IA à pied s'approche à **moins de 4.0 m** d'une porte, celle-ci s'ouvre automatiquement.
  * Comme l'IA met environ 2 à 3 secondes pour parcourir ces 4 mètres, le battant est entièrement ouvert avant son arrivée sur le pas de porte : **l'IA ne heurte plus la géométrie solide fermée et ne traverse plus les portes par glitch physique**.
* **Tampon d'Hystérésis & Anti-Claquement :**
  * **Ouverture :** Déclenchée à `<= 4.0 m`.
  * **Fermeture sécurisée :** Déclenchée uniquement si **aucune unité** (IA ou joueur) n'est présente dans un rayon de **> 5.5 m**.
  * **Délai minimal d'ouverture :** La porte reste maintenue ouverte **au moins 4.0 secondes** après le passage de la dernière unité, permettant à toute une colonne de soldats de franchir l'ouverture sans que la porte ne se referme brutalement sur les suivants.
  * **Cooldown :** Verrouillage de 1.5 seconde entre deux transitions pour supprimer tout claquement frénétique ou oscillation.
* **Immersion Sonore Spatialisée :**
  * Bruitages de portes (`DoorWoodSingleOpen_1.wss` / `DoorWoodSingleClose_1.wss`) émis directement aux coordonnées 3D de la porte (`_doorPos`) avec une portée limitée à 15 m.
* **Respect des Portes Verrouillées et des Joueurs :**
  * Les portes verrouillées scénarisées (`bis_disabled_Door_%1`) restent hermétiquement closes.
  * Les portes ouvertes manuellement par un joueur ne sont pas refermées automatiquement par le script.

---

## 5. Système Acoustique de l'Appel à la Prière (`fn_playEzan.sqf`)

Géré côté serveur au démarrage (`init.sqf`), le système diffuse l'Ezan (`Music\ezan.ogg`, 142 secondes) de façon atmosphérique, réaliste et sans aucune cacophonie à travers le relief du Takistan.

### Optimisations Acoustiques & Anti-Cacophonie :
* **Conversion Audio Mono pour Véritable Spatialisation 3D :**
  * Le fichier `ezan.ogg` a été converti en **MONO (1 canal)** (sauvegarde de l'original stéréo conservée). Dans le moteur d'Arma 3, un son stéréo joué en 3D ne peut pas être spatialisé correctement et blast dans les deux oreilles en 2D. En mono, le moteur calcule avec précision l'orientation panoramique, la réverbération et l'atténuation physique en fonction de la position exacte du haut-parleur.
* **Regroupement Géographique en Clusters (< 350 m) :**
  * Si plusieurs haut-parleurs sont placés à proximité (ex: `ezan_00` et `ezan_01` sur le même rocher ou le même minaret), ils sont automatiquement fusionnés dans un même cluster.
  * **Un seul haut-parleur représentant diffuse le son par site.** Cela élimine à 100 % l'effet de filtrage en peigne (comb filtering), les voix métalliques et la cacophonie de deux pistes superposées à quelques mètres d'intervalle.
* **Écho Naturel de Vallée entre Villages Distants :**
  * Pour un joueur donné, le haut-parleur le plus proche démarre immédiatement (T = 0s) à pleine puissance avec une portée de 2000 m.
  * Si un second village distant (> 700 m du premier) se trouve dans la portée d'écoute (< 2000 m du joueur), il s'enclenche avec un **décalage réaliste de 2.2 à 3.4 secondes**, créant un écho lointain magnifique et immersif à travers les montagnes, sans jamais surcharger l'environnement sonore.
* **Verrouillage Mutex Anti-Chevauchement :**
  * Tant qu'un Ezan est en cours de diffusion (145 s), aucun autre Ezan ne peut être démarré.
* **Périodicité Réaliste :**
  * Premier appel entre 5 et 10 minutes après le début de mission, puis répétition périodique toutes les 20 à 30 minutes.

---

## 6. Reste du Projet (À modifier et adapter)

Tous les autres dossiers et fichiers présents dans `Functions/` :
- `Functions/Briefing/` (En attente de mise à jour des textes selon `INTEGR_BRIEFING.md`)
- `Functions/Civilian/`
- `Functions/Drone/`
- `Functions/Environment/` (à l'exception de `fn_randomWeather.sqf`, `fn_initSkills.sqf`, `fn_doorSecurity.sqf` et `fn_playEzan.sqf` qui sont actifs)
- `Functions/Player/` (à l'exception de `fn_initIdentity.sqf` et `fn_initLoadout.sqf`)
- `Functions/Task/` (à l'exception de `fn_intro_01.sqf`, `fn_intro_02.sqf`, `fn_spawnStartArsenal.sqf`, `fn_initVehicleLoadout.sqf`)

**Sont en attente d'implémentation.**  
Ne pas présumer de leur fonctionnement. Tout développement ultérieur doit se baser exclusivement sur les spécifications de l'éditeur (`INFO_EDITOR.md`, `INFO_TASKS.md`, `INFO_MENU.md`).
