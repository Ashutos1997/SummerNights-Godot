# Changelog

All notable changes to the Summer Nights project will be documented in this file.

## [v1.5.4 - WIP]
*(Note: This release corresponds to v1.4 on itch.io)*

### Fixed
* UI Filter Bleed: Fixed retro filters applying to the start screen.
* Pause Guards: Prevented pausing during screen transitions or game over.
* Hazard Cleanup: Cleared remaining hazards on level transitions.
* Heat Bar Sync: Fixed sub-pixel rounding so temperature correctly resets to 100°C instead of 99°C.
* Wave Timer Pulse: Fixed an infinite tween leak when timers reset.

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

## [v1.5.4 - WIP]
*(참고: 이 릴리스는 itch.io의 v1.4 버전에 해당합니다)*

### 수정됨 (Fixed)
* UI 필터 누출: 타이틀 화면에 레트로 필터가 적용되던 문제 수정.
* 일시정지 보호: 화면 전환 및 게임 오버 시 일시정지를 막아 멈춤 방지.
* 투사체 정리: 레벨 전환 시 남아있는 위험 요소 초기화.
* 열기 게이지 동기화: 게이지 초기화 시 99°C가 아닌 100°C로 정확히 표시되도록 수정.
* 웨이브 타이머 펄스: 타이머 초기화 시 알파 펄스 트윈이 영구 지속되던 누수 수정.

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
