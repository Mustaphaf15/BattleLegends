# Skills recommandés pour les agents Codex — Battle Legends

Catalogue examiné : https://github.com/gamedev-skills/awesome-gamedev-agent-skills (Agent Skills SKILL.md). Alternative spécialisée : https://github.com/siyangsun/godot-skills .

**Important :** le catalogue principal documente Godot 4.7, mais Battle Legends utilise Godot 4.4.1. Vérifier chaque API et chaque exemple avant adaptation. Les skills ne sont pas installés automatiquement : il faut auditer le contenu et les licences avant de copier ou installer des scripts externes. Le jeu actif est 3D; `godot-2d-movement` ne doit pas être utilisé pour implémenter sa physique.

## Matrice issue → skills

| Sprint | Issue | Skills recommandés |
|---|---|---|
| S0 | [#2](https://github.com/Mustaphaf15/BattleLegends/issues/2) | `godot-gdscript`, `godot-nodes-scenes`, `godot-gdscript-headless-testing` |
| S0 | [#3](https://github.com/Mustaphaf15/BattleLegends/issues/3) | `dialogue-systems`, `level-design`, `create-game-assets` |
| S0 | [#4](https://github.com/Mustaphaf15/BattleLegends/issues/4) | `input-systems`, `game-feel`, `physics-tuning` |
| S1 | [#5](https://github.com/Mustaphaf15/BattleLegends/issues/5) | `godot-physics`, `physics-tuning`, `platformer` |
| S1 | [#6](https://github.com/Mustaphaf15/BattleLegends/issues/6) | `input-systems`, `godot-ui-control`, `game-ui-ux` |
| S1 | [#7](https://github.com/Mustaphaf15/BattleLegends/issues/7) | `godot-nodes-scenes`, `godot-resources`, `godot-gdscript-headless-testing` |
| S2 | [#8](https://github.com/Mustaphaf15/BattleLegends/issues/8) | `game-feel`, `godot-animation`, `physics-tuning` |
| S2 | [#9](https://github.com/Mustaphaf15/BattleLegends/issues/9) | `input-systems`, `game-feel`, `godot-animation` |
| S2 | [#10](https://github.com/Mustaphaf15/BattleLegends/issues/10) | `godot-resources`, `godot-animation`, `game-feel` |
| S3 | [#11](https://github.com/Mustaphaf15/BattleLegends/issues/11) | `create-game-assets`, `game-ui-ux`, `godot-shaders` |
| S3 | [#12](https://github.com/Mustaphaf15/BattleLegends/issues/12) | `godot-animation`, `godot-audio`, `audio-design` |
| S3 | [#13](https://github.com/Mustaphaf15/BattleLegends/issues/13) | `level-design`, `godot-3d-essentials`, `godot-physics` |
| S4 | [#14](https://github.com/Mustaphaf15/BattleLegends/issues/14) | `platformer`, `godot-physics`, `game-ui-ux` |
| S4 | [#15](https://github.com/Mustaphaf15/BattleLegends/issues/15) | `game-ai`, `ai-behavior-trees-utility-ai`, `godot-gdscript-headless-testing` |
| S4 | [#16](https://github.com/Mustaphaf15/BattleLegends/issues/16) | `create-game-assets`, `godot-resources`, `game-feel` |
| S5 | [#17](https://github.com/Mustaphaf15/BattleLegends/issues/17) | `save-systems`, `godot-resources`, `godot-gdscript-headless-testing` |
| S5 | [#18](https://github.com/Mustaphaf15/BattleLegends/issues/18) | `dialogue-systems`, `save-systems`, `level-design` |
| S5 | [#19](https://github.com/Mustaphaf15/BattleLegends/issues/19) | `save-systems`, `godot-animation`, `audio-design` |
| S6 | [#20](https://github.com/Mustaphaf15/BattleLegends/issues/20) | `performance-optimization`, `godot-export`, `godot-gdscript-headless-testing` |
| S6 | [#21](https://github.com/Mustaphaf15/BattleLegends/issues/21) | `game-ui-ux`, `godot-export`, `performance-optimization` |

## Où trouver les SKILL.md
- Godot : https://github.com/gamedev-skills/awesome-gamedev-agent-skills/tree/main/skills/godot
- Disciplines : https://github.com/gamedev-skills/awesome-gamedev-agent-skills/tree/main/skills/disciplines
- Genres (platformer) : https://github.com/gamedev-skills/awesome-gamedev-agent-skills/tree/main/skills/genres
- Installation et routage : https://github.com/gamedev-skills/awesome-gamedev-agent-skills/blob/main/README.md

## Procédure Codex
1. Lire `AGENTS.md`, `ROADMAP_CODEX.md` et l'issue assignée.
2. Identifier les 1–3 skills de la matrice et ouvrir leur `SKILL.md`; appliquer seulement les recommandations compatibles Godot 4.4.1.
3. Auditer la scène active, écrire un test de régression, puis modifier le code.
4. Fournir une PR avec tests, preuves, limites et lien vers l'issue.
5. Ne pas considérer l'issue terminée sans tests pertinents; Android réel obligatoire pour commandes et rendu.

## Skills à ne pas imposer
`godot-multiplayer` est à réserver à un futur sprint réseau; `godot-csharp` inutile tant que le projet reste en GDScript. Les skills ne remplacent pas la documentation officielle Godot 4.4 ni les tests.
