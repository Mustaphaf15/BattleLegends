# Battle Legends — Roadmap Codex / Sprints (2026-11-07)

> Source de vérité de planification : GitHub Issues #2 à #21. Les statuts dans ce fichier sont initiaux et ne se synchronisent pas automatiquement. Le suivi réel se fait via les issues et PR. Aucun sprint n'est déclaré terminé à la création du plan.

## Vision et périmètre
Jeu de combat 2,5D fantasy mystérieux et épique sous Godot 4.4.1, Android prioritaire. Combat équilibré, accessible, avec combos, spéciaux, garde et parade. Univers Aetheria, Éther et Cœur des Légendes; royaumes Nivareth/Vulkhar/Aeralis/Thaloria/Elyndor; Frost, Cinder Warden, Zephyr, Terra, Luna, Legend/Auren, Néant. **Canon narratif proposé à formaliser en S0**, pas encore une implémentation.
Contrôles cible : A saut/double saut, X attaque et combos, Y spécial directionnel, B garde maintenue/parade au timing, joystick analogique. Survival = PV, Smash = éjection. Legend : quête secrète garantie; chance aléatoire 1/100000 **proposition non validée**, à rendre configurable. Ne pas remplacer la quête par un RNG.

## Tableau de pilotage
| Sprint | But | Issues | Gate de sortie |
|---|---|---|---|
| S0 | Audit, canon, spécifications | #2 #3 #4 | Baseline vérifiée et règles écrites |
| S1 | Fondations | #5 #6 #7 | Sauts fiables + multitouch réel + tests |
| S2 | Combat vertical slice | #8 #9 #10 | Deux combattants avec combats équilibrés |
| S3 | Art et identité | #11 #12 #13 | Cohérence visuelle et Luna testable |
| S4 | Modes et contenu | #14 #15 #16 | Smash/Survival, IA, quatre personnages |
| S5 | Progression et Legend | #17 #18 #19 | Quête garantie, sauvegarde, rareté vérifiée |
| S6 | Bêta Android | #20 #21 | APK et essais réels documentés |

## Ordre et dépendances
- S0 précède tout changement majeur de gameplay ou d'histoire.
- S1 bloque les fonctionnalités avancées de S2; priorité immédiate à #5 et #6.
- S2 et S3 peuvent partiellement avancer en parallèle après la définition des contrats S0.
- S4 dépend de la stabilité du combat; S5 dépend des sauvegardes et de la définition du canon.
- S6 teste en continu dès S1; la validation finale reste à la fin.
- Ne pas supposer que la correction de `scripts/arena.gd` valide la scène principale : `project.godot` démarre `scenes/arena_3d.tscn`. Vérifier les deux implémentations et la couverture des tests.

## Règles de travail des agents Codex
1. Lire ce fichier, le README et les issues ouvertes avant de coder; faire un audit factuel de l'existant.
2. Choisir une issue et annoncer la prise en charge dans sa PR; ne pas fermer l'issue au début.
3. Créer une branche `codex/sN-issue-N-description`; PR de taille raisonnable avec `Refs #N` et `Closes #N` uniquement lorsque les critères sont remplis.
4. Répartir les agents par domaine (gameplay/physics, architecture/tests, art/UI, narrative/progression, Android/QA). Éviter les modifications concurrentes du même fichier.
5. À chaque PR : contexte, changements, risques, tests automatisés, preuve visuelle si pertinent, compatibilité Android, liens d'issues.
6. Ne jamais déclarer une tâche terminée sur le seul succès de la CI. Multitouch, rendu, performance et ergonomie exigent des essais sur appareil réel.
7. Conserver les décisions non validées comme configurables et marquées PROPOSITION. Ne pas inventer des fonctionnalités déjà livrées.
8. Après fusion et validation, cocher la checklist de l'issue, fermer l'issue et mettre à jour la documentation. Signaler explicitement les blocages.
9. Régression = nouvelle issue liée, priorité P0 si gameplay bloquant.
10. Pas d'assets ou musiques copiés d'autres jeux; produire des éléments originaux et documenter les licences.

## Definition of Ready
- Objectif et critères d'acceptation clairs.
- Dépendances identifiées.
- Fichiers et scène cible connus.
- Test de validation décrit.

## Definition of Done
- Implémentation intégrée, tests automatisés verts, pas de régression connue non documentée.
- APK exportable et scène principale vérifiée.
- Pour les fonctions visuelles/tactiles : test sur Android réel avec résultat consigné.
- Documentation et issue mises à jour, PR fusionnée.

## Statuts de suivi recommandés
Todo → In progress → In review → QA Android → Done; Blocked si dépendance. GitHub Issues/PR font foi; les labels et GitHub Projects peuvent être configurés ultérieurement. **Aucun milestone GitHub ni tableau Projects n'a été créé par cette opération**.

## Risques majeurs
- Confusion entre prototype 2D et scène 3D active.
- Collisions plateformes et saut non fiabilisés.
- Multitouch non validé sur téléphone.
- Équilibrage des pouvoirs et des avantages de Legend.
- Cinématique 120 s, sauvegarde et ressources mobiles coûteuses.
- Portée 20 personnages et 6 joueurs : ambitions futures, hors MVP.

## Mission de démarrage Codex
Commencer par #2, #3 et #4 (audit, canon et règles), puis #5 et #6. Produire une PR par issue; ne pas démarrer la production de Legend avant les prérequis. Tenir un compte rendu de sprint avec issues ouvertes/fermées, risques, démos APK et décisions en attente.
