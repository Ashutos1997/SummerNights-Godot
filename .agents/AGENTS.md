
## Documentation Guidelines
Always refer to the 4 core documentation files in the `docs/` directory when working on related features:
1. `docs/features.md` - Master record of all implemented mechanics and features.
2. `docs/changelog.md` - Release notes and version history.
3. `docs/ui_design_system.md` - UI design system, typography, colors, and animation logic.
4. `docs/HUD_UI.md` - Architectural map and layout references for the game's HUD.

Read these files to understand existing patterns before proposing new changes. Furthermore, **whenever you make changes to the game's codebase, mechanics, or UI, you MUST automatically update these 4 documentation files if applicable** to ensure they remain the single source of truth.

**CRITICAL CHANGELOG RULE:** When updating `docs/changelog.md`, you MUST always add the changes to BOTH the English section and the Korean (한국어) section. Never update just the English version.

## Art Asset Handling Guidelines
**CRITICAL RULE:** Never feed the UI artist's work or any provided assets into AI image generation or modification tools. The user strictly prohibits using AI on these assets. You must only implement the assets into the engine exactly as provided.

## Repository Management
**CRITICAL README RULE:** The project contains both an English `README.md` and a Korean `README.ko.md`. Whenever making updates to the README structure, layout, or content, you MUST ensure that both files are updated synchronously to keep their contents, image counts, and structures completely identical (accounting for language translations).

## UI & Design Consistency
**CRITICAL DESIGN RULE:** You must ALWAYS follow our design system (`docs/ui_design_system.md`) 1:1 for every single thing you create or modify. Fonts, colors, border radii, alignments, margins, and container sizes must strictly adhere to the established styles. Never introduce arbitrary colors or styling choices.

## Export Guidelines
**CRITICAL RULE:** Whenever exporting a macOS build, you must ALWAYS export it as a `.dmg` file format instead of a `.zip` file.

## Scripting & Automation Guidelines
**CRITICAL SCRIPTING RULE:** NEVER use the `cat << 'EOF'` heredoc method or write scripts inline inside bash commands. Always edit files manually using the native `replace_file_content` or `write_to_file` tools, or write explicit python/bash scripts using `write_to_file`.
