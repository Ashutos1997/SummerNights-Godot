# Changelog

All notable changes to the Summer Nights project will be documented in this file.

## [v1.5.1 - WIP]
*(Note: This release corresponds to v1.1 on itch.io)*

### Added
* **Achievement Progress UI:** The game's UI will now dynamically show your current progress on locked accumulative achievements (e.g. "Shoo away 50 seagulls. (12/50)"), both on the Title Screen and in the mid-game Pause Menu.
* **Game Logo:** Integrated the official "Summer Nights" logo as the primary application icon for both Windows `.exe` and macOS `.app` exports.

### Improved
* **Water Shader Polish:** Updated the stylized water shader (`stylized_water.gdshader`) to boost wave steepness and increase foam density and thickness, creating a much more dynamic and natural "water-like" feel.

### Fixed
* **Shadow Walker Achievement:** Fixed a bug where successfully surviving the Solar Eclipse event and clearing the level would not trigger or unlock the Shadow Walker achievement.
* **Level Clear Screen Consistency:** The "Next Level" screen (WinScreen) has been completely restyled to follow the global design system. It now features the signature 24px golden border, centered layout, and a dividing line, perfectly matching the visual presentation of the Lose Screen. Additionally, fixed a bug where the level completion text (e.g., "LEVEL 01 COMPLETE") was hardcoded to English and failed to update when Korean was selected.

## [v1.5.0]

### Added
- **First-Time Shooting Tutorial:** Added a new floating UI prompt during the first playthrough of Normal Mode to teach new players how to aim and shoot. The tutorial elegantly hovers centered above the weapon model and permanently fades out as soon as you press Left Click or Right Trigger.
- **Auto-Pause on Unfocus:** The game now automatically catches the `NOTIFICATION_APPLICATION_FOCUS_OUT` signal and seamlessly triggers the Pause Menu (while cleanly closing the Weapon Wheel if it was open) whenever the player Alt-Tabs or clicks away from the game window, preventing accidental run failures.
- **Dynamic Crosshair Ring:** Rebuilt the crosshair into a dedicated standalone scene. It now features a crisp, procedural vector ring drawn directly around the reticle that visually tracks your water tank capacity in real-time, removing the need to look down at the UI. The ring and crosshair will instantly flash red when the tank is empty, and will flash lime-green upon landing critical hits on sunspots.

### Fixed
- **Incomplete Pause State:** Fixed an issue where background elements (clouds, ocean wave shaders, physics, particles) continued animating while the game was paused. The pause system now sets `get_tree().paused = true` to freeze the entire scene tree globally, while keeping the HUD interactive via `PROCESS_MODE_ALWAYS`. All exit paths (Resume, Retry, Main Menu) correctly unpause the tree before transitioning.

## [v1.4.0]

### Added
- **Xbox Controller Support:** The game has been fully migrated to Godot’s `InputMap` backend, adding native plug-and-play support for Xbox Controllers. Aiming is handled via the Thumbsticks (Dual-stick), providing smooth analog crosshair movement. Core combat actions have been meticulously mapped for fluid gameplay: Right Trigger (RT) to Shoot, Left Trigger (LT) for Ice Blast, and Right Bumper (RB) for Catastrom. The Weapon Wheel now features native Gamepad support, allowing players to hold the Left Bumper (LB) to slow time, flick either thumbstick to select a weapon, and release the bumper to auto-equip it (DOOM-style).
- **Gamepad Menu Navigation:** Full UI navigation support for Xbox controllers. Players can now seamlessly navigate the Pause screen, Settings, Controls, and End/Lose screens using the D-Pad or thumbsticks. Visual focus rings have been added to all interactive elements (sliders, toggle buttons, language toggles), and pressing the `B` button correctly closes submenus and resumes the game without triggering the pause screen again.
- **Controller Haptics (Vibration):** Added immersive controller vibrations across core gameplay events: firing weapons, detonating Ice Bursts, dragging the sun during Catastrom, dunking the sun, and taking heat damage from solar flares. A new toggle has been added to the Settings menu to disable vibrations.
- **Controls Menu Overhaul:** The Controls menu now features a premium "Sliding Toggle Pill" (matching the Language settings) to switch seamlessly between the Keyboard and Xbox controller legend graphics. The Xbox graphic features mathematically exact vector highlights to match the keyboard diagram.
- **Water Shader Overhaul:** Completely rewrote the procedural water shader (`stylized_water.gdshader`) to use physical Gerstner waves, procedural Voronoi surface foam/caustics that scroll across the open ocean, and fake subsurface scattering (SSS) that dynamically highlights wave crests based on height and view angle.
- **PBR Sand Texture:** Replaced the procedurally generated sand noise with a high-quality CC0 PBR texture (Coast Sand 01) from Poly Haven, featuring diffuse, normal, and roughness maps for a smoother, stylized beach aesthetic.
- **Retro Post-Processing:** Added a global screen shader applying film grain, vignette, and synthwave color grading (S-curve contrast and complementary split-toning) for a cohesive arcade aesthetic.
- **Cinematic Bloom:** Enabled soft additive bloom in the WorldEnvironment. The sun and all dynamically generated particles (water shots, ice bursts, catastrom) are now emissive, dynamically bleeding light into the atmosphere.
- **Controls Menu:** Added a new "CONTROLS" menu accessible from the Pause Screen so players can easily see which keys are mapped to which actions.
- **Catastrom Audio (itch.io Safe Export):** Integrated a dual-audio pipeline for the Catastrom ultimate ability, dynamically loading a royalty-free "safe audio" dunk sound when exported with the `safe_audio` feature tag for itch.io, while preserving the original Kamen Rider audio for GitHub builds.

### Fixed
- **macOS Export Compatibility:** Fixed an issue where the exported macOS build (`.dmg`) would fail to open or report as damaged due to Godot's built-in code signing silently failing on restrictive extended file attributes (`com.apple.FinderInfo`). The macOS export pipeline has been updated to manually strip these attributes and enforce proper Ad-Hoc code signing.
- **Sand Reflectivity & Weather:** Fixed an issue where the new PBR sand texture looked overly reflective (like wet mud) and stayed brightly lit during dark weather events. The material now uses a completely matte finish (`specular = 0.0`) and dynamically fades its emission during Rainstorms and Eclipses to perfectly match the environment's ambient lighting.
- **Cinematic Rogue Waves:** Rogue waves now spawn off-mesh for a smooth entry and dynamically swell in height as they travel towards the island, creating a realistic, cinematic build-up before crashing. Additionally, the dark wet sand visual effect is now perfectly synchronized with the wave's exact speed and impact time. The logic for small, unimpactful rogue waves was completely removed—every rogue wave is now guaranteed to be a massive surfing wave, and their spawn interval has been increased (from 12-25s to 20-35s) so they feel like rarer, more cinematic events.
- **Distant Water Horizon:** Fixed an issue where the distant ocean was blending too heavily into the skybox due to volumetric fog and excessive sunset reflections. The water shader now disables fog, correctly fades out fresnel reflections based on depth, and is 100% opaque, resulting in a razor-sharp, deep blue horizon line.
- **Shiny Sand Highlights:** Disabled artificial specular light emission from the Sun and global directional lights to prevent them from projecting glossy, plastic-like reflection spots onto the dry, matte sand.
- **Solar Flare Intercept Effect:** Changed the particle explosion effect when successfully shooting down a Solar Flare from an un-natural purple/magenta to a fiery orange (`Color(1.0, 0.6, 0.1)`) that properly matches the flare's plasma core.
- **Credits Button Color:** Fixed a bug where the "Credits" and "Settings" buttons would occasionally render in a translucent grey instead of the standard yellow due to redundant manual hover-detection logic inside `HUD.gd`.
- **Weapon Wheel Exploit:** Fixed an exploit where players could stall the game in slow-motion using the Weapon Wheel to wait out hazards (Solar Wind, Eclipses). Hazard timers now pause completely while the wheel is open, forcing players to face them, while the main level timer continues to tick down.
- **Controls Menu Alignment:** Fixed a UI layout bug where the Keyboard and Xbox controller legend rows had mismatched widths and did not stretch symmetrically. Implemented Godot's expanding spacer pattern (`size_flags_horizontal = 3`) to perfectly align the left and right edges with the top/bottom dividers regardless of content size.
- **Windowed Mode Legibility:** The game now launches in Fullscreen mode by default to ensure maximum font legibility and visual clarity.

---

## [v1.3.0] - 2026-08-21

### Added
- **Tidal Gatling:** Added a massive 5th weapon (a heavy gatling gun) boasting huge cooling power but extreme water drain and slow recharge. Serves as an endgame loop goal and unlocks via the "Arcade Legend" achievement.
- **Dynamic Combo Callouts:** Reaching combo milestones (1.5x, 2.0x, 2.5x, 3.0x) now triggers energetic, themed floating text callouts (e.g., "CHILL!", "ICE COLD!") that scale and fade dynamically to boost the arcade feel.
- **Achievements System:** Added an in-game achievements gallery accessible from the Title Screen. Unlocking achievements displays a custom animated Toast notification with an audio cue. Features custom vector icons from Game-icons.net for each achievement. Current achievements include "Dawn Breaks" (Beat Level 5), "Arcade Legend" (Score 10,000 pts), "Slam Dunk" (Use Catastrom), "Untouchable" (Hit 3.0x Combo), "Rock Solid" (Evaporate Magma), "Shadow Walker" (Survive an Eclipse), "Shoo!" (Shoo 50 Seagulls), and "Flare Catcher" (Intercept 10 Solar Flares).
- **Active Buffs Menu:** Added a dedicated "Active Buffs" menu to the Pause screen. This dynamically checks the player's high score and achievements, displaying a live list of all currently active gameplay buffs and rewards.
- **Buff Notifications:** Unlocking a high-score buff now triggers a golden Toast notification during gameplay, sharing the unified design language of achievement unlocks but animating below them to prevent overlap.
- **Startup Boot Sequence:** The Title Screen now features a 4-second boot-up sequence syncing a swelling PS1-style synth pad with a procedurally animated golden border that draws itself around the screen.
- **Rogue Waves:** Occasional large, foamy "rogue waves" now procedurally roll in from the distant horizon towards the island, making the ocean feel much more dynamic and lively without breaking the stylized aesthetic.
- **High Heat Steam:** Added a dynamic visual effect where the sun furiously boils off steam when its temperature exceeds 75%. The steam thickness and speed dynamically scale with the heat, serving as a juicy visual warning of critical danger.
- **Supernova Cinematic:** Replaced the standard Game Over screen with a dramatic Supernova sequence. When time runs out, the sun violently expands into a blinding white flash before transitioning to the Lose menu. The intense camera shake during this event is automatically disabled if the 'Reduce Motion' setting is enabled.

### Improved
- **Menu Icons:** Replaced the generic settings gear icon on the Controls menu title with a dedicated controller SVG icon.
- **Achievements & Buffs Visibility:** Locked achievements and active buffs no longer obfuscate their names and descriptions with "???". They now clearly display their full titles and unlock requirements to help guide players, while remaining visually greyed-out until earned.
- **Safe Export Fallbacks:** The itch.io safe export build (`safe_audio`) now automatically substitutes the copyrighted Catastrom ultimate UI notification icon with a royalty-free "glowing ball" alternative.
- **Environment Polish:** The island's foliage (trees and bushes) now aggressively bends and sways when the Solar Wind hazard is active, visually telegraphing the wind direction.
- **In-Game Achievements:** The Achievements menu is now fully accessible from the in-game Pause Menu, allowing players to check their progress without returning to the Title Screen.
- **Border Consistency:** Unified the custom animated startup border to mathematically trace the exact 8-pixel corner radius used by the static panels across the rest of the game's UI for a seamless transition.
- **Button Consistency:** Standardized all "BACK" buttons across menus (Settings, Credits, Achievements, Buffs) to strictly match the global menu button design system (280x52 size, 2px gold borders, no arrow prefixes).
- **Menu Polish:** Unified the design across all menus (Pause, Settings, Credits, Achievements, Buffs) with consistent left-aligned layouts, unified 96px interior margins, uniform dividers, exactly 24px vertical separation gaps, and dynamic gold-tinted UI icons. Menu buttons were also increased in size for better accessibility.
- **Button States:** Standardized the 4 interaction states (Normal, Hover, Pressed, Disabled) across all primary menu buttons, ensuring perfectly consistent visual feedback, colors, and layout rules game-wide.
- **Pause Screen Border:** Added a custom broken-border design to the Pause menu featuring an animated procedurally-drawn vector sun graphic in the bottom-right corner.
- **Typography Readability:** English body text (achievement descriptions, credits) now uses the Inter Medium font for improved legibility, while titles and headers retain the stylized Kenney Future typeface.

### Fixed
- Fixed a visual bug where the beach sand material appeared "cooked" and dark; restored the original pale look while preserving the dynamic wet sand effect from rogue waves.
- Fixed a bug where clicking "Retry" on the lose screen would boot the player to the Title Screen instead of restarting the run.
- The Retry button now correctly resets the level and wave progression back to 1.
- Fixed a bug where the weapon model would disappear and not return after executing the Catastrom ultimate.
- Fixed an exploit where switching weapons via the Pause menu mid-game would magically refill the water tank to 100%; the water tank now correctly maintains its current percentage when a new weapon is equipped.
- Fixed a visual bug where the water meter would briefly flash to full capacity for a split second when switching weapons.
- Fixed an off-by-one error where the "Level Cleared" message would incorrectly display the next level number instead of the level just completed.
- Fixed an issue where the ambient ocean audio aggressively played at the start of the title screen, clashing with the startup synth. The ocean now smoothly fades in *after* the boot sequence completes.
- Fixed a UI state lock that caused the pause menu to freeze when returning from the achievements screen using a mouse.
- Fixed a bug where Godot's UI physics would fail to process scrolling for the achievements menu when the game world was paused.
- The ESC key now correctly closes the achievements screen on the Title Screen.
- Fixed an issue where the Ice Charge and Cooling Power high-score buffs were unlocking at the wrong point thresholds. They now correctly unlock at 20,000 and 15,000 points respectively, matching the design guide.
- Removed the Dev Mode toggle from the Title Screen to enforce standard gameplay unlocks.
- Fixed visual inconsistencies where the gap after menu dividers appeared too large in the Settings and Credits screens due to invisible bounding box padding, strictly aligning them to the standard 24px separation.
- Fixed multiple styling and layout issues on the Lose Screen where duplicate dividers were spawning on language toggle, buttons were sized incorrectly, and text typography was incorrectly applying left-alignment in a centered layout.

---

## [v1.2.0] - 2026-08-14

### Added
- **Sliding Language Toggle:** Upgraded the Title Screen language button to a sleek, animated sliding toggle.
- **Level 6 (Normal Mode):** Added a grueling final level to Normal Mode featuring constant Eclipse weather and the Heat Mirage hazard.
- **Critical Heat Warning:** The UI heat bar now aggressively flashes red when the sun exceeds 90 percent temperature.
- **Catastrom Notification:** Added a distinct purple Toast popup when the Catastrom ultimate is fully charged.
- **Mirage Overshield:** Heat Mirages now act as a formidable boss mechanic on every fifth wave in Endless Mode. They deploy a collective golden Overshield that blocks damage to the main sun and must be completely destroyed.
- **Multi-Flare:** Deep runs in Endless Mode (Wave 10+) now introduce multiple simultaneous solar flares in a shotgun spread pattern.

### Improved
- **Menu Overlays:** Standardized the visual design of all full-screen menus (Title, Pause, Settings, Credits) by applying a consistent golden border and a unified, ultra-dark 96% opacity background dim.
- **Endless Scaling Cap:** Capped the maximum possible heat regeneration in Endless mode at Wave 15. The sun will no longer scale infinitely to the point of being mathematically impossible to cool, preserving the mechanical skill challenge.
- **Catastrom Weather Clear:** Firing the Catastrom in Endless Mode now forcefully clears active Rain or Eclipse events.
- **Boss Scaling:** Boss health now dynamically scales higher with each encounter in Endless Mode.
- **Combo Reward:** Maintaining a combo multiplier above 2.0x now actively regenerates water faster.
- **Level Transitions:** Added a cinematic 2.5 second breather delay between level completions.
- **Weather Persistence:** Weather events (Rain, Eclipse) and Solar Wind gusts now seamlessly persist across wave/level transitions instead of abruptly resetting.
- **Title Screen Layout:** Restructured the main menu buttons from a horizontal row into a clean vertical stack to unify with the game-wide UI design language.
- **Ice Burst Cap:** Capped maximum held Ice Burst charges at 10 to prevent endless hoarding.

### Fixed
- Fixed an issue where the ambient ocean audio would fail to loop and stop playing on the title screen.
- Fixed a bug where the level timer would silently tick down and trigger a Game Over during the cinematic win transition.
- Fixed an issue where the End Screen incorrectly stated "1 LEVELS COMPLETED" instead of the actual number of completed levels.
- Fixed an issue where the Mirage Overshield HP bar would instantly pop in at full health when respawning instead of playing its visual charge-up animation.
- Fixed missing Korean localization for the Scatter Nozzle weapon in the Weapon Wheel.

---

## [v1.1.0] - 2026-08-08

### Added
- **Catastrom Ultimate:** Chargeable ultimate ability to physically grab the sun and instantly dunk it into the ocean to end the wave. Includes custom UI, voice-over, and massive dunk splash.
- **Precision Stream:** Toggled via 'Right Click'. Fires a narrow, intense jet of water that deals rapid heat reduction at the cost of high water drain.
- **Scoring System:** Dynamic Arcade scoring system that heavily rewards continuous cooling, flare interceptions, and debris evaporation, aggressively scaled by your active Combo multiplier. High scores are persistently saved.
- **Title Screen High Score:** The main menu now natively displays your all-time high score beneath the title.
- **Persistent HUD Weather Icon:** A stylized, dynamic icon under the Score counter that visually indicates the current weather state (Normal/Rain/Eclipse).
- **Heat Mirage Mechanic:** In Survival Mode (Wave 6+), high heat triggers a "shell game" where the Sun spawns two angry, ghost-like mirages and dynamically shuffles positions to confuse the player. Shooting mirages instantly breaks the combo meter.

### Improved
- **Weather System Revamp:** Converted the hardcoded 50/50 weather event logic into a data-driven probability system. Level 1 now eases players in with Rainstorms (or no weather), while Boss Waves almost guarantee chaotic Solar Eclipses.
- **Endless Mode Dynamic Scaling:** In Survival Mode, the weather probability weights now dynamically shift based on your survival time, gradually making Solar Eclipses more frequent the longer you survive.
- **Combo System:** Combo multiplier now dynamically scales up to 3.0x over time for continuous tracking, massively boosting Catastrom charging.
- **Combo UI:** The combo multiplier UI text dynamically reflects the exact decimal multiplier, making the tracking reward much clearer.
- **Language Toggle:** Added an instant `[EN / KR]` language toggle button directly to the Title Screen for better accessibility.
- **Credits Screen:** Converted the static multi-column layout into a sleek, vertically scrollable list with a cinematic auto-scroll effect.
- **Magma Debris Physics:** Overhauled the physics for magma debris. Rocks now explode outward realistically and crash heavily onto the beach instead of instantly rocketing away.
- **Magma Debris Persistence:** Magma rocks now remain permanently on the beach where they land, and can be actively evaporated by shooting them with the water gun.

---

## [v1.0.0] - Initial Release

### Added
- **Core Gameplay Loop:** Survive 5 progressively difficult waves against a 3D stylized Sun that generates heat. Includes a two-phase boss encounter on the final wave.
- **Weapon System:** Weapon wheel featuring 4 distinct water blasters (Standard Blaster, Precision Stream, Heavy Cannon, Scatter Nozzle).
- **Abilities:** 
  - **Ice Burst:** Secondary fire that freezes the sun's movement and heat regeneration.
- **Hazards & Enemies:**
  - **Solar Flares:** Interceptable fireballs that cause massive heat spikes.
  - **Solar Wind:** Periodic gusts that physically push the player's aim sideways.
  - **Magma Debris:** Physical rocks spawned from flare interceptions that crash onto the beach, scatter seagulls, and persist indefinitely until evaporated by the player.
- **Dynamic Weather:** Random mid-wave events including Rainstorms (infinite water/cooling) and Solar Eclipses (rapid shadow flares).
- **Environment & Polish:**
  - 3D stylized ocean, beach, and procedural low-poly clouds.
  - Flocks of animated seagulls that feature Bezier flight paths and react to water/debris.
  - Screen shake, heat distortion shaders, dynamic day-to-night lighting, and procedural sun face expressions.
- **UI & Accessibility:**
  - Custom crosshair, dynamic hit feedback, and a Water Stream Combo meter scaling up to 3.0x for continuous tracking.
  - Full localization support for English and Korean.
  - "Reduce Motion" accessibility toggle.
- **Audio:** 
  - Procedural UI synthesizer for sci-fi interface ticks and whooshes.
  - Immersive sound effects for water spraying, sizzling, bird calls, and wind.

---

## [v1.5.1 - WIP]
*(참고: 이 릴리스는 itch.io의 v1.1 버전에 해당합니다)*

### 추가됨 (Added)
* **업적 진행도 UI:** 타이틀 화면과 일시 정지 메뉴에서 잠금 해제되지 않은 누적 업적(예: "갈매기 50마리를 쫓아내세요. (12/50)")에 대한 현재 진행 상황을 동적으로 표시하도록 UI를 업데이트했습니다.
* **게임 로고:** 공식 "Summer Nights" 로고를 Windows(`.exe`) 및 macOS(`.app`) 내보내기용 기본 애플리케이션 아이콘으로 통합했습니다.

### 개선됨 (Improved)
* **물 셰이더 폴리싱:** 양식화된 물 셰이더(`stylized_water.gdshader`)를 업데이트하여 파도의 가파른 정도를 높이고 거품의 밀도와 두께를 증가시켜 훨씬 더 역동적이고 자연스러운 느낌을 구현했습니다.

### 수정됨 (Fixed)
* **그림자 걷는 자 업적:** 일식 이벤트를 성공적으로 생존하고 레벨을 클리어할 때 '그림자 걷는 자' 업적이 정상적으로 해제되지 않던 버그를 수정했습니다.
* **레벨 클리어 화면 일관성:** "다음 단계" 화면(WinScreen)이 게임의 전체 디자인 시스템에 맞게 완전히 개편되었습니다. 이제 실패(Lose) 화면과 시각적으로 완벽하게 일치하도록 24픽셀의 시그니처 황금색 테두리, 중앙 정렬 레이아웃 및 구분선이 적용되었습니다. 또한, 레벨 완료 텍스트(예: "LEVEL 01 COMPLETE")가 영어로 하드코딩되어 한국어 선택 시 동적으로 번역되지 않던 버그를 수정했습니다.

## [v1.5.0]

### 추가됨 (Added)
- **초보자 사격 튜토리얼:** 신규 플레이어가 일반 모드를 처음 플레이할 때 조준 및 사격 방법을 알려주는 새로운 UI 안내문을 추가했습니다. 이 튜토리얼은 화면 중앙 무기 모델 위에 표시되며, 좌클릭이나 우측 트리거(RT)를 눌러 사격하는 즉시 영구적으로 사라지고 진행 상황이 저장됩니다.
- **창 포커스 해제 시 자동 일시정지:** 플레이어가 Alt-Tab을 누르거나 게임 창 외부를 클릭할 때 게임이 백그라운드 포커스 아웃 신호를 감지하고 즉시 일시정지 메뉴를 띄웁니다 (무기 휠이 열려 있다면 자동으로 닫힘). 이를 통해 의도치 않게 게임을 실패하는 상황을 방지합니다.
- **다이내믹 크로스헤어 링:** 크로스헤어를 독립적인 씬으로 재구성했습니다. 이제 조준선 주위에 현재 물탱크 용량을 실시간으로 시각화하는 선명한 벡터 링이 렌더링되어 UI를 내려다볼 필요가 없습니다. 물탱크가 비어있을 때는 링과 조준선이 즉시 붉은색으로 깜박이며, 흑점(Sunspot)에 치명타를 적중시키면 라임 그린색으로 깜박입니다.

### 수정됨 (Fixed)
- **일시정지 중 배경 요소 미정지 버그:** 게임이 일시정지 상태일 때 구름, 해양 파도 셰이더, 물리, 파티클 등이 계속 움직이던 문제를 수정했습니다. 이제 일시정지 시 `get_tree().paused = true`를 호출하여 전체 씬 트리를 완전히 멈추며, HUD는 `PROCESS_MODE_ALWAYS`를 통해 일시정지 중에도 정상적으로 조작할 수 있도록 했습니다. 모든 종료 경로(재개, 재시작, 메인 메뉴)는 화면 전환 전에 올바르게 트리를 재개합니다.

## [v1.4.0]

### 추가됨 (Added)
- **Xbox 컨트롤러 지원:** 게임의 입력 시스템이 Godot의 `InputMap` 백엔드로 완벽하게 마이그레이션되어 Xbox 컨트롤러의 네이티브 플러그 앤 플레이를 지원합니다. 조준은 양쪽 썸스틱(듀얼 스틱)을 사용하여 부드러운 아날로그 움직임을 제공합니다. 핵심 전투 액션은 매끄러운 게임플레이를 위해 세밀하게 매핑되었습니다: 우측 트리거(RT)로 발사, 좌측 트리거(LT)로 얼음 폭발, 우측 범퍼(RB)로 카타스트롬을 사용합니다. 또한 무기 휠에 게임패드 지원이 추가되어, 좌측 범퍼(LB)를 누르고 있는 동안 썸스틱으로 무기를 선택하고 범퍼에서 손을 떼면 즉시 장착할 수 있습니다.
- **게임패드 메뉴 네비게이션:** Xbox 컨트롤러용 전체 UI 네비게이션을 지원합니다. 플레이어는 이제 D-Pad 또는 썸스틱을 사용하여 일시정지, 설정, 조작법 및 게임 오버 화면을 자유롭게 탐색할 수 있습니다. 모든 상호작용 요소(슬라이더, 토글 버튼, 언어 설정 등)에 시각적 포커스 링이 추가되었으며, `B` 버튼을 누르면 하위 메뉴가 올바르게 닫히거나 게임이 재개됩니다.
- **컨트롤러 진동 (Haptics):** 무기 발사, 얼음 폭발, 카타스트롬 사용 시 태양 드래그 및 덩크, 태양풍에 피격될 때 등 핵심 게임플레이 이벤트에 몰입감 있는 컨트롤러 진동을 추가했습니다. 설정 메뉴에 진동을 끄고 켤 수 있는 토글이 추가되었습니다.
- **조작법 메뉴 개편:** 조작법 메뉴에 프리미엄 "슬라이딩 토글(Sliding Toggle Pill)"(언어 설정과 동일한 디자인)이 추가되어 키보드와 Xbox 컨트롤러 조작법을 매끄럽게 전환할 수 있습니다. Xbox 그래픽에는 키보드 다이어그램과 완벽하게 일치하는 벡터 하이라이트가 적용되었습니다.
- **물 셰이더 전면 개편 (Water Shader Overhaul):** 물 셰이더(`stylized_water.gdshader`)를 완전히 다시 작성하여 물리적인 거스트너 파도(Gerstner waves), 절차적으로 생성되어 먼 바다를 가로지르는 보로노이 표면 거품/코스틱 효과, 그리고 높이와 시야각에 따라 파도 마루를 빛나게 하는 가짜 표면하 산란(Subsurface Scattering, SSS) 효과를 추가했습니다.
- **PBR 모래 텍스처 (PBR Sand Texture):** 절차적으로 생성되던 모래 노이즈를 Poly Haven의 고품질 CC0 PBR 텍스처(Coast Sand 01)로 교체하여, 디퓨즈, 노멀, 러프니스 맵을 통해 더욱 부드럽고 양식화된 해변 느낌을 구현했습니다.
- **레트로 포스트 프로세싱 (Retro Post-Processing):** 전반적인 아케이드 감성을 통일하기 위해 필름 그레인, 비네팅, 그리고 신스웨이브 컬러 그레이딩(S 커브 대비 및 보색 스플릿 토닝)을 적용하는 글로벌 화면 셰이더를 추가했습니다.
- **시네마틱 블룸 (Cinematic Bloom):** WorldEnvironment에서 부드러운 가산 블룸(Bloom) 효과를 활성화했습니다. 이제 태양과 동적으로 생성되는 모든 입자(물줄기, 얼음 폭발, 카타스트롬 등)가 발광하여 주변 환경에 자연스럽게 빛을 뿜어냅니다.
- **조작법 메뉴 (Controls Menu):** 플레이어가 어떤 키가 어떤 동작을 하는지 쉽게 확인할 수 있도록 일시정지 화면에 새로운 "조작법" 메뉴를 추가했습니다.
- **카타스트롬 오디오 (itch.io 배포용 안전 오디오):** 카타스트롬 궁극기에 듀얼 오디오 파이프라인을 통합하여, itch.io 배포를 위해 `safe_audio` 기능 태그로 내보낼 때 저작권 문제가 없는 "안전한 오디오" 덩크 소리를 동적으로 불러오도록 구현했습니다. (GitHub 빌드에서는 원본 가면라이더 오디오 유지)

### 수정됨 (Fixed)
- **macOS 내보내기 호환성 (macOS Export Compatibility):** 제한적인 확장 파일 속성(`com.apple.FinderInfo`)으로 인해 Godot의 내장 코드 서명이 조용히 실패하여, 내보낸 macOS 빌드(`.dmg`)가 열리지 않거나 손상된 것으로 보고되던 문제를 수정했습니다. 이제 macOS 배포 파이프라인에서 해당 속성을 수동으로 제거하고 올바른 Ad-Hoc 코드 서명을 강제하도록 개선되었습니다.
- **모래 반사율 및 날씨 동기화 (Sand Reflectivity & Weather):** 새로운 PBR 모래 텍스처가 과도하게 반사되어 젖은 진흙처럼 보이고, 어두운 날씨 이벤트 중에도 밝게 빛나던 문제를 수정했습니다. 이제 재질에 완전한 무광 마감(`specular = 0.0`)을 적용하고 비바람이나 일식 이벤트 동안 방출광(emission)을 동적으로 줄여 주변 조명과 완벽하게 일치하도록 만들었습니다.
- **시네마틱 파도 (Cinematic Rogue Waves):** 이제 돌발 파도가 바다 메시 바깥에서 생성되어 매끄럽게 진입하며, 섬을 향해 다가올수록 높이가 동적으로 부풀어 올라 부딪히기 전 사실적이고 시네마틱한 연출을 보여줍니다. 또한, 모래가 젖어 어두워지는 시각 효과가 파도의 이동 속도 및 충돌 시간에 완벽하게 동기화되도록 수정했습니다. 더불어 해변을 적시지만 작고 의미 없던 파도 생성 로직을 완전히 제거했습니다. 이제 모든 돌발 파도는 무조건 거대한 서핑 파도 크기로 생성되며, 생성 주기를 (12-25초에서 20-35초로) 늘려 더욱 드물고 시네마틱한 이벤트로 느껴지도록 개선했습니다.
- **먼 바다 수평선 (Distant Water Horizon):** 체적 안개(Volumetric Fog)와 과도한 일몰 반사로 인해 먼 바다가 하늘과 지나치게 섞여 보이던 문제를 수정했습니다. 물 셰이더에서 안개 적용을 비활성화하고, 깊이에 따라 프레넬 반사를 자연스럽게 감소시키며, 원경의 바다를 완전히 불투명하게 설정하여 수평선이 선명하고 짙은 파란색으로 뚜렷하게 구분되도록 개선했습니다.
- **모래 빛 반사 (Shiny Sand Highlights):** 마른 모래 위에 인위적으로 플라스틱처럼 반짝이는 반사점이 생기는 것을 방지하기 위해, 태양 광원 및 글로벌 직사광선(DirectionalLight3D)의 스페큘러 빛 방출을 완전히 비활성화했습니다.
- **태양 플레어 요격 효과 (Solar Flare Intercept Effect):** 태양 플레어를 성공적으로 격추했을 때 발생하는 파티클 폭발 효과의 색상을 부자연스러운 보라색/자홍색에서 플레어의 플라즈마 코어와 어울리는 불타는 주황색(`Color(1.0, 0.6, 0.1)`)으로 변경했습니다.
- **크레딧 버튼 색상 (Credits Button Color):** `HUD.gd` 내부에 남아있던 불필요한 수동 마우스 호버 감지 로직으로 인해 "크레딧"과 "설정" 버튼이 표준 노란색 대신 가끔 반투명한 회색으로 렌더링되던 버그를 수정했습니다.
- **무기 휠 꼼수 (Weapon Wheel Exploit):** 무기 휠을 열어 시간이 느려지는 기능을 악용하여 태양풍이나 일식 같은 위험 요소가 지나가기를 기다릴 수 있던 꼼수를 수정했습니다. 이제 무기 휠이 열려 있는 동안 모든 위험 요소의 타이머가 완전히 일시 정지되어 위험 요소에 직접 맞서도록 강제하며, 메인 레벨 타이머는 계속 감소하여 지연 행위에 패널티를 줍니다.
- **조작법 메뉴 정렬:** 키보드와 Xbox 컨트롤러 조작법 행의 너비가 일치하지 않고 대칭으로 늘어나지 않던 UI 레이아웃 버그를 수정했습니다. Godot의 확장 스페이서 패턴(`size_flags_horizontal = 3`)을 구현하여 내부 콘텐츠 크기에 관계없이 좌우 여백을 상단 및 하단 구분선과 완벽하게 일치시키도록 정렬했습니다.
- **창 모드 가독성 (Windowed Mode Legibility):** 폰트 가독성과 시각적 선명도를 극대화하기 위해 이제 게임이 기본적으로 전체 화면(Fullscreen) 모드로 실행되도록 변경했습니다.

---

## [v1.3.0] - 2026-08-21

### 추가됨 (Added)
- **타이달 개틀링 (Tidal Gatling):** 5번째 무기인 거대한 개틀링 건을 추가했습니다. 강력한 냉각력을 자랑하지만 물 소모량이 극심하고 재충전 속도가 느립니다. 엔드게임 루프 목표로 제공되며 "아케이드 전설" 업적 달성 시 해제됩니다.
- **다이내믹 콤보 콜아웃 (Dynamic Combo Callouts):** 콤보 배율이 특정 목표치(1.5x, 2.0x, 2.5x, 3.0x)에 도달할 때마다 역동적으로 팝업되는 아케이드 스타일의 텍스트 콜아웃(예: "시원해!", "빙점!") 기능을 추가하여 타격감을 높였습니다.
- **업적 시스템 (Achievements System):** 타이틀 화면에서 확인할 수 있는 게임 내 업적 갤러리를 추가했습니다. 업적을 달성하면 애니메이션 효과가 적용된 팝업(Toast) 알림과 효과음이 재생됩니다. 각 업적마다 Game-icons.net에서 제공하는 커스텀 벡터 아이콘이 포함되어 있습니다. "새벽이 밝다" (레벨 5 클리어), "아케이드 전설" (10,000점 달성), "슬램 덩크" (카타스트롬 사용), "언터처블" (3.0x 콤보 달성), "단단한 바위" (마그마 파편 증발), "그림자 추적자" (일식 생존), "훠이!" (갈매기 50마리 쫓아내기), "플레어 사냥꾼" (태양 플레어 10회 요격) 업적이 포함되어 있습니다.
- **활성화된 버프 메뉴 (Active Buffs Menu):** 일시정지 화면에 전용 "활성화된 버프" 메뉴를 추가했습니다. 플레이어의 최고 점수와 업적을 동적으로 확인하여 현재 적용 중인 모든 게임플레이 버프와 보상을 실시간 목록으로 보여줍니다.
- **버프 알림:** 최고 점수 버프를 잠금 해제하면 게임 플레이 중 업적 알림과 동일한 디자인 언어를 공유하는 황금색 팝업(Toast) 알림이 표시됩니다. 업적과 동시에 달성될 경우 겹치지 않도록 업적 알림 아래쪽에 표시됩니다.
- **부팅 시퀀스 추가:** 타이틀 화면에 4초간 진행되는 부팅 시퀀스를 추가했습니다. PS1 스타일의 신스 패드 사운드와 함께 화면 가장자리를 따라 그려지는 황금색 테두리 애니메이션이 연출됩니다.
- **돌발 파도 (Rogue Waves):** 먼 수평선에서 섬을 향해 거대한 거품을 일으키며 밀려오는 "돌발 파도"가 무작위로 생성되도록 추가했습니다. 기존의 로우폴리(low-poly) 아트 스타일을 해치지 않으면서 바다를 훨씬 더 역동적이고 생동감 있게 만들어 줍니다.
- **고열 증기 효과 (High Heat Steam):** 태양의 온도가 75%를 초과하면 격렬하게 증기를 뿜어내는 동적 시각 효과를 추가했습니다. 열기가 높아질수록 증기의 밀도와 속도가 증가하여 위험 상태를 시각적으로 경고합니다.
- **초신성 시네마틱 (Supernova Cinematic):** 기존의 단순한 게임 오버 화면을 초신성 폭발 시네마틱으로 교체했습니다. 제한 시간이 끝나면 태양이 거대하게 팽창하며 강렬한 섬광과 함께 게임 오버 메뉴로 전환됩니다. '화면 흔들림 감소' 설정이 켜져 있을 경우 폭발 시 발생하는 강한 카메라 흔들림이 자동으로 비활성화됩니다.

### 개선됨 (Improved)
- **메뉴 아이콘 (Menu Icons):** 조작법 메뉴 타이틀에 사용되던 기본 설정 톱니바퀴 아이콘을 전용 컨트롤러 SVG 아이콘으로 교체했습니다.
- **업적 및 버프 가시성 (Achievements & Buffs Visibility):** 잠긴 업적과 활성화된 버프의 이름과 설명이 더 이상 "???"로 숨겨지지 않습니다. 플레이어가 목표를 쉽게 파악할 수 있도록 잠금 해제 조건과 제목이 명확히 표시되며, 달성하기 전까지는 시각적으로 회색으로 비활성화되어 나타납니다.
- **안전한 배포 대체 (Safe Export Fallbacks):** itch.io 안전 빌드(`safe_audio`)에서는 카타스트롬 궁극기 UI 알림에 사용되던 저작권 아이콘이 자동으로 저작권 없는 "빛나는 공(glowing ball)" 아이콘으로 대체됩니다.
- **환경 폴리싱:** 태양풍(Solar Wind) 위험 요소가 활성화되었을 때 섬의 식물(야자수 및 수풀)이 강하게 구부러지고 흔들리도록 변경하여 풍향을 시각적으로 명확하게 전달합니다.
- **게임 내 업적 확인:** 이제 게임 내 일시정지 메뉴에서도 업적 갤러리에 접근할 수 있어, 타이틀 화면으로 돌아가지 않고도 달성 진행도를 즉시 확인할 수 있습니다.
- **테두리 일관성:** 시작 화면의 커스텀 테두리 드로잉 애니메이션이 게임 내 다른 UI 패널들과 동일한 8픽셀의 둥근 모서리를 가지도록 수학적으로 정확하게 일치시켜 자연스러운 전환을 구현했습니다.
- **버튼 일관성:** 설정, 크레딧, 업적, 버프 등 모든 메뉴의 "돌아가기(BACK)" 버튼을 글로벌 메뉴 버튼 디자인 시스템(280x52 크기, 2px 황금색 테두리, 화살표 접두사 제거)에 완벽하게 일치하도록 통일했습니다.
- **메뉴 폴리싱:** 일시정지, 설정, 크레딧, 업적, 버프 등 모든 메뉴의 디자인을 일관된 좌측 정렬 레이아웃, 통일된 96px 내부 여백, 동일한 구분선 및 정확한 24px 수직 간격, 그리고 텍스트 색상에 맞춘 황금색 UI 아이콘으로 통일했습니다. 접근성을 높이기 위해 메뉴 버튼의 크기도 확대했습니다.
- **버튼 상태 일관성:** 게임 내 모든 주요 메뉴 버튼에 대해 4가지 상호작용 상태(기본, 마우스 오버, 클릭, 비활성화)를 완벽하게 표준화하여, 시각적 피드백과 색상 및 레이아웃 규칙이 일관되게 적용되도록 개선했습니다.
- **일시정지 화면 테두리:** 일시정지 메뉴에 우측 하단이 끊어진 형태의 커스텀 테두리 디자인을 추가하고, 해당 위치에 절차적(procedurally)으로 그려지는 애니메이션 벡터 태양 그래픽을 배치했습니다.
- **타이포그래피 가독성:** 영어 본문 텍스트(업적 설명, 크레딧)에 Inter Medium 폰트를 적용하여 가독성을 개선했습니다. 제목과 헤더에는 스타일리쉬한 Kenney Future 서체가 유지됩니다.

### 수정됨 (Fixed)
- 해변 모래 질감이 어둡게 "타버린" 것처럼 보이던 시각적 버그를 수정했습니다. 돌발 파도의 젖은 모래 효과는 유지하면서 원래의 옅은 색상으로 복구했습니다.
- 패배 화면에서 "다시 시도(Retry)"를 클릭하면 게임이 제대로 재시작되지 않고 타이틀 화면으로 튕기던 버그를 수정했습니다.
- "다시 시도" 버튼이 이제 현재 레벨과 웨이브 진행도를 정상적으로 1로 초기화합니다.
- 카타스트롬 궁극기 사용 후 무기 모델이 사라지고 다시 나타나지 않던 버그를 수정했습니다.
- 게임 중 일시정지 메뉴에서 무기를 교체할 때마다 물탱크가 100%로 마법처럼 꽉 차던 악용 가능한 버그를 수정했습니다. 이제 새 무기를 장착해도 현재의 물 잔량 비율(%)이 올바르게 유지됩니다.
- 무기를 변경할 때 워터 미터가 아주 짧은 순간 동안 시각적으로 가득 찬 상태로 번쩍이는 버그를 수정했습니다.
- "레벨 클리어" 쿨다운 메시지가 방금 완료한 레벨이 아닌 다음 레벨 번호(예: "레벨 2 클리어")를 잘못 표시하던 off-by-one 오류를 수정했습니다.
- 타이틀 화면 시작 시 배경 파도 소리가 부팅 시퀀스의 신스 사운드와 겹쳐서 재생되던 문제를 수정했습니다. 이제 파도 소리는 부팅 시퀀스가 완료된 후 부드럽게 페이드인 됩니다.
- 마우스로 업적 화면에서 일시정지 메뉴로 돌아올 때 메뉴 입력이 멈추던 UI 상태 잠금 버그를 수정했습니다.
- 게임이 일시정지 상태일 때 고도의 UI 물리 엔진이 업적 메뉴의 스크롤을 처리하지 못하던 버그를 수정했습니다.
- 타이틀 화면에서 ESC 키를 눌러 업적 화면을 올바르게 닫을 수 있도록 수정했습니다.
- 얼음 충전 및 냉각력 최고 점수 버프가 잘못된 점수에서 잠금 해제되던 문제를 수정했습니다. 기획서에 맞게 각각 20,000점과 15,000점에서 정상적으로 해제되도록 수정했습니다.
- 일반적인 게임 플레이 환경을 위해 타이틀 화면에서 개발자 모드 토글 버튼을 제거했습니다.
- 설정 및 크레딧 화면에서 메뉴 구분선 아래의 간격이 비정상적으로 넓게 표시되던 시각적 불일치 문제를 수정하여, 모든 메뉴가 표준 24px 간격으로 정확히 정렬되도록 했습니다.
- 패배 화면에서 언어 변경 시 구분선이 중복 생성되거나 버튼 크기가 잘못 적용되던 문제, 그리고 중앙 정렬 레이아웃에서 텍스트가 강제로 좌측 정렬되던 타이포그래피 및 레이아웃 관련 다수의 버그를 수정했습니다.

---

## [v1.2.0] - 2026-08-14

### 추가됨 (Added)
- **슬라이딩 언어 토글:** 타이틀 화면의 언어 버튼을 매끄러운 애니메이션이 적용된 슬라이딩 토글 방식으로 업그레이드했습니다.
- **레벨 6 (일반 모드):** 지속적인 일식 날씨와 열기 신기루 기믹이 등장하는 극한의 최종 레벨을 일반 모드에 추가했습니다.
- **위험 열기 경고:** 태양 온도가 90퍼센트를 초과하면 UI 열기 게이지가 붉은색으로 강하게 깜빡입니다.
- **카타스트롬 준비 알림:** 카타스트롬 궁극기가 완전히 충전되면 눈에 띄는 보라색 팝업 알림이 표시됩니다.
- **신기루 오버실드:** 생존 모드의 매 5번째 웨이브마다 열기 신기루가 강력한 보스 기믹으로 등장합니다. 이들은 본체 태양에 가해지는 피해를 막아내는 황금색 오버실드를 공유하며, 본체를 공격하기 전에 반드시 파괴해야 합니다.
- **다중 플레어:** 무한 모드 후반부(웨이브 10 이상)에서 태양이 샷건처럼 여러 개의 플레어를 동시에 넓게 흩뿌립니다.

### 개선됨 (Improved)
- **메뉴 오버레이:** 모든 전체 화면 메뉴(타이틀, 일시정지, 설정, 크레딧)의 시각적 디자인을 표준화하여 일관된 황금색 테두리와 96% 불투명도의 매우 어두운 배경 밝기 감소 효과를 통일했습니다.
- **무한 모드 스케일링 제한:** 무한 모드에서 발생할 수 있는 최대 열기 회복량을 웨이브 15 수준으로 제한했습니다. 태양이 물리적으로 냉각 불가능한 수준까지 무한정 강해지지 않으며, 순수한 컨트롤 실력 싸움으로 유지되도록 개선했습니다.
- **카타스트롬 날씨 정화:** 생존 모드에서 카타스트롬을 발사하면 활성화된 폭우나 일식 이벤트가 즉시 정화됩니다.
- **보스 체력 스케일링:** 생존 모드에서 보스와 조우할 때마다 보스의 체력이 동적으로 더 높게 조정됩니다.
- **콤보 보상:** 2.0배 이상의 콤보 배율을 유지하면 물이 더 빠르게 회복됩니다.
- **레벨 전환:** 레벨 클리어 시 2.5초간의 시네마틱 휴식 대기 시간을 추가했습니다.
- **날씨 유지:** 날씨 이벤트(폭우, 일식)와 태양풍이 웨이브나 레벨 전환 시 갑자기 초기화되지 않고 매끄럽게 유지되도록 개선했습니다.
- **타이틀 화면 레이아웃:** 메인 메뉴 버튼들을 가로 배열에서 세로 배열로 재구성하여 게임 전체의 UI 디자인 언어와 통일했습니다.
- **얼음 폭발 제한:** 무한정 모이는 것을 방지하기 위해 최대 소지 가능한 얼음 폭발 횟수를 10회로 제한했습니다.

### 수정됨 (Fixed)
- 타이틀 화면에서 재생되는 배경 파도 소리가 한 번 재생된 후 반복되지 않고 끊기는 현상을 수정했습니다.
- 시네마틱 레벨 클리어 전환 중에 레벨 타이머가 뒤에서 조용히 감소하여 게임 오버를 유발하던 버그를 수정했습니다.
- 엔딩 화면에서 완료한 레벨 수가 실제 개수 대신 항상 "1 레벨 완료"로 잘못 표시되던 문제를 수정했습니다.
- 열기 신기루의 오버실드 HP 바가 생성될 때 시각적으로 충전되는 애니메이션이 재생되지 않고 즉시 가득 찬 상태로 나타나던 문제를 수정했습니다.
- 무기 휠에서 스캐터 노즐 무기의 한국어 번역이 누락되어 있던 문제를 수정했습니다.

---

## [v1.1.0] - 2026-08-08

### 추가됨 (Added)
- **카타스트롬 궁극기:** 게이지를 충전하여 태양을 직접 붙잡고 바다로 처박아 즉시 웨이브를 끝내는 궁극기. 커스텀 UI, 보이스오버, 거대한 물보라 효과가 포함됩니다.
- **정밀 물줄기 (Precision Stream):** '우클릭'으로 전환 가능합니다. 좁고 강력한 물줄기를 발사하여 물 소모량은 크지만 열을 빠르게 낮춥니다.
- **점수 시스템:** 활성화된 콤보 배율에 따라 점수가 크게 증가하는 아케이드 스타일의 동적 점수 시스템으로, 지속적인 냉각, 플레어 요격, 파편 증발 시 점수를 부여합니다. 최고 점수는 영구적으로 저장됩니다.
- **타이틀 화면 최고 점수:** 이제 메인 메뉴 타이틀 아래에 기록된 최고 점수가 기본적으로 표시됩니다.
- **HUD 날씨 아이콘:** 현재 날씨 상태(맑음/폭우/일식)를 시각적으로 명확히 보여주는 아이콘을 점수 카운터 아래에 추가했습니다.
- **열기 신기루 (Heat Mirage) 기믹:** 생존 모드 (웨이브 6 이상)에서 열기가 높아지면 태양이 2개의 유령 같은 신기루를 생성하고 서로의 위치를 무작위로 섞어 플레이어를 혼란에 빠뜨립니다. 신기루를 쏘면 콤보 미터가 즉시 초기화됩니다.

### 개선됨 (Improved)
- **날씨 시스템 개편:** 하드코딩된 50/50 날씨 이벤트 로직을 데이터 기반 확률 시스템으로 변환했습니다. 레벨 1에서는 폭우(또는 날씨 없음)로 플레이어를 편안하게 안내하는 반면, 보스 웨이브에서는 혼란스러운 일식이 거의 확실하게 발생합니다.
- **무한 모드 동적 난이도 조절:** 무한 모드(생존 모드)에서 날씨 확률 가중치가 생존 시간에 따라 동적으로 변하여, 오래 살아남을수록 일식이 점진적으로 더 자주 발생하게 됩니다.
- **콤보 시스템:** 물줄기로 태양을 지속적으로 추적할 때 콤보 배율이 시간이 지남에 따라 최대 3.0배까지 증가하여 카타스트롬 충전 속도를 대폭 높여줍니다.
- **콤보 UI:** 콤보 배율 UI 텍스트가 정확한 소수점 배율을 반영하도록 변경되어 추적 보상을 더욱 명확하게 보여줍니다.
- **언어 변경 버튼:** 타이틀 화면 우측 상단에 `[EN / KR]` 언어 변경 버튼을 추가하여 접근성을 개선했습니다.
- **크레딧 화면:** 화면 공간을 많이 차지하던 정적인 다중 열 레이아웃을 영화처럼 자동으로 스크롤되는 매끄러운 단일 세로 스크롤 목록으로 변경했습니다.
- **마그마 파편 물리 효과:** 마그마 파편의 물리 엔진을 전면 개편했습니다. 바위가 즉시 날아가는 대신 현실적으로 바깥쪽으로 폭발하며 해변에 무겁게 떨어집니다.
- **마그마 파편 영구 보존:** 이제 마그마 바위는 해변에 떨어지면 영구적으로 남아있으며, 플레이어가 물총을 쏘아 직접 증발시킬 수 있습니다.

---

## [v1.0.0] - 초기 출시 (Initial Release)

### 추가됨 (Added)
- **핵심 게임플레이 루프:** 열기를 생성하는 3D 태양을 상대로 점차 어려워지는 5번의 웨이브에서 생존하세요. 마지막 웨이브에는 2단계(Two-phase) 보스전이 포함됩니다.
- **무기 시스템:** 4가지 고유한 물총(표준 블래스터, 정밀 스트림, 헤비 캐논, 스캐터 노즐)을 제공하는 무기 휠 기능.
- **특수 능력:** 
  - **얼음 폭발 (Ice Burst):** 태양의 움직임과 열기 회복을 얼려버리는 보조 발사.
- **위협 및 적:**
  - **태양 플레어:** 요격하지 않으면 엄청난 열기 상승을 유발하는 불덩이.
  - **태양풍:** 주기적으로 플레이어의 조준을 옆으로 밀어내는 돌풍.
  - **마그마 파편:** 플레어 요격 시 생성되어 해변에 추락하며, 갈매기들을 쫓아내고 물총으로 증발시킬 때까지 영구적으로 남아있는 물리적 암석 파편.
- **동적 날씨:** 무한대의 물과 냉각을 제공하는 폭우(Rainstorms)와 빠른 섀도우 플레어를 쏘는 일식(Solar Eclipses)을 포함한 무작위 날씨 이벤트.
- **환경 및 폴리싱:**
  - 3D 바다, 해변, 절차적으로 생성되는 로우폴리 구름.
  - 물과 파편에 반응하며 베지어 곡선(Bezier flight paths)으로 비행하는 애니메이션 갈매기 무리.
  - 화면 흔들림(Screen shake), 열기 왜곡 셰이더, 동적 낮/밤 조명 변화, 절차적 태양 표정 애니메이션.
- **UI 및 접근성:**
  - 커스텀 크로스헤어, 역동적인 타격 피드백, 그리고 지속적인 추적 시 최대 3.0배까지 증가하는 물줄기 콤보 미터.
  - 영어 및 한국어 완벽 현지화 지원.
  - "화면 흔들림 감소 (Reduce Motion)" 접근성 토글.
- **오디오:** 
  - SF 스타일의 인터페이스 틱/스와이프 소리를 내는 절차적 UI 신디사이저.
  - 물 분사, 지글거리는 소리, 새 울음소리, 바람 소리 등 몰입감을 높여주는 사운드 이펙트.
