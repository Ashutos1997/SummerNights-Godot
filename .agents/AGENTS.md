
## Documentation Guidelines
Always refer to the 4 core documentation files in the `docs/` directory when working on related features:
1. `docs/features.md` - Master record of all implemented mechanics and features.
2. `docs/changelog.md` - Release notes and version history.
3. `docs/ui_design_system.md` - UI design system, typography, colors, and animation logic.
4. `docs/HUD_UI.md` - Architectural map and layout references for the game's HUD.

Read these files to understand existing patterns before proposing new changes. Furthermore, **whenever you make changes to the game's codebase, mechanics, or UI, you MUST automatically update these 4 documentation files if applicable** to ensure they remain the single source of truth.

## Art Asset Handling Guidelines
**CRITICAL RULE:** Never feed the UI artist's work or any provided assets into AI image generation or modification tools. The user strictly prohibits using AI on these assets. You must only implement the assets into the engine exactly as provided.
