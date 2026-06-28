# Helix RP v0.4.4
## About
Helix-based RP gamemode for Garry's Mod.
Currently in alpha. A more complete experience is planned for v0.5 or v0.6.

---

## Installation
Download the repository as a ZIP, extract it and place the metrouniversum folder into your garrysmod/gamemodes directory.
Configuration is done manually through config files. If you don't know what you're doing, this gamemode is probably not for you yet.

---

## Plugins:
* containers - Modified to include two additional hooks: `ContainerOpened` and `ContainerClosed`. Required by containerswithloot.
* containerswithloot - Allows you to define item pools that spawn inside specific containers, e.g. scrap in trash cans.
* crafting - Third-party plugin, included as-is.
* foodsystem - Extended with a hunger rework, thirst mechanic, and additional commands (disabled by default, uncomment to enable).
* itemspawner - Third-party plugin, included as-is.
* workshops - Custom plugin. Configure workstations where players exchange items for another.
* hud - Adds hunger and thirst bars to the Helix HUD.

---

## Roadmap
Development is slow and there's a chance this never reaches v1.0. Planned features if it does:
1. Diseases(diarrhea, food poisoning)
2. Crafting skills
3. Temperature system