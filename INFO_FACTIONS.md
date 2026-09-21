# INFO_FACTIONS.md — Spécification Complète des Factions de la Mission

Ce document définit le rôle, l'identité, l'équipement et les objectifs stratégiques de chaque faction présente dans la mission *Takistan Restored*.

---

## ⚠️ RÈGLE GLOBALE D'IDENTITÉ TAKISTANAISE

À l'exception des unités de la Légion Étrangère du RACS (**INDEPENDENT**), **TOUTES les autres factions du jeu (BLUFOR, OPFOR, CIVILIAN) sont composées d'unités takistanaises locales**.

Leur identité visuelle, vestimentaire et vocale est générée de manière dynamique via la fonction :
👉 [`Functions/Civilian/fn_applyTakistaniIdentity.sqf`](file:///c:/Users/kevin/Documents/Arma%203/missions/takistanRestored.takistan/Functions/Civilian/fn_applyTakistaniIdentity.sqf)

### Caractéristiques de l'Identité Takistanaise :
* **Noms & Visages :** Génération aléatoire à partir de la base de données takistanaise (`MISSION_CivilianNames_Male`, `MISSION_CivilianNames_Female`, `MISSION_CivilianMaleFaces`).
* **Voix :** Voix persanes natives (`Male01PER`, `Male02PER`, `Male03PER`).
* **Apparence & Vêtements :** Tenues traditionnelles orientales, 100% de coiffes pour les hommes (Lungee, Pakol, SkullCap), barbes (`CUP_Beard_Brown`, `CUP_Beard_Black`) et vestes civiles.
* **Armement & Sacs (Unités Armées) :** Attribution dynamique des armes légères (`MISSION_BanditWeapons`), sacs (`MISSION_BanditBackpacks`), munitions et équipements tactiques.

---

## 1. INDEPENDENT (Vert) — Légion Étrangère du RACS (*RACS Foreign Legion*)

* **Nature :** Force militaire d'élite du Royaume de Sahrani.
* **Composition :** L'escouade jouable de 6 hommes (`player_0` à `player_5`). C'est la seule faction non-takistanaise d'origine.
* **Identité & Équipement :**
  * Gilets tactiques JPC RACS (`CUP_V_JPC_*`).
  * Insigne officiel de la Légion RACS (`Images/racs_badge_ca.paa`).
  * Vecteurs de soutien : Hélicoptère UH-60L RACS (`CUP_I_UH60L_FFV_RACS`), Avion C-130J (`CUP_I_C130J_RACS`), Drone MQ-9 et Land Rover MG (`CUP_I_LR_MG_RACS`).
* **Objectifs Stratégiques :**
  1. **Pacification du Territoire :** Déployer la force expéditionnaire pour purger les zones urbaines et rurales des insurgés.
  2. **Opérations Spéciales & Démantèlement :** Traquer les chefs de faction ennemis (HVT), détruire les dépôts chimiques/d'armes et désamorcer les menaces explosives.
  3. **Soutien des Alliés Locaux :** Appuyer la milice civile alliée (BLUFOR) et secourir les otages/VIPs civils sans faire de victimes innocentes.
  4. **Enjeu Géopolitique Majeur :** Stabiliser le Takistan sous l'influence du Royaume de Sahrani afin d'empêcher une intervention armée directe des superpuissances étrangères.

---

## 2. BLUFOR (Bleu) — Milices Civiles Alliées Takistanaises

* **Nature :** Forces de défense locales et milices civiles pro-gouvernementales du Takistan.
* **Composition :** Unités locales takistanaises armées luttant aux côtés du RACS.
* **Identité & Équipement :**
  * Générés via [`fn_applyTakistaniIdentity.sqf`](file:///c:/Users/kevin/Documents/Arma%203/missions/takistanRestored.takistan/Functions/Civilian/fn_applyTakistaniIdentity.sqf).
  * Tenues traditionnelles takistanaises, turbans, pakols et barbes.
  * Armement d'insurrection et de défense locale.
* **Objectifs Stratégiques :**
  1. **Défense des Villages :** Protéger leurs communautés et leurs familles contre les attaques et les pillages des milices ennemies (OPFOR).
  2. **Assistance au RACS :** Offrir un appui tactique et territorial à la Légion Étrangère du RACS pour sécuriser le secteur.

---

## 3. OPFOR (Rouge) — Milices Ennemies & Insurgés Takistanais

* **Nature :** Groupes armés rebelles, milices extrémistes et insurgés du Takistan.
* **Composition :** Combattants locaux hostiles répartis dans les zones rurales, montagnes et bastions urbains.
* **Identité & Équipement :**
  * Générés via [`fn_applyTakistaniIdentity.sqf`](file:///c:/Users/kevin/Documents/Arma%203/missions/takistanRestored.takistan/Functions/Civilian/fn_applyTakistaniIdentity.sqf) avec le paramètre `_isEnemy = true`.
  * Tenues civiles/combattants locales, armement lourd/fusils d'assaut (`MISSION_BanditWeapons`), sacs à dos (`MISSION_BanditBackpacks`), radios et équipement de guérilla.
* **Objectifs Stratégiques :**
  1. **Guerre d'Usure :** Traquer et éliminer les patrouilles du RACS (INDEPENDENT) et écraser la milice civile alliée (BLUFOR).
  2. **Terreur & Subversion :** Contrôler les villes par la force, prendre des otages/VIPs, implanter des émetteurs radio de propagande et utiliser des dépôts d'armes chimiques/explosives.

---

## 4. CIVILIAN (Violet / Rose) — Population Civile Takistanaise & Faune

* **Nature :** Population civile locale non-armée et faune sauvage (`sideAmbientLife`).
* **Composition :** Hommes, femmes, commerçants, habitants des villes/villages, animaux de ferme (moutons).
* **Identité & Équipement :**
  * Identité takistanaise civile pure via [`fn_applyTakistaniIdentity.sqf`](file:///c:/Users/kevin/Documents/Arma%203/missions/takistanRestored.takistan/Functions/Civilian/fn_applyTakistaniIdentity.sqf) (aucun armement).
  * Tenues traditionnelles locales (robes, turbans, voiles pour les femmes).
* **Objectifs Stratégiques :**
  1. **Survie :** Tenter de poursuivre leurs activités quotidiennes et déplacements inter-zones malgré la guerre civile.
  2. **Mise à l'Abri :** Fuir et se réfugier dans les habitations dès qu'un affrontement armé éclate à proximité (`FiredNear`).

---

## 📊 Tableau Récapitulatif des Factions

| Camp Engine | Faction en Jeu | Origine | Identité Visuelle / Vocale | Armement / Équipement |
| :--- | :--- | :--- | :--- | :--- |
| **INDEPENDENT** | **RACS Foreign Legion** | Internationale (Sahrani) | Militaire Pro / Insigne RACS | Gilets JPC, UH-60L, C-130J, LR MG |
| **BLUFOR** | **Milices Civiles Alliées** | Takistan | Takistanaise (`fn_applyTakistaniIdentity.sqf`) | Armes légères, tenues locales |
| **OPFOR** | **Milices Ennemies Insurgées** | Takistan | Takistanaise (`fn_applyTakistaniIdentity.sqf`, `_isEnemy`) | `MISSION_BanditWeapons`, Sacs, Radios |
| **CIVILIAN** | **Civils & Faune Locale** | Takistan | Takistanaise (`fn_applyTakistaniIdentity.sqf`) | Sans armes, tenues locales |
