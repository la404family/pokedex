# 🛠️ INFO_IDENTITY.md — Système Global d'Identité Takistanaise

Ce document définit les règles, les variables et le fonctionnement du nouveau système d'identité globale pour la mission Takistan Restored. Ce système a pour but de fournir une identité cohérente (noms, vêtements, visages, voix) à TOUTES les unités de type "Takistanaises" du jeu, en séparant strictement les hommes et les femmes.

> **Rappel Faction :** Les unités de l'escouade du joueur appartiennent à la faction **Indépendant (Vert - RACS)**.

---

## 1. Proposition de Renommage du Dossier

Actuellement, les scripts se trouvent dans `Functions/Civilian/`.
Étant donné que le système s'appliquera à **toutes les unités** (civils, insurgés, ennemis, etc.), il est recommandé de renommer ce dossier pour refléter sa fonction globale.

- **Nom de dossier proposé :** `Functions/Identity`
- *Si validé, ce dossier contiendra toutes les fonctions liées à la génération d'identités (joueurs et PNJ).*

---

## 2. Variables Récupérées (Actuellement dans `fn_initCivilians.sqf`)

Nous disposons déjà d'une base de données très complète pour générer les identités :

### A. Noms Takistanais

<details>
<summary><b>Afficher les variables (Noms Hommes et Femmes)</b></summary>

```sqf
MISSION_CivilianNames_Male = [
    ["Afaq Khan",             "Afaq",       "Khan"],
    ["Akhtar Durrani",        "Akhtar",     "Durrani"],
    ["Anis Kakar",            "Anis",       "Kakar"],
    ["Azad Mousavi",          "Azad",       "Mousavi"],
    ["Faisal Karimi",         "Faisal",     "Karimi"],
    ["Habib Noori",           "Habib",      "Noori"],
    ["Jalil Hashemi",         "Jalil",      "Hashemi"],
    ["Karim Jafari",          "Karim",      "Jafari"],
    ["Omar Faizi",            "Omar",       "Faizi"],
    ["Rashid Taheri",         "Rashid",     "Taheri"],
    ["Abbas Alizadeh",        "Abbas",      "Alizadeh"],
    ["Abdullah Wardak",       "Abdullah",   "Wardak"],
    ["Adel Termos",           "Adel",       "Termos"],
    ["Adnan Malik",           "Adnan",      "Malik"],
    ["Ahmad Shah",            "Ahmad",      "Shah"],
    ["Ali Rezaei",            "Ali",        "Rezaei"],
    ["Amin Maalouf",          "Amin",       "Maalouf"],
    ["Amir Hosseini",         "Amir",       "Hosseini"],
    ["Amjad Sabri",           "Amjad",      "Sabri"],
    ["Arash Kamali",          "Arash",      "Kamali"],
    ["Arsalan Kazemi",        "Arsalan",    "Kazemi"],
    ["Asadullah Khalid",      "Asadullah",  "Khalid"],
    ["Ashraf Baradar",        "Ashraf",     "Baradar"],
    ["Atiq Rahimi",           "Atiq",       "Rahimi"],
    ["Ayman Odeh",            "Ayman",      "Odeh"],
    ["Aziz Ansari",           "Aziz",       "Ansari"],
    ["Babur Dostum",          "Babur",      "Dostum"],
    ["Bahram Radan",          "Bahram",     "Radan"],
    ["Baktash Siawash",       "Baktash",    "Siawash"],
    ["Bashir Ahmad",          "Bashir",     "Ahmad"],
    ["Bassam Tibi",           "Bassam",     "Tibi"],
    ["Behrouz Vosooghi",      "Behrouz",    "Vosooghi"],
    ["Bilal Mansour",         "Bilal",      "Mansour"],
    ["Boulos Khoury",         "Boulos",     "Khoury"],
    ["Cyrus Zarei",           "Cyrus",      "Zarei"],
    ["Danish Karokhel",       "Danish",     "Karokhel"],
    ["Dariush Eghbali",       "Dariush",    "Eghbali"],
    ["Dawood Sarkhosh",       "Dawood",     "Sarkhosh"],
    ["Ehsan Aman",            "Ehsan",      "Aman"],
    ["Elias Yasin",           "Elias",      "Yasin"],
    ["Emal Zakarya",          "Emal",       "Zakarya"],
    ["Esmail Khoi",           "Esmail",     "Khoi"],
    ["Fahim Dashty",          "Fahim",      "Dashty"],
    ["Farhad Darya",          "Farhad",     "Darya"],
    ["Farid Zaland",          "Farid",      "Zaland"],
    ["Farzad Farzin",         "Farzad",     "Farzin"],
    ["Fawad Ramiz",           "Fawad",      "Ramiz"],
    ["Faysal Qureshi",        "Faysal",     "Qureshi"],
    ["Fouad Ajami",           "Fouad",      "Ajami"],
    ["Ghafoor Bakhsh",        "Ghafoor",    "Bakhsh"],
    ["Ghassan Kanafani",      "Ghassan",    "Kanafani"],
    ["Ghulam Haider",         "Ghulam",     "Haider"],
    ["Gulbuddin Hekmatyar",   "Gulbuddin",  "Hekmatyar"],
    ["Hafez Assad",           "Hafez",      "Assad"],
    ["Hamid Karzai",          "Hamid",      "Karzai"],
    ["Hamza Yusuf",           "Hamza",      "Yusuf"],
    ["Haroon Yusufi",         "Haroon",     "Yusufi"],
    ["Hassan Rouhani",        "Hassan",     "Rouhani"],
    ["Hekmat Khalil",         "Hekmat",     "Khalil"],
    ["Hesam Din",             "Hesam",      "Din"],
    ["Homayoun Shajarian",    "Homayoun",   "Shajarian"],
    ["Hossein Alizadeh",      "Hossein",    "Alizadeh"],
    ["Ibrahim Maalouf",       "Ibrahim",    "Maalouf"],
    ["Idris Sadiqi",          "Idris",      "Sadiqi"],
    ["Ilyas Kashmiri",        "Ilyas",      "Kashmiri"],
    ["Imran Khan",            "Imran",      "Khan"],
    ["Ismael Jalal",          "Ismael",     "Jalal"],
    ["Jabbar Patel",          "Jabbar",     "Patel"],
    ["Jafar Panahi",          "Jafar",      "Panahi"],
    ["Jalal Talabani",        "Jalal",      "Talabani"],
    ["Jamal Khashoggi",       "Jamal",      "Khashoggi"],
    ["Jamil Sadeqi",          "Jamil",      "Sadeqi"],
    ["Javed Akhtar",          "Javed",      "Akhtar"],
    ["Jawad Sharif",          "Jawad",      "Sharif"],
    ["Kabir Bedi",            "Kabir",      "Bedi"],
    ["Kamal Salibi",          "Kamal",      "Salibi"],
    ["Kamran Hooman",         "Kamran",     "Hooman"],
    ["Kasra Nouri",           "Kasra",      "Nouri"],
    ["Kaveh Ahangar",         "Kaveh",      "Ahangar"],
    ["Khalid Hosseini",       "Khalid",     "Hosseini"],
    ["Khalil Zad",            "Khalil",     "Zad"],
    ["Khosrow Shakibai",      "Khosrow",    "Shakibai"],
    ["Kianoush Ayari",        "Kianoush",   "Ayari"],
    ["Latif Pedram",          "Latif",      "Pedram"],
    ["Mahdi Darius",          "Mahdi",      "Darius"],
    ["Mahmood Khan",          "Mahmood",    "Khan"],
    ["Majid Majidi",          "Majid",      "Majidi"],
    ["Malek Jahan",           "Malek",      "Jahan"],
    ["Mansour Bahrami",       "Mansour",    "Bahrami"],
    ["Marwan Barghouti",      "Marwan",     "Barghouti"],
    ["Masoud Shojaei",        "Masoud",     "Shojaei"],
    ["Mehdi Mahdavikia",      "Mehdi",      "Mahdavikia"],
    ["Mirwais Nejat",         "Mirwais",    "Nejat"],
    ["Mohammad Reza",         "Mohammad",   "Reza"],
    ["Mohsen Makhmalbaf",     "Mohsen",     "Makhmalbaf"],
    ["Morteza Pashaei",       "Morteza",    "Pashaei"],
    ["Munir Bashir",          "Munir",      "Bashir"],
    ["Mustafa Sandal",        "Mustafa",    "Sandal"],
    ["Nabil Shoail",          "Nabil",      "Shoail"],
    ["Nader Shah",            "Nader",      "Shah"],
    ["Naguib Mahfouz",        "Naguib",     "Mahfouz"],
    ["Najibullah Ahmadzai",   "Najibullah", "Ahmadzai"],
    ["Naseeruddin Shah",      "Naseeruddin","Shah"],
    ["Nasser Al-Attiyah",     "Nasser",     "Al-Attiyah"],
    ["Navid Negahban",        "Navid",      "Negahban"],
    ["Nizar Qabbani",         "Nizar",      "Qabbani"],
    ["Omid Djalili",          "Omid",       "Djalili"],
    ["Osman Mir",             "Osman",      "Mir"],
    ["Parviz Parastui",       "Parviz",     "Parastui"],
    ["Payam Dehkordi",        "Payam",      "Dehkordi"],
    ["Qais Ulfat",            "Qais",       "Ulfat"],
    ["Qasim Soleimani",       "Qasim",      "Soleimani"],
    ["Rafik Hariri",          "Rafik",      "Hariri"],
    ["Rahim Shah",            "Rahim",      "Shah"],
    ["Rahman Baba",           "Rahman",     "Baba"],
    ["Rami Malek",            "Rami",       "Malek"],
    ["Ramzi Yousef",          "Ramzi",      "Yousef"],
    ["Reza Attaran",          "Reza",       "Attaran"],
    ["Rostam Farrokhzad",     "Rostam",     "Farrokhzad"],
    ["Saami Yusuf",           "Saami",      "Yusuf"],
    ["Saeed Rad",             "Saeed",      "Rad"],
    ["Salahuddin Rabbani",    "Salahuddin", "Rabbani"],
    ["Salim Shaheen",         "Salim",      "Shaheen"],
    ["Salman Khan",           "Salman",     "Khan"],
    ["Saman Jalili",          "Saman",      "Jalili"],
    ["Sardar Azmoun",         "Sardar",     "Azmoun"],
    ["Shahrukh Khan",         "Shahrukh",   "Khan"],
    ["Shahzad Ismaily",       "Shahzad",    "Ismaily"],
    ["Shams Langroudi",       "Shams",      "Langroudi"],
    ["Sohrab Sepehri",        "Sohrab",     "Sepehri"],
    ["Sulaiman Layeq",        "Sulaiman",   "Layeq"],
    ["Tahir Qadri",           "Tahir",      "Qadri"],
    ["Tarek Fatah",           "Tarek",      "Fatah"],
    ["Tariq Ramadan",         "Tariq",      "Ramadan"],
    ["Ubaidullah Jan",        "Ubaidullah", "Jan"],
    ["Vahid Amiri",           "Vahid",      "Amiri"],
    ["Walid Al-Shehri",       "Walid",      "Al-Shehri"],
    ["Waseem Badami",         "Waseem",     "Badami"],
    ["Yasin Malik",           "Yasin",      "Malik"],
    ["Yasser Arafat",         "Yasser",     "Arafat"],
    ["Yousef Chahine",        "Yousef",     "Chahine"],
    ["Zalmay Khalilzad",      "Zalmay",     "Khalilzad"],
    ["Zarif Zarif",           "Zarif",      "Zarif"],
    ["Zayn Malik",            "Zayn",       "Malik"],
    ["Zia Massoud",           "Zia",        "Massoud"]
];

MISSION_CivilianNames_Female = [
    ["Aadila Nouri",          "Aadila",     "Nouri"],
    ["Aaliyah Massoud",       "Aaliyah",    "Massoud"],
    ["Amani Rahimi",          "Amani",      "Rahimi"],
    ["Anisa Wahab",           "Anisa",      "Wahab"],
    ["Bahar Pars",            "Bahar",      "Pars"],
    ["Fatima Bhutto",         "Fatima",     "Bhutto"],
    ["Ghazal Sadat",          "Ghazal",     "Sadat"],
    ["Jamila Afghani",        "Jamila",     "Afghani"],
    ["Kubra Khademi",         "Kubra",      "Khademi"],
    ["Latifa Nabizada",       "Latifa",     "Nabizada"],
    ["Malalai Joya",          "Malalai",    "Joya"],
    ["Sima Samar",            "Sima",       "Samar"],
    ["Abir Al-Sahlani",       "Abir",       "Al-Sahlani"],
    ["Afra Jalil",            "Afra",       "Jalil"],
    ["Aisha Wardak",          "Aisha",      "Wardak"],
    ["Aleena Khan",           "Aleena",     "Khan"],
    ["Alia Zadeh",            "Alia",       "Zadeh"],
    ["Almas Durrani",         "Almas",      "Durrani"],
    ["Amal Alamuddin",        "Amal",       "Alamuddin"],
    ["Amira Casar",           "Amira",      "Casar"],
    ["Anahita Ratebzad",      "Anahita",    "Ratebzad"],
    ["Anbar Nadiya",          "Anbar",      "Nadiya"],
    ["Aqsa Parvez",           "Aqsa",       "Parvez"],
    ["Ara Qadir",             "Ara",        "Qadir"],
    ["Areeba Habib",          "Areeba",     "Habib"],
    ["Arezoo Tanha",          "Arezoo",     "Tanha"],
    ["Arwa Damon",            "Arwa",       "Damon"],
    ["Asal Badiee",           "Asal",       "Badiee"],
    ["Asma Jahangir",         "Asma",       "Jahangir"],
    ["Asra Nomani",           "Asra",       "Nomani"],
    ["Atefeh Razavi",         "Atefeh",     "Razavi"],
    ["Azadeh Moaveni",        "Azadeh",     "Moaveni"],
    ["Aziza Siddiqui",        "Aziza",      "Siddiqui"],
    ["Azra Akrami",           "Azra",       "Akrami"],
    ["Badra Ali",             "Badra",      "Ali"],
    ["Bahira Sherif",         "Bahira",     "Sherif"],
    ["Balqis Ahmed",          "Balqis",     "Ahmed"],
    ["Banu Ghazanfar",        "Banu",       "Ghazanfar"],
    ["Baran Kosari",          "Baran",      "Kosari"],
    ["Baria Alamuddin",       "Baria",      "Alamuddin"],
    ["Basma Hassan",          "Basma",      "Hassan"],
    ["Batool Fakoor",         "Batool",     "Fakoor"],
    ["Bayan Mahmoud",         "Bayan",      "Mahmoud"],
    ["Beheshta Arghand",      "Beheshta",   "Arghand"],
    ["Behnaz Jafari",         "Behnaz",     "Jafari"],
    ["Benafsha Yaqoobi",      "Benafsha",   "Yaqoobi"],
    ["Bushra Maneka",         "Bushra",     "Maneka"],
    ["Dalia Mogahed",         "Dalia",      "Mogahed"],
    ["Dana Ghazi",            "Dana",       "Ghazi"],
    ["Dania Khatib",          "Dania",      "Khatib"],
    ["Darya Safai",           "Darya",      "Safai"],
    ["Deena Aljuhani",        "Deena",      "Aljuhani"],
    ["Delaram Karkhir",       "Delaram",    "Karkhir"],
    ["Delbar Nazari",         "Delbar",     "Nazari"],
    ["Dorsa Derakhshani",     "Dorsa",      "Derakhshani"],
    ["Dua Khalil",            "Dua",        "Khalil"],
    ["Durkhanai Ayubi",       "Durkhanai",  "Ayubi"],
    ["Elaha Soroor",          "Elaha",      "Soroor"],
    ["Elham Shahin",          "Elham",      "Shahin"],
    ["Elnaz Shakerdoost",     "Elnaz",      "Shakerdoost"],
    ["Esra Bilgic",           "Esra",       "Bilgic"],
    ["Faiza Darkhani",        "Faiza",      "Darkhani"],
    ["Fakhria Khalil",        "Fakhria",    "Khalil"],
    ["Farah Pahlavi",         "Farah",      "Pahlavi"],
    ["Farangis Yeganegi",     "Farangis",   "Yeganegi"],
    ["Farhana Qasimi",        "Farhana",    "Qasimi"],
    ["Fariba Hachtroudi",     "Fariba",     "Hachtroudi"],
    ["Farkhunda Zahra",       "Farkhunda",  "Zahra"],
    ["Farzaneh Kaboli",       "Farzaneh",   "Kaboli"],
    ["Fatemeh Motamed",       "Fatemeh",    "Motamed"],
    ["Fawzia Koofi",          "Fawzia",     "Koofi"],
    ["Fereshteh Kazemi",      "Fereshteh",  "Kazemi"],
    ["Fida Qasemi",           "Fida",       "Qasemi"],
    ["Forough Farrokhzad",    "Forough",    "Farrokhzad"],
    ["Fozia Koofi",           "Fozia",      "Koofi"],
    ["Freshta Karim",         "Freshta",    "Karim"],
    ["Geeti Pasha",           "Geeti",      "Pasha"],
    ["Gelareh Abbasi",        "Gelareh",    "Abbasi"],
    ["Ghadir Mounib",         "Ghadir",     "Mounib"],
    ["Golshifteh Farahani",   "Golshifteh", "Farahani"],
    ["Habiba Sarabi",         "Habiba",     "Sarabi"],
    ["Hadia Tajik",           "Hadia",      "Tajik"],
    ["Hafsa Zayyan",          "Hafsa",      "Zayyan"],
    ["Haifa Wehbe",           "Haifa",      "Wehbe"],
    ["Hala Gorani",           "Hala",       "Gorani"],
    ["Hamida Barmaki",        "Hamida",     "Barmaki"],
    ["Hangama Zohra",         "Hangama",    "Zohra"],
    ["Hania Amir",            "Hania",      "Amir"],
    ["Hasina Safi",           "Hasina",     "Safi"],
    ["Hawa Alam",             "Hawa",       "Alam"],
    ["Hayat Mirshad",         "Hayat",      "Mirshad"],
    ["Hediyeh Tehrani",       "Hediyeh",    "Tehrani"],
    ["Hina Rabbani",          "Hina",       "Rabbani"],
    ["Hind Rostom",           "Hind",       "Rostom"],
    ["Homa Darabi",           "Homa",       "Darabi"],
    ["Homira Qaderi",         "Homira",     "Qaderi"],
    ["Huda Kattan",           "Huda",       "Kattan"],
    ["Iman Abdulmajid",       "Iman",       "Abdulmajid"],
    ["Kamila Sidiqi",         "Kamila",     "Sidiqi"],
    ["Kawsar Sharifi",        "Kawsar",     "Sharifi"],
    ["Khadija Bashir",        "Khadija",    "Bashir"],
    ["Laila Freivalds",       "Laila",      "Freivalds"],
    ["Laila Haidari",         "Laila",      "Haidari"],
    ["Layla Murad",           "Layla",      "Murad"],
    ["Leena Alam",            "Leena",      "Alam"],
    ["Leila Hatami",          "Leila",      "Hatami"],
    ["Lima Azimi",            "Lima",       "Azimi"],
    ["Lina Ben Mhenni",       "Lina",       "Ben Mhenni"],
    ["Mahbouba Seraj",        "Mahbouba",   "Seraj"],
    ["Mahira Khan",           "Mahira",     "Khan"],
    ["Manal al-Sharif",       "Manal",      "al-Sharif"],
    ["Mariam Durrani",        "Mariam",     "Durrani"],
    ["Mariam Ghani",          "Mariam",     "Ghani"],
    ["Marjane Satrapi",       "Marjane",    "Satrapi"],
    ["Marwa Elselehdar",      "Marwa",      "Elselehdar"],
    ["Maryam Monsef",         "Maryam",     "Monsef"],
    ["Massouda Jalal",        "Massouda",   "Jalal"],
    ["Meena Keshwar",         "Meena",      "Keshwar"],
    ["Mehrnaz Dabir",         "Mehrnaz",    "Dabir"],
    ["Mina Mangal",           "Mina",       "Mangal"],
    ["Mitra Hajjar",          "Mitra",      "Hajjar"],
    ["Mona Zaki",             "Mona",       "Zaki"],
    ["Mozhdah Jamalzadah",    "Mozhdah",    "Jamalzadah"],
    ["Muna Wassef",           "Muna",       "Wassef"],
    ["Muniba Mazari",         "Muniba",     "Mazari"],
    ["Nadia Anjuman",         "Nadia",      "Anjuman"],
    ["Naghma Shaperai",       "Naghma",     "Shaperai"],
    ["Nahid Persson",         "Nahid",      "Persson"],
    ["Nargis Fakhri",         "Nargis",     "Fakhri"],
    ["Nargis Nehan",          "Nargis",     "Nehan"],
    ["Nasrin Sotoudeh",       "Nasrin",     "Sotoudeh"],
    ["Nawal El Saadawi",      "Nawal",      "El Saadawi"],
    ["Nelofer Pazira",        "Nelofer",    "Pazira"],
    ["Niki Karimi",           "Niki",       "Karimi"],
    ["Niloufar Ardalan",      "Niloufar",   "Ardalan"],
    ["Niloufar Bayat",        "Niloufar",   "Bayat"],
    ["Noor Jahan",            "Noor",       "Jahan"],
    ["Palwasha Hassan",       "Palwasha",   "Hassan"],
    ["Parvin Etesami",        "Parvin",     "Etesami"],
    ["Parwana Amiri",         "Parwana",    "Amiri"],
    ["Qamar Gul",             "Qamar",      "Gul"],
    ["Rabea Balkhi",          "Rabea",      "Balkhi"],
    ["Rahima Jami",           "Rahima",     "Jami"],
    ["Rania Al-Abdullah",     "Rania",      "Al-Abdullah"],
    ["Reem Abdullah",         "Reem",       "Abdullah"],
    ["Rola Ghani",            "Rola",       "Ghani"],
    ["Roxana Saberi",         "Roxana",     "Saberi"],
    ["Roya Mahboob",          "Roya",       "Mahboob"],
    ["Saba Qamar",            "Saba",       "Qamar"],
    ["Sahraa Karimi",         "Sahraa",     "Karimi"],
    ["Sajal Aly",             "Sajal",      "Aly"],
    ["Salma Zadeh",           "Salma",      "Zadeh"],
    ["Samira Makhmalbaf",     "Samira",     "Makhmalbaf"],
    ["Sanam Baloch",          "Sanam",      "Baloch"],
    ["Sarah Shahi",           "Sarah",      "Shahi"],
    ["Seeta Qasemi",          "Seeta",      "Qasemi"],
    ["Shabana Azmi",          "Shabana",    "Azmi"],
    ["Shaharzad Akbar",       "Shaharzad",  "Akbar"],
    ["Shirin Ebadi",          "Shirin",     "Ebadi"],
    ["Shukria Barakzai",      "Shukria",    "Barakzai"],
    ["Soheila Siddiq",        "Soheila",    "Siddiq"],
    ["Soraya Tarzi",          "Soraya",     "Tarzi"],
    ["Tahmina Alvi",          "Tahmina",    "Alvi"],
    ["Tahmineh Milani",       "Tahmineh",   "Milani"],
    ["Taraneh Alidoosti",     "Taraneh",    "Alidoosti"],
    ["Vida Samadzai",         "Vida",       "Samadzai"],
    ["Wazhma Frogh",          "Wazhma",     "Frogh"],
    ["Yalda Hakim",           "Yalda",      "Hakim"],
    ["Yasmin Levy",           "Yasmin",     "Levy"],
    ["Zainab Salbi",          "Zainab",     "Salbi"],
    ["Zara Kayani",           "Zara",       "Kayani"],
    ["Zarghona Walid",        "Zarghona",   "Walid"],
    ["Zarifa Ghafari",        "Zarifa",     "Ghafari"],
    ["Zohra Karimi",          "Zohra",      "Karimi"]
];
```
</details>

### B. Caractéristiques Physiques
- **Visages Hommes :** `PersianHead_A3_01`, `PersianHead_A3_02`, `PersianHead_A3_03`, `GreekHead_A3_01`, `GreekHead_A3_02`, `GreekHead_A3_03`, `GreekHead_A3_04`, `GreekHead_A3_05`, `GreekHead_A3_06`.
- **Visages Femmes :** *(Dans le code actuel, le visage féminin est laissé vide `""`. S'il y a des noms de visages spécifiques pour les femmes, merci de me les préciser).*
- **Couvre-chefs Hommes (CUP Takistan) :**
  ```sqf
  MISSION_CivilianHats = [
      "CUP_H_TKI_Lungee_Open_01", "CUP_H_TKI_Lungee_Open_02", "CUP_H_TKI_Lungee_Open_03",
      "CUP_H_TKI_Lungee_Open_04", "CUP_H_TKI_Lungee_Open_05", "CUP_H_TKI_Lungee_Open_06",
      "CUP_H_TKI_Pakol_1_01",     "CUP_H_TKI_Pakol_1_02",     "CUP_H_TKI_Pakol_1_03",
      "CUP_H_TKI_Pakol_1_04",     "CUP_H_TKI_Pakol_1_05",
      "CUP_H_TKI_SkullCap_01",    "CUP_H_TKI_SkullCap_02",    "CUP_H_TKI_SkullCap_03",
      "CUP_H_TKI_SkullCap_04",    "CUP_H_TKI_SkullCap_05",    "CUP_H_TKI_SkullCap_06"
  ];
  ```
- **Barbes Hommes (CUP - slot lunettes) :**
  ```sqf
  MISSION_CivilianBeards = ["CUP_Beard_Brown", "CUP_Beard_Black"];
  ```

### C. Armement (Bandits / Insurgés)
- **Loadouts :** Configurations existantes avec munitions, fumigènes et trousses de secours.
- **Accessoires obligatoires :** Toutes les armes doivent être équipées d'une lampe torche.
  ```sqf
  _unit addHandgunItem (selectRandom ["CUP_acc_CZ_M3X","acc_Flashlight_pistol"]);
  _unit addPrimaryWeaponItem (selectRandom ["CUP_acc_Flashlight","CUP_acc_Zenit_2DS"]);
  ```
- **Armes spécifiques à intégrer :**
  - Katiba 6.5 mm : `arifle_Katiba_F`
  - Mk20C 5.56 mm (Camo) : `arifle_Mk20C_F`
  - PDW2000 9 mm : `hgun_PDW2000_F`
  - AK-12 7.62 mm : `arifle_AK12_F`
  - AKM 7.62 mm : `arifle_AKM_F`
  - SPAR-16 5.56 mm (Black) : `arifle_SPAR_01_blk_F`
  - Kozlice 12G (Sawed-Off) : `sgun_HunterShotgun_01_sawedoff_F`
  - Promet 6.5 mm (Black) : `arifle_MSBS65_black_F`
  - AK : `CUP_arifle_AK47_Early`
  - AS Val (RIS mount/Grip) : `CUP_arifle_AS_VAL_VFG_top_rail`
  - CZ 584 : `CUP_sgun_CZ584`
  - L129A1 (Foregrip/CTRG Tropical) : `CUP_srifle_L129A1_HG_ctrgt`
  - PP-19-01 Vityaz-SN : `CUP_smg_vityaz_top_rail`
  - Romat : `CUP_arifle_IMI_Romat`
  - Slamfire Shotgun : `CUP_sgun_slamfire`

- **Sacs à dos :** 
  - Dismantled M2 HMG .50 (Raised) [FIA] : `I_G_HMG_02_high_weapon_ F`
  - Field Pack (Khaki) : `B_FieldPack_khk`
  - RPG Pack : `CUP_B_RPGPack_Khaki`
  - US Assault Pack (Coyote) : `CUP_B_AssaultPack_Coyote`
  - Messenger Bag (Black) : `B_Messenger_Black_F`
  - Messenger Bag (Coyote) : `B_Messenger_Coyote_F`

---

## 3. Informations Manquantes : Tenues (Vêtements)

**[À COMPLÉTER PAR LE DÉVELOPPEUR]**
L'ancien système utilisait des "templates" copiés depuis l'éditeur. Nous allons maintenant générer les tenues proprement par script. J'ai besoin des classnames des vêtements de style Afghan.

Veuillez insérer ici (ou me donner directement) la liste détaillée des tenues :

- **Tenues Civiles Hommes :** `[À DÉFINIR]`
- **Tenues Civiles Femmes :**
  ```sqf
  MISSION_CivilianUniforms_Female = [
      "Burqa1", "Burqa2", "Burqa3", "Burqa4", "Burqa5", "Burqa6",
      "tak1", "tak2", "tak3", "tak4", "tak5",
      "taky1", "taky2", "taky3", "taky4", "taky5"
  ];
  ```

- **Tenues Civiles Hommes :**
  ```sqf
  MISSION_CivilianUniforms_Male = [
      "CUP_O_TKI_Khet_Partug_01", "CUP_O_TKI_Khet_Partug_02", "CUP_O_TKI_Khet_Partug_03",
      "CUP_O_TKI_Khet_Partug_04", "CUP_O_TKI_Khet_Partug_05", "CUP_O_TKI_Khet_Partug_06"
  ];
  ```

- **Vestes Hommes :**
  ```sqf
  MISSION_CivilianVests = [
      "CUP_V_OI_TKI_Jacket1_01", "CUP_V_OI_TKI_Jacket1_03", "CUP_V_OI_TKI_Jacket1_04",
      "CUP_V_OI_TKI_Jacket1_05", "CUP_V_OI_TKI_Jacket1_06", "CUP_V_OI_TKI_Jacket4_01",
      "CUP_V_OI_TKI_Jacket4_02", "CUP_V_OI_TKI_Jacket4_03", "CUP_V_OI_TKI_Jacket4_04",
      "CUP_V_OI_TKI_Jacket4_05", "CUP_V_OI_TKI_Jacket4_06", "CUP_V_OI_TKI_Jacket2_01",
      "CUP_V_OI_TKI_Jacket2_02", "CUP_V_OI_TKI_Jacket2_03", "CUP_V_OI_TKI_Jacket2_04",
      "CUP_V_OI_TKI_Jacket2_05", "CUP_V_OI_TKI_Jacket2_06"
  ];
  ```

- **Chapeaux Hommes (mise à jour) :**
  ```sqf
  MISSION_CivilianHats = [
      "CUP_H_TKI_SkullCap_01", "CUP_H_TKI_SkullCap_02", "CUP_H_TKI_SkullCap_03",
      "CUP_H_TKI_SkullCap_04", "CUP_H_TKI_SkullCap_05", "CUP_H_TKI_SkullCap_06",
      "CUP_H_TKI_Pakol_2_01", "CUP_H_TKI_Pakol_2_02", "CUP_H_TKI_Pakol_2_03",
      "CUP_H_TKI_Pakol_2_04", "CUP_H_TKI_Pakol_2_05", "CUP_H_TKI_Pakol_2_06",
      "CUP_H_TKI_Pakol_1_01", "CUP_H_TKI_Pakol_1_02", "CUP_H_TKI_Pakol_1_03",
      "CUP_H_TKI_Pakol_1_04", "CUP_H_TKI_Pakol_1_05", "CUP_H_TKI_Pakol_1_06",
      "CUP_H_TKI_Lungee_Open_01", "CUP_H_TKI_Lungee_Open_02", "CUP_H_TKI_Lungee_Open_03",
      "CUP_H_TKI_Lungee_Open_04", "CUP_H_TKI_Lungee_Open_05", "CUP_H_TKI_Lungee_Open_06"
  ];
  ```

## 4. Architecture des Nouvelles Fonctions SQF

Nous allons créer deux fonctions principales :

### A. `fn_initTakistaniDB.sqf` (Exécuté au démarrage serveur)
Regroupera de manière centralisée toutes les listes de variables (Noms, Visages, Voix, Chapeaux, Barbes, Tenues, Armes).
- Suppression des anciens "templates" `max_tak_woman` et autres mannequins de l'éditeur devenus inutiles.

### B. `fn_applyTakistaniIdentity.sqf` (Exécuté sur chaque unité ciblée)
Cette fonction prendra en paramètre l'unité concernée.
1. Elle vérifiera si l'unité est un Homme ou une Femme (soit par sa classe, soit par un paramètre explicite).
2. Elle appliquera un visage persan/grec et un nom de la liste correspondante.
3. Elle appliquera une voix adaptée. *(Le pitch sera de `1.0` pour les hommes, et `selectRandom [1.3, 1.4]` pour les femmes).*
4. Elle videra l'inventaire par défaut (sauf exceptions).
5. Elle habillera l'unité avec une tenue de la liste (homme ou femme).
6. Si c'est un homme, elle ajoutera aléatoirement une barbe et un couvre-chef.
7. S'il s'agit d'un ennemi, elle piochera dans `MISSION_BanditLoadouts` pour lui attribuer son arme. *(Note : Les femmes rebelles/ennemies ne recevront qu'une arme et un sac, rien d'autre).*

### C. Règles de Spawning (Génération d'unités)
- **Ratio Homme / Femme :** Les femmes doivent être minoritaires sur la carte. Lors de la génération des unités (civiles ou ennemies), le script appliquera un ratio de **5 à 10 % de femmes** maximum.

---

## 5. Mode d'Application (Question Ouverte)

**Comment souhaitez-vous que ces identités soient appliquées ?**

- **Option A (Automatique globale) :** Comme dans votre code actuel, un `addMissionEventHandler ["EntityCreated", {...}]` détecte CHAQUE IA générée (civils de villages, renforts ennemis) et lui applique instantanément l'identité, sans que vous n'ayez à y penser.
- **Option B (Manuel) :** Vous souhaitez appeler la fonction manuellement uniquement quand vous en avez le besoin dans vos propres scripts de spawn.
