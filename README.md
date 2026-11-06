# Battle Legends

Prototype Android Godot 4.4.1. Le sprint v0.2 est en cours ; la version actuelle reste en 2D.

## Fonctionnalités actuelles

Combat Frost contre bot, déplacement, saut, attaque, blocage maintenu (B), parry (Y), combo XXXX pendant un étourdissement. Boutons Y en haut, B à droite, A en bas, X à gauche. Rejouer restaure les états du combat. Les contacts sont libérés lors de la suspension.

## Installation

Télécharger et extraire l’artifact de la dernière compilation verte dans Actions. Installer le fichier APK sur un appareil Android ARM64 (Android 5 ou ultérieur), en autorisant l’installation depuis cette source. Signature debug : prototype de développement.

## Validation

La CI importe le projet, lance un smoke test headless et les régressions `tools/test_baseline.gd`, puis exporte et vérifie le contenu et la signature de l’APK. Ces contrôles ne remplacent pas une installation et des essais sur Android.

## Limites connues

Pas encore de rendu 3D, de vrais corps physiques, de joystick analogique ni de modes Survival/Smash sélectionnables. Les plateformes dessinées ne possèdent pas de collisions. Les attaques ignorent encore la distance verticale. L’option joystick/flèches change seulement son libellé.

Legend : tirage 1/600 000 après victoire ; présentation textuelle temporaire de 120 secondes avec retour au combat. Le modèle 3D, la musique, la sauvegarde et le déblocage au million de kills restent à implémenter. La cinématique finale complète n’est pas livrée.
