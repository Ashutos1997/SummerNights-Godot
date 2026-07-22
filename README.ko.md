[English](README.md)

# 썸머 나이츠

Godot 4로 제작된 3D 아케이드 슈터. 태양을 식히기 전에 열기에 압도당하지 마세요.

---

## 게임플레이 영상

[![Gameplay Video](https://img.youtube.com/vi/6r5lm0zydUM/maxresdefault.jpg)](https://youtu.be/6r5lm0zydUM)

---

## 🎮 게임플레이
- **태양 제압:** 타이머가 종료되기 전에 태양에 물을 뿌려 온도를 0으로 낮추세요! 태양은 시간이 지남에 따라 점차 열기를 회복합니다.
- **5단계 난이도:** 레벨이 올라갈수록 타이머가 짧아지고, 태양의 움직임(좌우 흔들림 및 8자 패턴)이 공격적으로 변하며 열기 회복 속도가 증가합니다.
- **5단계 보스 페이즈:** 마지막 5단계는 태양이 열기를 회복하고 속도가 빨라지는 2단계(Two-phase) 패턴을 특징으로 합니다.
- **패배 조건:** 태양을 식히기 전에 타이머가 0에 도달하면 레벨 실패가 되며 다시 시도해야 합니다.
- **전략적 열 분출구:** 태양 표면에 매우 뜨거운 임계 분출구가 있습니다. 이 지점을 정확히 맞추면 태양을 **2.4배 빠르게** 식힐 수 있습니다.
- **태양 플레어 (불덩이):** 태양이 주기적으로 플레이어를 향해 뜨거운 플레어를 발사합니다. 물줄기로 0.33초 동안 추적하여 공중에서 요격해야 합니다. 플레어를 파괴하면 즉시 **물통이 30% 충전**됩니다.
- **얼음 폭발 (Ice Burst):** 3단계부터 강력한 얼음 폭발 기능이 해제됩니다! 시간이 지나면서 3개의 충전을 모은 후 우클릭(또는 R키)을 눌러 태양을 향해 얼음 조각을 발사하세요. 3초 동안 태양의 모든 움직임과 열기 회복이 완전히 정지됩니다.

---

## 조작법

| 입력 | 동작 |
|---|---|
| 마우스 이동 | 물 대포 조준 |
| 왼쪽 클릭 (유지) | 물 분사 |
| 우클릭 / R | 얼음 폭발 발사 (충전 시) |
| ESC | 설정 / 크레딧 열기 |

---

## 주요 기능

- 물통 자원 관리 — 소진 및 충전 사이클
- 태양 열 분출구 — 치명적 냉각 및 증기 폭발 효과
- 포물선 태양 파편 — 공중 요격 시 물 보충
- 절차적 생성 3D 구름 (CloudLayer.gd)
- 날개 퍼덕이는 애니메이션이 있는 갈매기 (SeagullLayer.gd)
- 야자수와 덤불의 바람 흔들림 효과
- 하늘, 열기 왜곡, 파도 물결 커스텀 GLSL 셰이더
- WCAG 2.1 AA/AAA 준수 UI — 고대비 모드, 모션 감소, 감도 조절
- macOS (인텔 + 애플 실리콘 Universal Binary) 및 Windows .exe 출시

---

## 실행 방법

1. Godot 4.7.1 (stable) 실행
2. 프로젝트 관리자에서 가져오기 클릭
3. 이 폴더로 이동하여 `project.godot` 선택
4. 가져오기 및 편집 클릭 후 F5 눌러 실행

---

## 프로젝트 구조

```
SummerNights-Godot/
├── project.godot
├── scenes/
│   ├── TitleScreen.tscn      - 타이틀 화면
│   ├── LoadingScreen.tscn    - 로딩 화면
│   ├── Main.tscn             - 3D 게임플레이 씬
│   └── HUD.tscn              - 2D UI 레이어
├── scripts/
│   ├── Main.gd               - 핵심 게임 루프, 태양 파편, 분출구, 환경
│   ├── HUD.gd                - HUD, 설정, 크레딧, 크로스헤어, 승리 화면
│   ├── CloudLayer.gd         - 절차적 생성 3D 구름
│   ├── SeagullLayer.gd       - 애니메이션 갈매기
│   ├── GameState.gd          - 오토로드 상태 (레벨, 볼륨, 접근성, 언어)
│   └── LoadingScreen.gd      - 로딩 화면 전환
└── assets/
    ├── summer_night_sky.gdshader
    ├── heat_haze.gdshader
    ├── stylized_water.gdshader
    ├── fonts/                - Galmuri11.ttf (한국어 지원)
    ├── models/
    ├── pirate/
    └── audio/
```

---

## 기술 스택

| 분야 | 기술 |
|---|---|
| 엔진 | Godot Engine 4.7.1 (stable) |
| 렌더링 | Forward+ (Metal / Vulkan) |
| 언어 | GDScript |
| 후처리 | SSAO, SSIL, SSR, 볼류메트릭 안개, 블룸 |

---

## 크레딧

0% 생성형 AI. 모든 에셋은 수작업, CC0 오픈소스, 또는 절차적 GDScript로 제작되었습니다.

| 에셋 | 제작자 | 라이선스 |
|---|---|---|
| 3D 태양 모델 - PS1 Style Low Poly Sun | albert_buscio (Sketchfab) | CC0 |
| 3D 총 모델 - 3D Blaster | Kenney | CC0 |
| 야자수, 바위, 모래 - Pirate Pack | Kenney | CC0 |
| 양식화된 하늘 셰이더 | MinionsArt | CC0 |
| 양식화된 물 셰이더 | Jtfinlay | MIT |
| 열기 왜곡 셰이더 | MinionsArt | CC0 |
| 폰트 - Kenney Future | Kenney | CC0 |
| 한국어 폰트 - Galmuri11 | quiple | SIL OFL |
| UI Pack Adventure | Kenney | CC0 |
| SFX - 40가지 CC0 물/물결 효과음 | OpenGameArt | CC0 |
| SFX - 물총 발사음 | belanhud (Freesound) | CC0 |
| SFX - UI 오디오 팩 | Kenney | CC0 |
| SFX - 얼음 발사음 | urupin (Freesound) | CC0 |
| SFX - 얼음 피격음 | antonsoederberg (Freesound) | CC0 |
| VFX - 얼음 폭발 발사체 및 입자 효과 | 절차적 고도(Godot) 기본 도형 | - |
| 절차적 구름 및 갈매기 | 수작업 GDScript | - |
| 태양 표정 (Sun Face) | 절차적 Godot Image draw API | - |
