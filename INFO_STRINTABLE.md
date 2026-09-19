# 🛠️ Méthode d'Intégration et de Traduction (Stringtable)

## 1. Règles Générales de Langue

- **Langue Principale :** L'**Anglais** est la langue principale de référence de la mission.
- **Balises `<Original>` et `<English>` :** Doivent impérativement être rédigées en anglais.
- **Traduction Multi-Langues Obligatoire :** Tous les textes du jeu doivent être traduits dans l'ensemble des langues supportées par Arma 3.

---

## 2. Méthode d'Intégration Non Destructive

Les textes de la mission sont compilés par un script Python (`compile_stringtable.py`). Il ne faut **pas** modifier manuellement `stringtable.xml` sous peine de voir les modifications écrasées lors de la prochaine génération.

La méthode propre consiste à ajouter les définitions dans l'un des fichiers XML sources à côté du script SQF correspondant (par exemple `fn_addDroneAction.sqf` → `fn_addDroneAction.xml`), puis à régénérer la stringtable globale.

---

## 3. Procédure Pas à Pas

1. Créez ou modifiez le fichier XML à côté de votre script SQF (ex: `fn_addDroneAction.xml`).
2. Ajoutez vos clés de traduction en incluant toutes les langues d'Arma 3 :

```xml
<?xml version="1.0" encoding="utf-8"?>
<Keys>
    <Key ID="STR_Drone_Surveillance">
        <Original>[DRONE] Surveillance</Original>
        <English>[DRONE] Surveillance</English>
        <French>[DRONE] Surveillance</French>
        <Spanish>[DRON] Vigilancia</Spanish>
        <German>[DROHNE] Überwachung</German>
        <Italian>[DRONE] Sorveglianza</Italian>
        <Polish>[DRON] Inwigilacja</Polish>
        <Portuguese>[DRONE] Vigilância</Portuguese>
        <Russian>[БПЛА] Наблюдение</Russian>
        <Czech>[DRON] Sledování</Czech>
        <Korean>[드론] 감시</Korean>
        <Japanese>[ドローン] 監視</Japanese>
        <Chinese>[無人機] 監視</Chinese>
        <Chinesesimp>[无人机] 监视</Chinesesimp>
        <Turkish>[İHA] Gözetleme</Turkish>
    </Key>
</Keys>
```

3. Dans votre fichier SQF, utilisez la clé localisée : `localize "STR_Drone_Surveillance"`.
4. Exécutez le script `compile_stringtable.py` pour régénérer le fichier `stringtable.xml` global.
