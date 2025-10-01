# ⏱️💰 Time Is Money App

## 🎯 Aperçu du Projet

**Time Is Money** est une application multiplateforme ludique et utilitaire qui transforme le temps en argent réel. Elle permet aux utilisateurs de visualiser en direct, à la seconde près, leurs gains cumulés en fonction d'un taux horaire défini.

**Objectif principal :** Rendre la valeur du temps concret, lisible et motivant.

## ✨ Spécifications Fonctionnelles (MVP - Version 1.0)

La première version se concentre sur le cœur du concept :

1.  **Saisie du Taux Horaire :** L'utilisateur peut définir son taux de gain par heure (ex: 15.30 €/h).
2.  **Choix de la Devise :** Sélection paramétrable de la devise (EUR, USD, GBP, etc.) qui sera affichée sur le compteur.
3.  **Compteur en Temps Réel :** Affichage de deux compteurs synchronisés :
    * **Durée :** Le temps écoulé depuis le démarrage de la session (HH:MM:SS).
    * **Gains :** Le montant cumulé calculé sur base du taux et de la durée.
4.  **Contrôle de Session :** Un bouton unique **START / STOP** pour lancer, mettre en pause et reprendre le calcul.
5.  **Persistance :** Sauvegarde automatique du dernier taux horaire utilisé.
6.  **Section Fun (Préréglages) :** Ajout de taux horaires préenregistrés à sélectionner rapidement pour le fun (ex: Taux SMIC, Salaire d'une célébrité).

## 🎨 Design et Expérience Utilisateur (UX/UI)

### Écran d'Introduction (Splash Screen)

* **Thème Visuel :** Forte représentation du concept "Temps = Argent".
* **Animation :** Un **sablier stylisé** au centre, dont le sable s'écoule.
* **Effet :** Des **symboles monétaires animés** descendent en arrière-plan, renforçant l'idée que le temps qui passe génère de l'argent.
* **Texte :** Le titre **"Time Is Money"** affiché clairement sous l'animation.

### Écran Principal (Le Compteur)

* **Clarté :** Interface minimaliste centrée sur les deux compteurs.
* **Hiérarchie :** Le compteur de **Gains** doit être visuellement le plus dominant, suivi du compteur de **Durée**.
* **Contrôle :** Le bouton **START/STOP** positionné de manière ergonomique pour un accès facile.

## 🛠️ Stack Technique

* **Langage :** **Dart**
* **Framework :** **Flutter** (pour la flexibilité multiplateforme)
* **Plateformes Cibles :** Android, iOS, Web, Windows, macOS.

## 🚀 Prochaines Étapes de Développement

1.  Initialisation du projet Flutter.
2.  Développement de la logique de calcul du temps et de l'argent (le **`Timer`**).
3.  Conception de l'interface utilisateur de l'écran principal.
4.  Implémentation de la persistance des données (`shared_preferences`).
