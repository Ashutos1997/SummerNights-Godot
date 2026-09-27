# Changelog

All notable changes to the Summer Nights project will be documented in this file.

## [v1.5.6] - WIP
*(Note: This release corresponds to v1.6 on itch.io)*

### Added
* Power Up Shared Pool & Dynamic Meter: Unified Catastrom and Celestial Awakening into a shared pool; HUD meter swaps dynamically between Purple (Guns 1–5) and Cyan (Kitsune Buster IX) with charge preserved.
* Celestial Awakening Full Charge Toast: Added cyan toast notification ("CELESTIAL AWAKENING READY [F]") with bespoke starburst icon when the Power Up meter reaches 100% on the Kitsune Buster IX.
* Celestial Awakening Ethereal Filter & HUD FX: Layer 0 post-processing filter with indigo split-toning, cyan energy vignette, 360° reticle timer ring, and holographic text shadows.
* Fox Nine 3D Tails: Procedural 9-tail celestial hydro-ribbon system (CelestialTails.gd) with staggered bloom, traveling waves, and cyan glow.
* 9-Stream Hydro-Cannon: Spiraling 9-stream hydro-vortex with infinite water capacity, 2.0x cooling, and close-range flare-deflecting Creation Aura during Celestial Awakening.
* Kitsune Buster IX: Tokusatsu-inspired celestial water blaster with 6-way weapon wheel integration, revolving 9-vial Kyubi cylinder, and diamond reticle.
* 4 New Achievements: Added "Endurance" (Wave 25), "Marathon Runner" (Wave 50), "Arsenal Expert" (5 weapons used), and "Ice Breaker" (50 Ice Blasts) with live progress tracking.
* Best Endless Wave Tracking: Persistent wave record displayed on the Title Screen ("BEST ENDLESS: WAVE X") and game over celebration badge.
* Celestial Awakening Audio: Dedicated CC0 activation swell and deactivation cooldown sound effects.
* Kitsune Buster IX Dual Modes: Seamless real-time transformation between Cannon and Blade modes via `[X]` / MMB with synchronized 3D animations and reticle morphing.
* Kitsune Blade Melee & Parry: 60° sweeping melee slash (8.5 cooling) that cleaves solar flares for +15% water parry refund.
* 13th Achievement ("The Highlight"): Added achievement and lifetime stat tracking for triggering Celestial Awakening.
* Foxfire Slash Wave: Emits an 85 m/s golden-white flame crescent along the crosshair ray on blade swings.
* Hydro-Tube Emissive Pulsation: Real-time emissive breathing pulse across cylinder vials and coolant lines, shifting to amber below 25% water.
* Liquid Slosh & Barrel Momentum: Fluid inertia tilt in vials and firing-accelerated cylinder rotation with viscous spin-down drag.
* Drone CC0 Audio Overhaul: 7 authentic open-source recordings by rubberduck for multi-voice metal impacts, water shatters, and cryogenic ice shatters.
* Solar Convergence Swarm (Phase 1): Boss encounter on Wave 20+ featuring 6–8 Solar Eye Drones orbiting the Sun, physically intercepting water streams (toggle: `[O]`).
* Equatorial Solar Driver & Planetary Belt (Milestone 2): Custom low-poly 3D Driver & Belt model (`assets/models/solar_driver.glb`, $R \approx 7.15\text{m}$) mounted to the Sun's lower waist ($Y = -3.85\text{m}$, tilted 14° towards camera, keeping the face clear) with obsidian chassis, beveled Sun-Gold frames, lateral eye-drone docking bays ($X = \pm 1.95\text{m}$), and breathing amber iris core. Features authentic Tokusatsu wearing (dual ribbon sweep + magnetic buckle slam + shockwave flash + screen shake) and taking off (unlatch click + buckle spring pop + ribbon peel dissolution) animations (`[L]`).
* The Sun's Henshin Escalation & Full-Sphere Kamen Rider Helmet (Milestone 3): Apex transformation sequence triggered upon player defeating all orbital eye drones (or via `[P]` debug trigger). Features cinematic slow-mo drop, furious Sun power-up surge, waist driver latch, and the slam assembly of the Full-Sphere Kamen Rider Apex Helmet (`assets/models/solar_helmet.glb`, featuring a complete 360° closed armor hull ($R = 8.12\text{m}$) that 100% engulfs the Sun with zero exposed lava, swept V-crest horns, faceted ruby compound eye visors, and 4-tier crusher mouth plate) with hydraulic clamp lock, cheek steam blasts, radial shockwaves, and clean HUD (`[P]`).

### Improved
* Solar Eye Drone Visual Polish: Radiant Sun-Gold & Pearl Ivory armor plating, warm bronze chassis, vermilion inlays, toon shading, and 2.3x scale for crisp beach silhouette.
* Procedural Drone Crack Damage: Stage 1 hairline fissures (≤65% HP) and Stage 2 solar amber fractures with leaking coolant steam wisps (≤35% HP, strobe ≤18%) without red tinting.
* Sun & Drone Geometry: Raised Sun to Y=13.5 (+3m) and adjusted drone orbits ($R = 11.8\text{m}–12.8\text{m}$) to prevent sand dune clipping.
* Kitsune Blade & Collar Detail: Upgraded receiver collar with aperture clamps, bronze Seppa, cyber-gold Habaki, Yokote ridge line, and chisel O-Kissaki tip.
* Kitsune Cannon Muzzle Detail: Aerodynamic fox-fang cowl, compensator brake, stepped vortex nozzle, quad magnetic calipers, and front post sight.
* Controls "Power Up" Legend: Unified `[F]` and `[RB]` input labels from "Catastrom" to "Power Up" across keyboard and gamepad.
* Kitsune Buster 3D Model Polish: Authentic Katana sori curvature, fuller groove, fox-flame tsuba, and skeletonized cylinder window.
* Weapon Wheel Spacing: Replaced angular padding with uniform 12px linear gaps between all slices.
* Weapon Wheel Info Panel: Centered archetype tags, mini-meter stat bars, crit multiplier badge, and hairline dividers.
* Responsive Wheel Stat Bars: Made PWR and CAP progress bars responsive (`SIZE_EXPAND_FILL`) with 10px spacing.
* Articulated Seagull Rig: 2-joint wing rig (Shoulder/Elbow) with aerodynamic folding, thrust bobbing, and banked turns.
* Cloud Depth Parallax: Dynamic cloud drift speeds linked to Z-depth for atmospheric perspective.
* Flare Interception Embers: High-energy golden ember particle bursts when extinguishing solar flares.
* Coronal Halo & Heat Waves: Unshaded additive coronal glow and organic heat ripples scaling with sun temperature.
* Lifetime Stats Icon Plates: 32x32 retro flat plates with gold monochrome icons for each stat category.
* Credits Sync: In-game Credits and bilingual READMEs synchronized with full 1:1 attributions.
* Retro Icon Plates: 64x64 flat plates (4px radii) for Title Screen and HUD achievement/buff cards.
* Game Over Stats Flow: Frameless layout with 32x32 retro plates and inline milestone badges.
* Settings Categorization & Spacing: 3 categorized sections with retro badges, 12px VBox spacing, and high-contrast off-white body labels.
* Weapon Wheel Blaster Preview: Kitsune Buster IX always renders in compact blaster form inside the wheel.
* Kitsune Buster IX Wave 30 Balance: Tuned cooling (28.0), crit (2.2x), water capacity (160), and recharge (14/s) to match Wave 30 sun regen.
* Streamlined Awakening Activation: Removed redundant top toast in favor of HUD-native tails, vignette, and 360° reticle ring.
* Awakening Filter Grading: S-curve contrast and zero-lift indigo split-toning to eliminate milky shadow wash.
* Kitsune Blade Pure Melee: Removed intrusive 2D slash arcs and projectiles in favor of clean 1인칭 tactile flare parrying.
* PBR Material Preservation: Maintained true specular luster on tamahagane steel, cyber-gold, and dark gunmetal.

### Known Issues (Critical)
* Fullscreen End-of-Run Dimming: Win ("Cool Down") and Lose ("The Sun Won") screens render at low brightness in Normal and Endless modes despite modulate 1.0. Root rendering cause under active investigation.

### Fixed
* Kitsune Blade Sun Over-Damage: Rebalanced Blade Mode base strike cooling damage from 45.0 to 8.5 (1.5x crit) to match sustained v1.5 weapon pacing (~24 DPS).
* Level Transition Double-Clearing: Locked melee input and raycast damage during screen fade transitions until the new level fully fades in.
* Kitsune Blade Aim Hit Detection: Replaced broad forward dot-product check with raycast hit detection matching guns.
* Kitsune Blade Drone Damage: Fixed a bug where Kitsune Buster IX Blade Mode swings passed through Solar Eye Drones without dealing damage. Slashing now accurately damages and shatters drones (~2 hits, 1-hit core crit/Awakened) while shielding the Sun behind them.
* Weapon Wheel Overlay Safety: Guaranteed background blur/dim overlay hides immediately upon closing or switching to full-screen menus.

## [v1.5.5] - 2026-09-22
*(Note: This release corresponds to v1.5 on itch.io)*

### Added
* Solar Flare Shield: Procedural boss shield on Endless Wave 15+ that nullifies water damage until shattered with Ice Blast (`[R]`).
* Shield Visuals & Audio: Custom Fresnel pulse shader, impact ripples, deflection sparks, bouncing water droplets, and CC0 shatter/materialize SFX.
* Shield Tactical Cue: Bilingual prompt and HUD meter flash alerting players to shatter the shield with Ice Blast.
* Custom Boot Splash: Bespoke "Made with Godot" intro with golden frame drawing, monochrome Godot logo, PS1 synth swell, and curtain bloom.

### Improved
* Stat Hard Caps: Clamped player Cooling Power (3.5x) and Crit Damage (3.0x) to prevent runaway scaling in Endless Mode.
* Perk Scaling Safety: Added upper and lower safety bounds across all drafting perks to keep deep runs challenging and exploit-free.
* Late Wave Scaling: Added soft water resistance at Wave 100+, raised Sun heat regen ceiling to 45.0, and tuned sway amplitude.
* HUD Credits Sync: Aligned in-game credits screen 1:1 with README attributions in both English and Korean.

### Fixed
* HUD Meter Gating: Hidden Ice Blast and Catastrom meters on Wave 1 until naturally unlocked at Waves 2 and 4.
* Catastrom Lock: Prevented early charge accumulation and activation before reaching Wave 4 / Level 4.

## [v1.5.4] - 2026-09-16
*(Note: This release corresponds to v1.4 on itch.io)*

### Fixed
* UI Filter Bleed: Fixed retro filters applying to the start screen.
* Pause Guards: Prevented pausing during screen transitions or game over.
* Hazard Cleanup: Cleared remaining hazards on level transitions.
* Heat Bar Sync: Fixed sub-pixel rounding so temperature correctly resets to 100°C instead of 99°C.
* Wave Timer Pulse: Fixed an infinite tween leak when timers reset.
* Beach Wave Traversal: Fixed rogue beach waves prematurely collapsing and cutting off mid-beach by extending travel across the island, maintaining swell crest height across the entire shoreline, and preventing early tween interruption.
* Rock Solid Achievement: Fixed the "Rock Solid" achievement not unlocking when shooting or evaporating magma rock debris with water.

### Improved
* Temp Readout: Added live Celsius temperature reading to the heat bar.
* Timer Polish: Low-time wave timer now pulses red and bounces.
* HUD Shadows: Added 4px drop shadow to all HUD panels.
* Weapon Wheel Pointer: Added directional arrow for wheel selection.
* Left Weapon HUD: Expanded bottom-left weapon icon to include localized name and elemental color tinting.
* Weapon Swap Animations: Added physical swap animations.
* Crosshair Bounce: Crosshair scales up briefly on weapon swap.
* Solar Flare Penalties: Missing flares resets combo and applies scaling heat/water penalties.
* Gatling Alignment: Nudged Tidal Gatling 3D model leftwards (-0.15) for center alignment.
* Title Screen Camera: Fine-tuned distance, height, and FOV for a more cinematic perspective.
* Ocean Audio: Processed ambient track to loop seamlessly without a sharp cut.
* Ocean Cross-Swells: Added horizontal distant background waves with a timing lock to prevent clashing with shoreline waves.
* Weapon Wheel Shadows: Added subtle 4px drop shadows to floating wedges and selector needle matching the HUD visor depth.
* Weapon Wheel Pointer Animation: Added smooth morphing transition between the center neutral dot and the directional chevron pointer, with physical scaling, shadow tracking, and color preservation.
* Weapon Wheel Audio: Added button hover tick sound when highlighting weapons on the wheel.
* Drafting Screen Polish: Added tactile staggered card entrance animation, sequential audio ticks, drop shadows, and rarity badges (Common, Uncommon, Rare) with matching border tints.
* Achievement Progress Readouts: Added dedicated right-side progress column with mini gold progress bars and numerical counters (`current / max`) for locked achievements in both Pause and Title menus, and completed badges for unlocked achievements.
* Ice Burst Meter Polish: Replaced crowded discrete pill buttons with a unified 200x24 cyan-frost meter featuring discrete notch dividers and real-time numeric counter (`charges / max`), creating visual harmony across all resource bars.
* Active Buff Card Typography: Unified Active Buff card text sizing with Achievement cards (title reduced to 24px and body description to 15px with 2px vertical separation).
* HUD Credits Screen: Added missing audio attributions (Ice Shoot, Ice Hit, Ocean Waves), procedural systems (Ice VFX, Magma Debris, Solar Wind Hazard, Stream Combo & Sun Expressions), and bilingual fan-project disclaimers to 100% mirror README documentation.

---

## [v1.5.3] - 2026-09-12
*(Note: This release corresponds to v1.3 on itch.io)*

### Added
* Filters Menu: Added Retro Colors, Dithering, PS1 Shading, Heatwave 1984.

### Improved
* Retro Filters: Improved visual fidelity, NTSC chroma delay, quantization, PS1 low-res, and halation.
* Resource HUD: Upgraded to dark retro flat plates.
* Ice Burst: Replaced progress bar with discrete segmented charge cells.
* Catastrom UI: "MAX READY!" text pulses when ultimate is ready.
* Icons: Updated Ice Burst toast and filter menu icons.
* Weather: Clouds react to Rain/Eclipses; seagulls hide or panic based on weather.
* Ice Burst Polish: Added screen frost effect and cyan sun color shift.
* Level Transitions: Added cinematic "Dying Ember" fade out and delay.
* Flare Telegraphs: Flares show a 2D charging ring before launching.
* Audio Ducking: Heavy bass ducking on major impacts and dunks.
* Sun Expressions: Sun reacts dynamically to damage, charging, and dunks.

### Fixed
* HUD Alignment: Grouped and aligned all right-side HUD elements perfectly.
* Visual Glitches: Fixed flare ring clipping, particle coverage, menu spacing, and rogue waves in transitions.

---

## [v1.5.2] - 2026-09-07
*(Note: This release corresponds to v1.2 on itch.io)*

### Added
* Stats: Lifetime tracking for Water Sprayed and Deaths in the main menu.
* Crosshairs: Unique procedural crosshairs for each weapon.
* Draft Perks: Added Glass Cannon, Heavy Water, Reckless Haste.

### Improved
* UI Polish: Added global button hover bounce and UI audio ticks.
* Game Over UI: Added gold borders and improved layout to End screens.
* High Heat Warning: Added red border and heartbeat sound at 85% heat.
* Flare Impacts: Enhanced camera shake, flash, and explosion audio.
* Low Water: Crosshair pulses orange below 25%.
* Accessibility: Reduced motion support for all new UI pulses.
* Controller Friction: Added aim-assist slow-down when hovering the sun.

---

## [v1.5.1] - 2026-09-02
*(Note: This release corresponds to v1.1 on itch.io)*

### Added
* Rogue-lite Perks: Draft 1 of 3 perks after every boss wave.
* Perks HUD: Real-time active buff tracker on the top left.
* Perks: Added 'Gravity Anchor' to reduce sun sway.
* Procedural Fireflies: Reacts dynamically to weather events.
* Achievement UI: Show progress trackers in menus.

### Improved
* Sky Aesthetics: Parallax clouds and twinkling starfields.
* Weapon Wheel: Shows exact unlock conditions for locked weapons.
* Polish: Better island breeze sway, water splashes, and water shader steepness.

### Fixed
* Logic Bugs: Fixed Shadow Walker achievement, missing localization, screenshot freeze, MacOS focus pause, engine lockup on pause, and fullscreen start issues.

---

## [v1.5.0]

### Added
* Tutorial: First-time shooting tutorial prompt.
* Auto-Pause: Game pauses automatically when window loses focus.
* Dynamic Ring: Crosshair ring visually tracks water capacity.

### Fixed
* Pause State: Ensured the entire scene tree correctly freezes on pause.

---

## [v1.4.0]

### Added
* Controller Support: Full Xbox gamepad input for aiming, shooting, and UI.
* Controller Haptics: Immersion vibration for gameplay events.
* Water Shader: Procedural Gerstner waves, Voronoi foam, and subsurface scattering.
* Graphics: PBR sand texture, synthwave post-processing, cinematic bloom.
* Audio: Added safe royalty-free audio fallback for itch.io exports.

### Fixed
* Mac Export: Fixed Ad-Hoc code signing issues on MacOS builds.
* Visual Fixes: Corrected sand reflectivity, distant horizon fog, shiny sand highlights, and flare explosion color.
* Rogue Waves: Made cinematic and synchronized with wet sand.
* Exploit: Pausing weapon wheel no longer skips hazard timers.

---

## [v1.3.0] - 2026-08-21

### Added
* Tidal Gatling: 5th weapon unlocked via achievement.
* Combo Callouts: Floating text for high combo multipliers.
* Achievements: In-game gallery with custom icons and toast notifications.
* Buffs Menu: Tracks active high score rewards.
* Boot Sequence: PS1-style synth boot screen.
* Weather: Rogue waves crash onto the island; High heat boils steam from sun.
* Supernova: Cinematic supernova explosion on Game Over.

### Improved
* Menus: Unified UI styling (borders, margins, gaps, buttons).
* Consistency: Reduced Motion support, itch.io safe export icons, island foliage reacts to wind.

### Fixed
* Fixes: Sand material color, retry button logic, weapon model disappearance, pause exploits, and menu layout bugs.

---

## [v1.2.0] - 2026-08-14

### Added
* UI: Sliding language toggle button.
* Level 6: Added final Normal Mode level with constant Eclipses.
* Heat Mirage: Survival Mode boss mechanic with clones and Overshields.
* Endless Scaling: Multi-flares in deep runs.

### Improved
* Balance: Capped heat scaling at wave 15; Combo 2.0x+ regenerates water.
* Flow: 2.5s breather delay between levels; Weather persists across waves.
* Catastrom: Clears active weather when used.

### Fixed
* Fixes: Title audio loop, transition level timer, missing translations.

---

## [v1.1.0] - 2026-08-08

### Added
* Catastrom Ultimate: Grab and dunk the sun into the ocean.
* Precision Stream: High water drain, rapid cooling alternate fire.
* Scoring: Arcade combo multiplier scoring system.
* Heat Mirage: Shell game mechanic to confuse targeting.

### Improved
* Weather: Probability shifts based on survival time.
* Debris: Magma debris stays on beach and can be evaporated.
* Credits: Auto-scrolling cinematic credits screen.

---

## [v1.0.0] - 2026-07-19 (Initial Release)

### Added
* Core Loop: Survive 5 waves, cool the 3D sun.
* Weapons: 4 blasters and Ice Burst secondary.
* Hazards: Solar flares, solar wind, magma debris.
* Weather: Rainstorms, Solar Eclipses.
* Visuals: 3D stylized ocean, day/night cycle, procedural sun expressions.
* Accessibility: English/Korean localization, Reduce Motion setting.

---

## [v1.5.6] - WIP
*(참고: 이 릴리스는 itch.io의 v1.6 버전에 해당합니다)*

### 추가됨 (Added)
* 파워 업 공유 풀 및 동적 게이지: 카타스트롬과 신성의 각성을 단일 파워 업 충전 풀로 연동; 무기 전환 시 충전량이 보존되며 HUD 게이지가 퍼플(1~5번 총기)과 사이언(구미호 버스터)으로 실시간 전환.
* 신성의 각성 완충 토스트 알림: 구미호 버스터 장착 중 파워 업 게이지 100% 도달 시 전용 성광 아이콘과 사이언 테두리의 토스트 알림("신성의 각성 준비됨 [F]") 표시.
* 신성의 각성 에테리얼 필터 및 HUD 효과: 인디고 분할 톤의 0번 레이어 후처리 필터, 사이언 에너지 비네트, 360° 조준선 타이머 링, 홀로그래픽 텍스트 그림자 적용.
* 구미호 3D 수압 꼬리: 단계별 변신 만개 연출, 흐름 파동 및 사이언 발광을 갖춘 1인칭 9꼬리 절차적 수류 리본 시스템(CelestialTails.gd) 구현.
* 9줄기 집중 하이드로 캐논: 신성의 각성 중 무한 수조, 2.0배 냉각력, 5.5m 근접 플레어 소멸 창조의 오라를 갖춘 나선형 수압 볼텍스 사격 지원.
* 6번째 비밀 무기 (구미호 버스터 IX): 6분할 무기 휠 연동, 9개 바이알 회전식 실린더 챔버, 전용 다이아몬드 조준선을 갖춘 특촬풍 신성 수압 블래스터 추가.
* 신규 업적 4종: "인내심"(25웨이브), "마라톤 주자"(50웨이브), "무기 전문가"(5개 무기 사용), "얼음 파괴자"(얼음 폭발 50회) 추가 및 실시간 진행도 추적 지원.
* 엔들리스 최고 웨이브 추적: 생존 시간과 함께 최고 웨이브(`best_wave`)를 영구 저장하여 타이틀 화면 표시 및 게임 오버 신기록 배지 연동.
* 신성의 각성 전용 효과음: CC0 변신 파워업 스웰 및 쿨다운 에너지 분산 효과음 연동.
* 구미호 버스터 IX 듀얼 모드 변형: `[X]` 키 또는 마우스 휠 클릭으로 포격 모드와 검 모드를 실시간 기계식 애니메이션 및 조준선 모핑과 함께 즉시 전환.
* 구미호 검 근접 베기 및 패링: 태양 플레어를 절단하여 +15% 물탱크를 환급받는 60° 근접 베기(8.5 냉각력) 구현.
* 13번째 신규 업적 ("클라이맥스"): 구미호 버스터 IX로 신성의 각성 최초 발동 시 해금되는 업적 및 영구 통계 추가.
* 여우불 참격파 투사체: 검 휘두르기 시 조준선을 따라 85m/s 속도로 직진하는 황금백색 초승달 화염 및 불티 궤적 투사체 방출.
* 수압 튜브 동적 발광 맥동: 실린더 바이알 및 냉각 파이프의 실시간 호흡 발광 맥동 구현 (수량 25% 미만 시 호박색 경고 전환).
* 유체 슬로싱 관성 및 총열 자동 회전: 바이알 내부 유체 관성 틸트 및 사격 시 가속 회전/감속 정지하는 실린더 물리 모멘텀 적용.
* 드론 CC0 효과음 개편: OpenGameArt의 rubberduck 제작 정품 오디오를 활용한 다보이스 금속 피격음, 수압 파괴음, 극저온 얼음 분쇄음 연동.
* 태양 수렴 드론 군체 (1단계): 20웨이브 이상 보스전에 태양 주위를 공전하며 물줄기를 물리 차단하는 6~8기의 태양 궤도 아이 드론 군체 추가 (토글: `[O]`).
* 적도 솔라 드라이버 및 행성 벨트 (2단계): 얼굴을 가리지 않는 태양 하단 허리($Y = -3.85\text{m}$, 14° 기울기, $R \approx 7.15\text{m}$)에 장착되는 전용 저폴리곤 3D 모델(`assets/models/solar_driver.glb`) 추가 (흑요석 섀시, 썬-골드 프레임, $X = \pm 1.95\text{m}$ 측면 드론 도킹 베이, 호흡 발광 엠버 동공 코어). 특촬풍 장착(듀얼 리본 래핑 + 마그네틱 버클 슬램 + 충격파 발광 + 화면 흔들림) 및 해제(언래치 클릭 + 스프링 팝 + 리본 분해 수납) 애니메이션 연동 (`[L]`).
* 태양 변신(Henshin) 에스컬레이션 & 전구형(360도) 가면라이더 헬멧 (3단계): 플레이어가 모든 궤도 아이 드론을 격파했을 때(또는 `[P]` 디버그 트리거) 발동되는 정점 보스 변신 연출 추가. 슬로우 모션 전환, 태양 분노 각성 및 열기 팽창, 허리 드라이버 체결, 태양 전체를 360도 완벽하게 감싸 용암 구체를 100% 가리는 전구형 흑요석 장갑 선체($R = 8.12\text{m}$), V-크레스트 뿔, 패싯 루비 복안 바이저, 4단 크러셔 입판이 장착된 가면라이더 헬멧(`assets/models/solar_helmet.glb`)의 슬램 체결과 고압 스팀 분출, 방사형 충격파 연동 (`[P]`).

### 개선됨 (Improved)
* 태양 궤도 아이 드론 외형 개선: 썬-골드 및 펄 아이보리 장갑, 브론즈 섀시, 버밀리온 인레이, 툰 셰이딩 및 2.3배 크기 확대로 해변 조준 실루엣 강화.
* 드론 절차적 균열 손상: 1단계 미세 렌즈 균열(HP ≤65%) 및 2단계 솔라 엠버 파쇄선과 냉각수 증기(HP ≤35%, 스트로브 ≤18%)를 과도한 붉은 틴팅 없이 품격 있게 구현.
* 지형 간섭 해소: 태양 기준 높이를 Y=13.5(+3m)로 상향하고 드론 공전 궤도($R = 11.8\text{m}–12.8\text{m}$)를 조정하여 모래사장 클리핑 방지.
* 구미호 검 모드 체결 칼라 개선: 조리개 잠금 클램프, 청동 셋파, 사이버 골드 하바키, 요코테 융기선, 칫솔형 오-킷사키 칼끝 형상 적용.
* 구미호 포격 총구 개선: 구미호 송곳니 카울, 컴펜세이터 브레이크, 단차식 볼텍스 노즐, 4조각 자기 집속 캘리퍼, 전면 가늠쇠 레일 적용.
* 조작 안내 "파워 업" 표기 통일: 조작 안내 화면의 `[F]` 및 `[RB]` 명칭을 "카타스트롬"에서 "파워 업"으로 통합 표기.
* 구미호 버스터 3D 모델 디테일 강화: 정통 카타나 곡률(소리), 혈조, 여우불 츠바, 스켈레톤 실린더 윈도우 디테일 추가.
* 무기 선택 휠 균일 간격: 슬라이스 간격을 일정한 12px 선형 갭으로 통일하여 평행한 레이아웃 유지.
* 무기 정보 패널 개선: 아키타입 태그, 파워/용량 미니 게이지, 치명타 배율 배지, 헤어라인 구분선이 결합된 아케이드 카드 레이아웃 적용.
* 반응형 스탯 바: PWR/CAP 게이지 바 반응형 확장(`SIZE_EXPAND_FILL`) 및 10px 간격 적용.
* 다관절 갈매기 리그: 어깨/팔꿈치 2관절 날개 접기, 비행 바운싱, 뱅킹 선회 역학 적용.
* 구름 깊이 패럴랙스: Z축 깊이에 따른 차등 이동 속도로 입체적인 3D 하늘 흐름 구현.
* 플레어 요격 골든 엠버: 물줄기로 태양 플레어 소화 시 화려한 황금빛 불티(엠버) 파티클 피드백 추가.
* 코로나 헤일로 및 열파: 태양 온도에 반응하여 유기적으로 맥동하고 소화되는 대기 코로나 아우라 및 동심원 열파 효과 구현.
* 기록 메뉴 아이콘 플레이트: 기록 화면 각 항목에 골드 모노크롬 카테고리 아이콘과 32x32 레트로 플레이트 적용.
* 크레딧 동기화: 인게임 크레딧 화면 및 국/영문 README에 신규 3D 모델, CC0 오디오, 시각 효과 애셋 출처 완전 동기화.
* 레트로 아이콘 플레이트: 타이틀 및 HUD의 업적/버프 카드 아이콘에 64x64 레트로 플랫 플레이트(4px 모서리) 적용.
* 게임 오버 프레임리스 기록 요약: 32x32 플레이트와 인라인 신기록 배지를 갖춘 깔끔한 기록 플로우 적용.
* 설정 메뉴 카테고리화 및 여백: 3개 카테고리 배지, 12px 간격, 고대비 오프화이트 라벨을 적용한 시각적 위계 확립.
* 무기 휠 블래스터 뷰 고정: 무기 선택 휠에서 구미호 버스터를 항상 컴팩트한 블래스터 모드로 표시하여 휠 균형 유지.
* 구미호 버스터 30웨이브 밸런스: 30웨이브 태양 패시브 열기 재생에 맞춰 냉각력(28.0), 치명타(2.2x), 물 용량(160), 충전 속도(14/s) 정밀 조율.
* 불필요한 토스트 알림 제거: 상단 팝업 토스트 대신 3D 꼬리, 비네트, 360° 조준선 링 등 HUD 네이티브 시각 효과로 신성의 각성 안내.
* 에테리얼 필터 명암 개선: S-커브 명암 강화 및 블랙 리프트 없는 인디고 분할 톤으로 깊은 암부 대비 확보.
* 순수 근접 패링 특화: 화면 하단 참격 호 메시와 투사체를 제거하고 1인칭 카타나 휘두르기 및 플레어 절단 패링에 집중.
* PBR 메탈릭 재질 보존: 타마하가네 강철, 사이버 골드, 건메탈 고유의 금속성 반사 광택 보존.

### 알려진 문제 (Known Issues - Critical)
* 전체화면 라운드 종료 화면 밝기 저하: 일반 및 무한 모드 모두에서 승리("Cool Down") 및 패배("The Sun Won") 화면이 어둡게 렌더링되는 현상 (원인 추적 중).

### 수정됨 (Fixed)
* 구미호 검 태양 과다 냉각 버그 수정: 검 모드 기본 냉각 피해량을 45.0에서 8.5(치명타 1.5배)로 재조정하여 v1.5 무기 규격(~24 DPS)에 맞춤.
* 레벨 전환 시 연속 클리어 버그 수정: 화면 페이드 전환 중 근접 입력 및 사격을 잠금 처리하여 조기 클리어 방지.
* 구미호 검 조준 타격 판정 수정: 전방 내적 판정 대신 레이캐스트 조준선 판정을 적용하여 조준선이 태양에 위치할 때만 타격되도록 수정.
* 구미호 검 드론 피격 판정 수정: 구미호 버스터 IX 검 모드 공격 시 태양 궤도 아이 드론에 피해가 들어가지 않던 버그 수정. 검 휘두르기로 드론을 정상 타격 및 파괴(일반 2타, 코어 치명타/각성 시 1타)할 수 있으며 태양 차단 판정이 정확히 적용됨.
* 무기 선택 휠 오버레이 안전성 강화: 메뉴 전환 및 휠 종료 시 배경 블러/딤 오버레이가 즉시 숨겨지도록 수정.

## [v1.5.5] - 2026-09-22
*(참고: 이 릴리스는 itch.io의 v1.5 버전에 해당합니다)*

### 추가됨 (Added)
* 태양 플레어 실드: 무한 모드 15웨이브 이상 보스에 등장하며, 얼음 폭발(`[R]`)로 파괴하기 전까지 물 피해를 완전 무효화하는 에너지 실드 추가.
* 실드 비주얼 및 오디오: 프레넬 펄스 셰이더, 물방울 튕김 파티클, 충격 리플 및 전용 생성/파괴 효과음 적용.
* 실드 전술 알림: 실드 피격 시 아이스 버스트 게이지 점멸 및 파괴 유도 다국어 토스트 알림 추가.
* 커스텀 부트 스플래시: 골드 프레임 드로잉, 모노크롬 고도 엔진 로고, PS1 신스 사운드 및 커튼 리빌 연출을 갖춘 인트로 화면 추가.

### 개선됨 (Improved)
* 능력치 하드 캡: 무한 모드 밸런스 붕괴를 방지하기 위해 냉각력(3.5배) 및 치명타 피해(3.0배) 상한선 적용.
* 퍽 스케일링 안전 경계: 후반 무한 모드에서 모든 특성에 상·하한선을 두어 익스플로잇 방지 및 긴장감 유지.
* 후반 웨이브 스케일링: 100웨이브 이후 물 소프트 저항 도입, 태양 최대 열기 재생 상한 상향(45.0), 흔들림 진폭 최적화.
* 크레딧 동기화: 게임 내 크레딧 화면을 README 문서와 1:1로 일치시키고 다국어 표기 보강.

### 수정됨 (Fixed)
* 자원 HUD 표시 오류: 무한 모드 1웨이브에서 아직 미해금된 아이스 버스트 및 카타스트롬 게이지가 보이던 문제 수정.
* 카타스트롬 잠금 제어: 4웨이브 / 레벨 4 이전에는 게이지 충전 및 스킬 발동이 되지 않도록 수정.

## [v1.5.4] - 2026-09-16
*(참고: 이 릴리스는 itch.io의 v1.4 버전에 해당합니다)*

### 수정됨 (Fixed)
* UI 필터 누출: 타이틀 화면에 레트로 필터가 적용되던 문제 수정.
* 일시정지 보호: 화면 전환 및 게임 오버 시 일시정지를 막아 멈춤 방지.
* 투사체 정리: 레벨 전환 시 남아있는 위험 요소 초기화.
* 열기 게이지 동기화: 게이지 초기화 시 99°C가 아닌 100°C로 정확히 표시되도록 수정.
* 웨이브 타이머 펄스: 타이머 초기화 시 알파 펄스 트윈이 영구 지속되던 누수 수정.
* 해변 파도 연출: 파도가 해변 중간에서 갑자기 사라지거나 끊기던 문제를 해결하여, 섬 전체를 완전히 가로질러 덮치도록 이동 거리와 높이 트윈 타이밍을 정상화하고 조기 종료 인터럽트를 방지.
* 단단한 바위 업적: 물총으로 마그마 파편을 쏘거나 증발시켜도 "단단한 바위(Rock Solid)" 업적이 해금되지 않던 문제 수정.

### 개선됨 (Improved)
* 온도 표시: 열기 게이지에 실시간 섭씨 온도 추가.
* 타이머 폴리싱: 시간이 부족할 때 타이머가 붉게 깜박이며 튕기는 애니메이션 추가.
* HUD 그림자: 모든 HUD 패널에 4px 드롭 섀도우 추가.
* 무기 휠 포인터: 휠 선택 방향을 알려주는 화살표 추가.
* 좌측 무기 HUD: 좌측 하단 아이콘에 무기 이름과 원소 색상 표시 추가.
* 무기 교체 애니메이션: 물리적인 무기 교체 애니메이션 추가.
* 크로스헤어 바운스: 무기 교체 시 크로스헤어 크기 일시적 증가.
* 태양 플레어 페널티: 플레어 충돌 시 콤보 초기화 및 진행도 비례 열기/물 증발 페널티 적용.
* 개틀링 정렬: 타이달 개틀링 3D 모델 중심축 미세 조정 (-0.15).
* 타이틀 화면 카메라: 거리, 높이 및 시야각(FOV)을 조정하여 더 시네마틱한 연출 적용.
* 바다 오디오: 끊김 현상 없이 자연스럽게 반복되도록 앰비언트 트랙 믹싱 처리.
* 바다 크로스 스웰: 해안가 파도와 겹치지 않도록 타이밍 잠금이 적용된 원경 가로 파도 추가.
* 무기 휠 그림자: HUD 바이저 깊이감과 일치하도록 플로팅 웨지 및 선택 화살표에 은은한 4px 드롭 섀도우 추가.
* 무기 휠 포인터 애니메이션: 중앙 중립 도트와 방향성 셰브론 포인터 간의 물리적 스케일링, 그림자 추적 및 색상 유지가 적용된 부드러운 모핑 전환 애니메이션 추가.
* 무기 휠 효과음: 무기 휠에서 각 무기 슬라이스를 호버/선택할 때 버튼 호버 틱 사운드 재생 추가.
* 특성 드래프트 연출: 카드 딜링 순차 등장 애니메이션, 효과음 틱, 드롭 섀도우 및 등급별 태그(일반, 고급, 희귀)와 테두리 틴트 추가.
* 업적 진행도 표시: 일시정지 및 타이틀 메뉴의 잠긴 업적에 미니 골드 진행도 바와 수치 카운터(`현재 / 최대`)가 포함된 전용 상태 열 및 완료 배지 추가.
* 얼음 폭발 게이지 개선: 다수의 충전 보유 시 답답하게 보이던 개별 알약 형태의 버튼들을 물/카타스트롬과 대칭을 이루는 200x24 일체형 사이언 프로스트 게이지로 개편하고, 미세 눈금 분할선 및 실시간 수치 카운터(`현재 / 최대`) 적용.
* 활성 버프 카드 타이포그래피: 활성 버프 카드의 텍스트 크기를 업적 카드와 일치하도록 통일(제목 24px, 설명 15px 및 2px 수직 간격 적용).
* HUD 크레딧 화면: 누락되었던 효과음(얼음 발사음, 얼음 피격음, 바다 파도 앰비언스), 절차적 시스템(얼음 폭발 VFX, 마그마 파편, 태양풍, 물줄기 콤보 및 태양 표정), 그리고 비영리 팬 제작물 면책 조항을 추가하여 README 문서와 100% 일치하도록 보완.

---

## [v1.5.3] - 2026-09-12
*(참고: 이 릴리스는 itch.io의 v1.3 버전에 해당합니다)*

### 추가됨 (Added)
* 필터 메뉴: 레트로 색상, 디더링, PS1 셰이딩, 폭염 1984 필터 추가.

### 개선됨 (Improved)
* 레트로 필터: 그래픽 개선, NTSC 크로마 지연, 픽셀화, 할레이션 퀄리티 강화.
* 자원 HUD: 다크 레트로 플랫 패널 디자인으로 개편.
* 얼음 폭발: 게이지를 개별 충전 칸 디자인으로 교체.
* 카타스트롬 UI: 궁극기 충전 시 "준비 완료!" 텍스트 깜박임 연출.
* 아이콘: 얼음 폭발 알림 및 필터 메뉴 아이콘 업데이트.
* 날씨 반응: 비/일식에 구름 색상이 변하며 갈매기가 날씨에 따라 행동함.
* 얼음 폭발 폴리싱: 사용 시 화면 서리 효과 및 태양 색상 청록색 변화.
* 레벨 전환: "잔불" 페이드 아웃 연출 및 시네마틱 딜레이 추가.
* 플레어 전조 증상: 발사 전 2D 충전 링 표시.
* 오디오 더킹: 큰 타격이나 궁극기 덩크 시 강력한 베이스 오디오 더킹 적용.
* 태양 표정: 피격, 충전, 궁극기 피격 시 동적 표정 추가.

### 수정됨 (Fixed)
* HUD 정렬: 우측 HUD 요소 간격 및 우측 정렬 통일.
* 시각적 오류 수정: 플레어 링 잘림, 파티클 범위, 메뉴 간격, 전환 중 파도 생성 버그 수정.

---

## [v1.5.2] - 2026-09-07
*(참고: 이 릴리스는 itch.io의 v1.2 버전에 해당합니다)*

### 추가됨 (Added)
* 통계: 물 분사량 및 총 사망 횟수 영구 추적 메뉴 추가.
* 크로스헤어: 무기마다 고유한 모양의 동적 크로스헤어 적용.
* 드래프트 퍽: 유리 대포, 중수, 무모한 가속 퍽 추가.

### 개선됨 (Improved)
* UI 폴리싱: 모든 버튼 호버 바운스 및 상호작용 오디오 틱 소리 추가.
* 게임 오버 UI: 종료 화면에 금빛 테두리 및 레이아웃 개선.
* 고열 경고: 온도 85% 초과 시 붉은 화면 테두리와 심장 박동음 추가.
* 플레어 충돌: 카메라 흔들림, 플래시, 폭발 오디오 강화.
* 물 부족: 물탱크 25% 이하 시 크로스헤어 주황색 깜박임.
* 접근성: 모든 새로운 펄스 효과에 '움직임 감소' 옵션 완벽 지원.
* 컨트롤러 마찰력: 태양 조준 시 조준선 느려짐(에임 어시스트) 적용.

---

## [v1.5.1] - 2026-09-02
*(참고: 이 릴리스는 itch.io의 v1.1 버전에 해당합니다)*

### 추가됨 (Added)
* 로그라이트 퍽: 보스 웨이브 이후 3개의 퍽 중 하나 선택 (드래프팅).
* 퍽 HUD: 좌측 상단에 실시간 활성화 버프 트래커 추가.
* 신규 퍽: 태양 흔들림을 줄이는 '중력 닻' 추가.
* 절차적 반딧불이: 날씨에 동적으로 반응하는 반딧불이 입자.
* 업적 UI: 메뉴에서 누적 업적 진행도 표시 기능.

### 개선됨 (Improved)
* 하늘 미학: 다층 시차 구름 및 반짝이는 별밭 추가.
* 무기 휠: 잠긴 무기의 정확한 해금 조건 명시.
* 폴리싱: 해변 산들바람 흔들림, 물보라 파티클, 물 셰이더 파도 가파름 개선.

### 수정됨 (Fixed)
* 로직 버그: 그림자 걷는 자 업적 버그, 누락된 번역, 스크린샷 멈춤, MacOS 포커스 및 엔진 멈춤 문제 완벽 수정.

---

## [v1.5.0]

### 추가됨 (Added)
* 튜토리얼: 첫 플레이 시 조준 및 사격 안내 팝업.
* 자동 일시정지: 게임 창 포커스를 잃을 때 자동 일시정지 되도록 개선.
* 동적 링: 크로스헤어 주위에 물탱크 용량을 실시간 링으로 표시.

### 수정됨 (Fixed)
* 일시정지 상태: 일시정지 시 전체 씬 트리가 올바르게 멈추도록 버그 수정.

---

## [v1.4.0]

### 추가됨 (Added)
* 컨트롤러 지원: 조준, 사격, UI 탐색 등 Xbox 게임패드 완벽 호환.
* 컨트롤러 진동: 게임플레이 주요 이벤트에 진동(햅틱 피드백) 추가.
* 물 셰이더: 절차적 거스트너 파도, 보로노이 거품, 표면하 산란 효과 도입.
* 그래픽: PBR 모래 텍스처, 신스웨이브 포스트 프로세싱, 시네마틱 블룸.
* 오디오: itch.io 배포를 위한 저작권 무료 대체 오디오 파일 추가.

### 수정됨 (Fixed)
* Mac 배포: MacOS 빌드의 Ad-Hoc 코드 서명 호환성 문제 해결.
* 시각 수정: 모래 반사율, 원경 안개, 플레어 폭발 색상 등 다수 그래픽 버그 수정.
* 돌발 파도: 파도를 시네마틱하게 변경하고 젖은 모래 효과와 시각적 동기화.
* 꼼수 방지: 무기 휠을 켜고 일시정지로 위험 요소 시간을 넘기는 꼼수 방지.

---

## [v1.3.0] - 2026-08-21

### 추가됨 (Added)
* 타이달 개틀링: 업적 달성 시 해금되는 5번째 헤비 무기.
* 콤보 콜아웃: 높은 콤보 도달 시 역동적으로 떠오르는 텍스트 연출.
* 업적: 인게임 갤러리와 커스텀 아이콘 알림 기능이 있는 업적 시스템 추가.
* 버프 메뉴: 활성화된 하이스코어 보상 버프를 추적하는 메뉴 추가.
* 부팅 시퀀스: 타이틀 화면에 PS1 스타일 씬스 사운드와 테두리 애니메이션 도입.
* 기상 효과: 해변을 강타하는 돌발 파도 및 고열 시 태양 증기 방출 시각 효과.
* 초신성: 타임 오버 시 시네마틱 초신성 폭발 화면 적용.

### 개선됨 (Improved)
* 메뉴: 여백, 테두리, 버튼, 간격 등 전반적인 UI 통일 디자인 구축.
* 일관성: 모션 감소 호환 및 바람에 흔들리는 섬 식물 등 개선.

### 수정됨 (Fixed)
* 버그 수정: 모래 질감 색상 버그, 재시작 버튼 로직, 무기 휠 악용 꼼수, 메뉴 레이아웃 정렬 수정.

---

## [v1.2.0] - 2026-08-14

### 추가됨 (Added)
* UI: 슬라이딩 애니메이션이 적용된 언어 토글 버튼 추가.
* 레벨 6: 일식이 지속되는 일반 모드 최종 레벨 추가.
* 열기 신기루: 환영과 보호막을 소환하는 생존 모드 보스 패턴.
* 무한 스케일링: 극후반 무한 모드(웨이브 10 이상)에서 다중 플레어 산탄 발사 등장.

### 개선됨 (Improved)
* 밸런스: 무한 모드 열기 재생을 웨이브 15로 상한 캡 적용; 2.0x 콤보 이상 시 물 점진적 재생 기능 추가.
* 흐름: 레벨 간 2.5초 지연(숨고르기) 시간 부여; 날씨가 웨이브를 넘어 지속되도록 개선.
* 카타스트롬: 궁극기 사용 시 현재 날씨 이벤트를 강제 맑음 처리.

### 수정됨 (Fixed)
* 버그 수정: 타이틀 오디오 루프 오류, 전환 중 타이머 작동 버그, 번역 누락 수정.

---

## [v1.1.0] - 2026-08-08

### 추가됨 (Added)
* 카타스트롬 궁극기: 게이지 충전 시 태양을 잡아 바다에 던져 덩크슛하는 기능.
* 정밀 스트림: 물 소모가 매우 크고 냉각이 빠른 보조 발사 무기.
* 점수 시스템: 콤보에 비례하여 증가하는 아케이드 점수 시스템 추가.
* 열기 신기루: 환영을 만들어 혼란을 주는 신기루 보스 메커니즘.

### 개선됨 (Improved)
* 날씨: 무한 모드 생존 시간에 따라 일식 기상 확률이 동적으로 증가.
* 파편: 마그마 잔해가 해변에 남아 직접 물을 쏴서 증발시킬 수 있도록 개선.
* 크레딧: 자동 스크롤되는 시네마틱 크레딧 화면 적용.

---

## [v1.0.0] - 2026-07-19 (초기 출시)

### 추가됨 (Added)
* 핵심 루프: 5웨이브 연속 생존, 3D 태양 냉각 메커니즘.
* 무기: 4종의 물총(Blaster)과 얼음 폭발(Ice Burst) 보조 공격.
* 위험 요소: 태양 플레어, 태양풍 돌풍, 마그마 파편 비.
* 날씨: 폭우(물 무한), 개기 일식(시야 차단).
* 시각 효과: 3D 양식화 바다 셰이더, 밤낮 주기 조명 변화, 절차적 3D 표정.
* 접근성: 영어 및 한국어 이중 언어 지원, 모션 감소(Reduce Motion) 옵션 제공.
