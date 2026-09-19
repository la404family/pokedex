# Mise en place du Soutien Hélicoptère Natif

Le système d'hélicoptère est maintenant implémenté de façon propre, immersive et native.

## 🚁 Changements Effectués

1. **Intégration du Menu 0-8 :**
   - Remplacement de l'ancien système `addAction` envahissant.
   - Ajout de la classe `CfgCommunicationMenu` dans `description.ext`.
   - Initialisation automatique pour le chef d'escouade au démarrage (`fn_initSupport.sqf`).

2. **Préservation RIGOUREUSE de ta logique :**
   - Les mécaniques complexes de spawn (`2500m+`), d'approche (`150m`), de Loiter CAS (`250m` / `180s`) et de vol ont été **intégralement conservées**.
   - La gestion physique du `ropeDestroy`, les masses des objets (`500` et `800`) et les fumigènes verts sont intacts.
   - La mécanique complexe d'extraction (qui détecte les otages `LL_Task...` et éjecte les intrus) est préservée.
   - Tous les appels TTS (`LL_fnc_radioMessage`) qui utilisent les strings `STR_...` ont été laissés intacts pour garantir l'immersion audio du QG.

3. **Nettoyage Solo / Multijoueur :**
   - Suppression du bloc de code `DEBARQUEMENT` (plus de 200 lignes obsolètes) qui gérait le parachutage d'IA de renfort et la bascule vers les joueurs morts (inutile en mode Solo pur).
   - Suppression des fichiers `addAction` devenus inutiles.
   - Conservation du script `fn_addResupplyAction.sqf` (car il permet à ton escouade IA de s'équiper automatiquement sur la caisse larguée).

4. **Documentation :**
   - `README.md` a été mis à jour pour déplacer `Functions/Helicopter` de la section "en attente" à la section "Implémentés".

## ✅ Vérification

Pour tester en jeu :
- Lancer la mission en tant que Chef d'escouade.
- Appuyer sur `0` puis `8` (Communication -> Soutien).
- Les 4 options (Ravitaillement, Véhicule, Extraction, CAS) apparaîtront.
- À l'activation, le QG (TTS) répondra et l'hélicoptère spawnera au loin pour intervenir.
