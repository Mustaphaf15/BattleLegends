# Instructions agents — Battle Legends

Consulter obligatoirement [la roadmap](docs/production/ROADMAP_CODEX.md), les issues GitHub ouvertes et le README avant tout changement.

## Mission
Livrer progressivement un jeu de combat Android 2,5D original, stable et cohérent avec la bible fantasy mystérieuse et épique. Les exigences du sprint et les critères d'acceptation de chaque issue priment sur l'ajout opportuniste de fonctionnalités.

## Règles
- Une issue par unité de travail et une PR reliée à l'issue.
- Auditer les fichiers actuels avant d'éditer. La scène active est `scenes/arena_3d.tscn`; ne pas confondre avec la référence 2D.
- Priorité aux bugs de saut, collisions, multitouch et au combat avant les extensions narratives.
- Tester Godot headless et la compilation APK; ne jamais prétendre à une validation Android réelle sans preuve.
- Ne pas fusionner du code non testé ou ajouter d'assets non originaux.
- Faire respecter le canon narratif et la cohérence visuelle. Les nouveaux noms et la probabilité 1/100000 sont des propositions à valider, pas des décisions figées.
- Signaler les dépendances et conflits entre agents, garder les PR ciblées.
- Fermer les issues uniquement après fusion et vérification des critères.

## Première tâche
Prendre en charge #2 et produire l'audit, puis organiser #3 et #4. Les tâches suivantes sont listées dans `docs/production/ROADMAP_CODEX.md`.
