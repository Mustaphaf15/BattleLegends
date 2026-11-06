# Battle Legends

Prototype Android Godot 4.4.1. Le sprint v0.2 est en cours ; la scène principale est désormais une architecture 3D provisoire. La référence 2D reste accessible avec le bouton « RÉFÉRENCE 2D ».

## Prototype 3D

Caméra orthographique de côté, environnement éclairé, matériaux compatibles mobile, plateformes physiques réutilisables et Frost avec un modèle original d’armure/cristaux et Cinder Warden, adversaire original cuivre/charbon à cornes et marteau. Déplacement horizontal et saut physiques du joueur, touches ou boutons provisoires. Frost dispose de neuf animations (Idle, Run, Jump, Fall, Attack, Block, Parry, Hit, KO), de cristaux mobiles et d’une attaque visuelle via X ou le bouton temporaire. La forêt magique comporte arbres, plantes, rochers, cristaux, particules et deux champignons rebondissants de récupération aux bords. Les plateformes hautes se traversent depuis dessous puis permettent d’atterrir dessus. Le bot poursuit, saute et attaque automatiquement. Le combat 3D de référence possède PV, coups, recul, étourdissement, victoire/défaite et Rejouer.

La CI Android Emulator QA installe et lance l’APK exact sur Android 10 x86_64, puis produit une capture et les logs. Une capture doit être revue pour valider le rendu. Ce smoke test ne valide ni le multitouch ni les performances sur téléphone.

## Fonctionnalités de la référence 2D

Combat Frost contre bot, déplacement, saut, attaque, blocage maintenu (B), parry (Y), combo XXXX pendant un étourdissement. Boutons Y en haut, B à droite, A en bas, X à gauche. Rejouer restaure les états du combat. Les contacts sont libérés lors de la suspension.

## Installation

Télécharger et extraire l’artifact de la dernière compilation verte dans Actions. Installer le fichier APK sur un appareil Android ARM64 (Android 5 ou ultérieur), en autorisant l’installation depuis cette source. Signature debug : prototype de développement.

## Validation

La CI importe le projet, lance un smoke test headless et les régressions `tools/test_baseline.gd`, puis exporte et vérifie le contenu et la signature de l’APK. Ces contrôles ne remplacent pas une installation et des essais sur Android.

## Limites connues

Modèles procéduraux de prototype. Le blocage/parry 3D réels, les hitboxes formelles, le joystick analogique et les modes Survival/Smash sélectionnables restent à livrer. B/Y activent actuellement des poses provisoires. Les commandes 3D ne sont pas encore validées en multitouch.

La référence 2D conserve ses limites historiques : plateformes dessinées sans collisions, attaques ignorant la distance verticale et option joystick/flèches changeant seulement le libellé.

Legend : tirage 1/600 000 après victoire ; présentation textuelle temporaire de 120 secondes avec retour au combat. Le modèle 3D, la musique, la sauvegarde et le déblocage au million de kills restent à implémenter. La cinématique finale complète n’est pas livrée.
