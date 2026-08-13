# Changelog

All notable changes to the Summer Nights project will be documented in this file.

## [v1.2.0] - WIP

### Added
- **Sliding Language Toggle:** Upgraded the Title Screen language button to a sleek, animated sliding toggle.
- **Level 6 (Normal Mode):** Added a grueling final level to Normal Mode featuring constant Eclipse weather and the Heat Mirage hazard.
- **Critical Heat Warning:** The UI heat bar now aggressively flashes red when the sun exceeds 90 percent temperature.
- **Catastrom Notification:** Added a distinct purple Toast popup when the Catastrom ultimate is fully charged.
- **Mirage Overshield:** Heat Mirages now act as a formidable boss mechanic on every fifth wave in Endless Mode. They deploy a collective golden Overshield that blocks damage to the main sun and must be completely destroyed.

### Improved
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

## [v1.2.0] - WIP

### 추가됨 (Added)
- **슬라이딩 언어 토글:** 타이틀 화면의 언어 버튼을 매끄러운 애니메이션이 적용된 슬라이딩 토글 방식으로 업그레이드했습니다.
- **레벨 6 (일반 모드):** 지속적인 일식 날씨와 열기 신기루 기믹이 등장하는 극한의 최종 레벨을 일반 모드에 추가했습니다.
- **위험 열기 경고:** 태양 온도가 90퍼센트를 초과하면 UI 열기 게이지가 붉은색으로 강하게 깜빡입니다.
- **카타스트롬 준비 알림:** 카타스트롬 궁극기가 완전히 충전되면 눈에 띄는 보라색 팝업 알림이 표시됩니다.
- **신기루 오버실드:** 생존 모드의 매 5번째 웨이브마다 열기 신기루가 강력한 보스 기믹으로 등장합니다. 이들은 본체 태양에 가해지는 피해를 막아내는 황금색 오버실드를 공유하며, 본체를 공격하기 전에 반드시 파괴해야 합니다.

### 개선됨 (Improved)
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
