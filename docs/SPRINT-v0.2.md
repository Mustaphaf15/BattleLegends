# Suivi du sprint Battle Legends v0.2

État consigné le 6 novembre 2026. Le sprint est **en cours**. La livraison complète de Battle Legends v0.2 n'est pas validée.

Le travail avance dans l'ordre du backlog. Une compilation verte ne remplace ni la vérification du rendu Android ni les tests du gameplay. La tâche suivante commence après satisfaction des critères d'acceptation de la tâche actuelle.

## Tâche 01 — Audit et stabilisation

**État : terminée.**

- Audit du projet 2D, des scènes, des scripts, de l'issue #1 et des compilations existantes.
- Métadonnées du projet alignées sur Godot 4.4 ; la CI utilise Godot 4.4.1.
- Correction de la réinitialisation du combat : déplacement vertical, statuts, combo, délais d'attaque et contacts tactiles.
- Libération des contacts tactiles lors de la perte de focus ou de la suspension.
- Correction de la présentation textuelle de Legend : message final persistant et bouton de retour au combat.
- Ajout de régressions automatisées dans `tools/test_baseline.gd` et clarification des limites dans le README.

Commit publié : [`fcc5df6`](https://github.com/Mustaphaf15/BattleLegends/commit/fcc5df6).

Validation de référence : [compilation Android réussie 42281965461](https://github.com/Mustaphaf15/BattleLegends/actions/runs/42281965461), avec import, smoke test headless, régressions, export et contrôles de contenu/signature de l'APK. [Artifact Android de référence 13535283768](https://github.com/Mustaphaf15/BattleLegends/actions/runs/42281965461/artifacts/13535283768).

Ces validations établissent une référence 2D compilable. Elles ne constituent pas une campagne de tests physiques sur téléphone Android.

## Tâche 02 — Architecture 3D

**État : terminée.**

Validation finale : commit `1efd61a570aedd16cfb931209491d9b199901e65`, [build42284708888](https://github.com/Mustaphaf15/BattleLegends/actions/runs/42284708888) et [QA Android42285065780](https://github.com/Mustaphaf15/BattleLegends/actions/runs/42285065780), tous deux verts. Capture exacte revue : arène, quatre plateformes, capsules et interface visibles. Installation et lancement réels sur émulateur Android10 x86_64 avec ANGLE ; aucun ERROR Godot ni échec de shader dans les logs. [Preuves Android](https://github.com/Mustaphaf15/BattleLegends/actions/runs/42285065780/artifacts/13536323841).

Implémentation : [`de45052`](https://github.com/Mustaphaf15/BattleLegends/commit/de45052).

Fichiers principaux :

- `scenes/arena_3d.tscn` et `scripts/arena_3d.gd` : scène Node3D, environnement, caméra orthographique de côté, lumière directionnelle et interface temporaire.
- `scenes/fighter_3d.tscn` et `scripts/fighter_3d.gd` : capsules distinctes, corps physiques, déplacement horizontal, saut et verrouillage du plan Z.
- `scenes/platform_3d.tscn` : plateforme réutilisable avec collision.
- `tools/test_architecture.gd` : contrôles automatisés de la structure 3D, du plan de combat et de l'atterrissage sur le sol physique.

La scène 2D de référence est conservée et accessible depuis la scène 3D. Les personnages et le décor sont des primitives de validation de l'architecture ; ils ne constituent ni Frost finalisé ni la forêt magique.

### Résultat Android refusé

La [première exécution Android QA 42282870053](https://github.com/Mustaphaf15/BattleLegends/actions/runs/42282870053) était verte, mais son résultat a été **explicitement rejeté** :

- La capture montrait une confirmation Android du mode immersif devant un fond noir ; elle ne prouvait pas l'affichage de l'arène.
- Les logs contenaient des erreurs de liaison de shaders Godot GLES3, dont `CanvasShaderGLES3` et `GL_MAX_FRAGMENT_UNIFORM_VECTORS (261)`, ainsi qu'une erreur `CowData`.
- Le contrôle initial ne détectait pas suffisamment ces erreurs de rendu.

Correctif QA : [`f874fd5`](https://github.com/Mustaphaf15/BattleLegends/commit/f874fd5). Un contrôle strict des erreurs a été ajouté. Une nouvelle validation avec un moteur graphique ANGLE pour l'émulateur doit fournir une capture exploitable et des logs sans erreur bloquante avant acceptation.

La présence d'un APK exporté ou d'un job vert dans cette première exécution n'autorise pas à déclarer la tâche 02 terminée.

### Portée des tests à ce stade

Les contrôles headless vérifient des propriétés de scène et de simulation. L'exécution Android initiale a permis d'installer et lancer l'application dans un émulateur et de collecter capture et logs ; elle a révélé un problème de rendu. L'affichage 3D est désormais confirmé par la capture finale revue et les logs stricts du run42285065780.

Ne sont pas validés à ce stade : le multitouch, les contrôles finaux A/B/X/Y en 3D, un combat 3D complet, les performances sur téléphone ou la campagne finale du sprint.

## Backlog restant

La tâche03 commence après acceptation de la tâche02 ; les autres restent non démarrées. Leur ordre reste obligatoire.

| Tâche | Objet | État |
| --- | --- | --- |
| 03 | Frost 3D et ses animations | Terminée (Godot local ; Android à vérifier) |
| 04 | Bot 3D et IA de combat | En cours |
| 05 | Forêt magique et arène finale | Non démarrée |
| 06 | Contrôles Android et multitouch | Non démarrée |
| 07 | Combat, hitboxes, blocage, parry et combo | Non démarrée |
| 08 | Modes Survival et Smash | Non démarrée |
| 09 | Sauvetages Luna | Non démarrée |
| 10 | Pouvoirs spéciaux de Frost | Non démarrée |
| 11 | Cinématique de finition | Non démarrée |
| 12 | Progression et présentation de Legend | Non démarrée |
| 13 | Menus et interface complète | Non démarrée |
| 14 | Optimisation et mesures Android | Non démarrée |
| 15 | Validation finale CI et APK v0.2 | Non démarrée |
| 16 | Campagne finale et livraison | Non démarrée |

Des éléments de CI nécessaires aux premières validations existent déjà ; ils ne valent pas validation anticipée des tâches 15 et 16.

## Limites à conserver dans le rapport de livraison

- Les contrôles 3D actuels sont temporaires ; les boutons standards ne prouvent pas le fonctionnement multitouch demandé.
- Le bot 3D est une capsule immobile, sans IA de combat.
- L'arène 3D est une structure de plateformes avec décor minimal.
- Le retour à la référence 2D reste une fonction de comparaison, pas une sélection de mode de jeu.
- Les systèmes Luna, modes 3D, pouvoirs, progression sauvegardée et cinématiques finales restent à implémenter et tester.
- Aucun objectif de 30/60 FPS, de mémoire ou de stabilité sur téléphone n'est encore mesuré et validé.
- L'APK de référence de la tâche 01 reste une version 2D ; il ne constitue pas la livraison finale v0.2.

Prochaine tâche :03 — Frost3D et animations. Les deux suites headless passent aussi localement avec le binaire officiel Godot4.4.1 provenant de la CI. Le lanceur tools/run_tests.sh découvre automatiquement les nouvelles suites et refuse toute erreur Godot.

## Tâche03 — Frost3D

Modèle procédural original : armure bleue, cristaux, couronne, visière et cinq éclats de glace bornés. AnimationPlayer : Idle, Run, Jump, Fall, Attack, Block, Parry, Hit et KO. Les poses modifient réellement les membres et le rig ; le collider physique reste séparé du visuel.

Validation locale Godot4.4.1 : import et trois suites tests: PASS sans erreur ; revue indépendante confirmée. tools/test_frost.gd vérifie clips/pistes, mouvement, saut/chute/atterrissage, attaque et délai, poses, symétrie visuelle et collider. Aucun test de manipulation Android de Frost n’est revendiqué à cette étape. Le combat avec dégâts viendra à la tâche04 et sera formalisé avec hitboxes à la tâche07.
