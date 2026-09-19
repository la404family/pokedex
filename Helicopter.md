# Plan d'Optimisation : Hélicoptère de Soutien

Tu as totalement raison d'être en colère, je te présente mes excuses. Mon analyse précédente était beaucoup trop superficielle et n'a pas listé les éléments précis de ton code. J'ai maintenant lu en détail la **totalité** des 1122 lignes de `fn_heliManager.sqf`, ainsi que `fn_heliDispatch.sqf`.

Voici l'analyse complète de **TA** logique que j'ai identifiée et que je vais **préserver rigoureusement** :

## 1. Tes paramétrages de vol et de mission (Intouchables)
J'ai relevé toutes tes valeurs exactes. Elles ne seront pas modifiées :
- **Rayon de Spawn/Despawn dynamique :** Recherche d'une position sûre entre `2500m` et `8000m` via `_fnGetSpawnPos`. L'hélicoptère apparaît bien de nulle part et repart à cette position `_homeBase` pour être supprimé via `_fnRTB`.
- **Hauteurs de vol :**
  - Vitesse de croisière / Approche (`_flyHeight`) : **150m**
  - Hover pour largage (`_hoverHeight`) : **15m**
  - Loiter CAS (`_loiterHeight`) : **60m**
- **Paramétrages CAS :** Rayon de **250m**, durée de **180 secondes**, avec une hauteur forcée ASL, et une limitation de vitesse à **80 km/h** pour ne pas décrocher.
- **Paramétrages Dépose (Livraison/Véhicule) :** 
  - La caisse de munition prend une masse de **500** (`B_supplyCrate_F`), le véhicule **800** (`CUP_I_LR_MG_RACS`).
  - La descente progressive en `Hover` via `_descTimer`, avec largage automatique (`ropeDestroy`) quand la caisse est à moins de **3m** du sol (ou 0.5m pour le véhicule).
  - Le système de fumigène vert (`SmokeShellGreen`) et fumigènes blancs qui s'activent autour de la caisse.
- **Logique d'Extraction Complexe :** J'ai vu que ton extraction gère spécifiquement la récupération de VIP/Otages (`LL_Task00_Hostage`, `LL_Task02b_Hostage`, `LL_Task06_HVT`). Elle éjecte les mauvais joueurs avec un message d'avertissement, attend les VIP, puis déclenche la victoire (`BIS_fnc_endMission`) après 25 secondes de vol retour.
- **La mécanique de Dépose :** La gestion physique des caisses et véhicules (manipulation de la masse, `ropeDestroy`, stabilisation des vecteurs) restera inchangée.
- **L'Immersion Audio TTS (QG) :** C'est crucial : tous les appels à `LL_fnc_radioMessage` (pour déclencher tes audios générés avec le script Python dans le dossier `TTS`) seront intégralement conservés ! Que ce soit pour l'approbation du vol, le largage de munitions ou l'arrivée sur la LZ, le QG continuera de parler via la radio avec les mêmes clés `STR_...`.

## 2. Ce que l'on supprime (Le nettoyage)
- **La logique Multijoueur & Débarquement ("DEBARQUEMENT") :** Les lignes 520 à 759 de `_fnExecDeploy` gèrent le parachutage de nouvelles IA (classe `CUP_I_RACS_Soldier_...`), la manipulation des loadouts aléatoires, et le `selectPlayer` pour les joueurs morts (`LL_g_deadPlayers`). Vu que ta mission est strictement Solo avec 6 IA fixes, cette logique est obsolète et dangereuse. Elle sera purgée.
- **Le système `addAction` :** Fini les actions molette (`fn_addHelicopterActions.sqf`). 

## 3. Ce que l'on intègre (Le Menu Natif Arma 3)
Au lieu des `addAction`, nous allons créer une classe `CfgCommunicationMenu` dans `description.ext`. 
Le joueur utilisera la touche `0` puis `8` (Soutien) pour ouvrir le menu natif, qui enverra les mêmes ordres à ta file d'attente (`fn_heliDispatch.sqf`) :
1. **Soutien : Ravitaillement** (Appelle "LIVRAISON")
2. **Soutien : Véhicule Léger** (Appelle "VEHICULE")
3. **Soutien : Extraction** (Appelle "EMBARQUEMENT")
4. **Soutien : CAS** (Appelle "CAS")

> [!IMPORTANT]
> **Validation Requise**
> Tu as la preuve que j'ai lu tes 1122 lignes et identifié tes sécurités (masses, timeouts, VIP extraction). Je te garantis que tes paramètres de vol et de dépose resteront intacts. Mon seul travail sera de brancher ton script sur le menu `0-8` natif et d'effacer la partie parachutage IA. 
> Me donnes-tu l'autorisation d'implémenter cette optimisation (création du CfgCommunicationMenu et nettoyage du script) ?
