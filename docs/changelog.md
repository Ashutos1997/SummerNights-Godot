# Changelog

All notable changes to the Summer Nights project will be documented in this file.

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
