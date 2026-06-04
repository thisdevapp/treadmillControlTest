# 🌙 Sleep Prototype (로컬 전용 정밀 수면일지)

정신과 진료 시 의사에게 정확하고 정밀한 수면 데이터를 제공하기 위한 **Consensus Sleep Diary (CSD)** 기반의 고성능 수면 관리 앱입니다.

## 🚀 프로젝트 철학
- **Privacy First**: 모든 데이터는 기기 내부 SQLite(Drift)에만 저장되며, 외부 서버와 통신하지 않는 완전한 로컬 프라이버시를 보장합니다.
- **Doctor-Friendly**: 의사가 진료실에서 10초 이내에 환자의 수면 패턴, 효율, 약물 복용 시점을 한눈에 파악할 수 있도록 최적화된 리포트 뷰를 제공합니다.
- **Precision Data**: 단순 기록을 넘어 Unix Timestamp 기반으로 모든 수면 세션을 초 단위로 정밀하게 관리합니다.

## 🛠 기술 스택
- **Framework**: Flutter (Material 3)
- **Database**: Drift (SQLite) - **Schema v11 (Responsive Custom Data)**
- **State Management**: RxDart (Stream 통합 및 실시간 동기화)
- **UI Engine**: Custom Painter (지능형 통합 지표 시스템 탑재)
- **UX**: Haptic Feedback Engine (물리적 기록 확인 시스템)

## ✨ 핵심 기능 및 업데이트 (v4.0 - Android Style Dashboard)

### 1. 차세대 인터랙티브 대시보드 (Next-Gen Interaction)
- **Android Launcher UX**: 위젯의 위치와 크기를 조작하는 안드로이드 순정 대시보드 방식을 Flutter로 완벽 구현했습니다.
- **드래그 앤 드롭 이동**: 편집 모드에서 위젯을 잡고 원하는 위치로 자유롭게 옮길 수 있으며, 실시간 고스트 가이드가 스냅 위치를 안내합니다.
- **자유로운 크기 조절**: 위젯 우측 하단의 전용 핸들을 드래그하여 1x1, 2x2, 4x2 등 원하는 크기로 즉시 변경 가능합니다.
- **지능형 자동 정렬**: 위젯이 겹치거나 열 범위를 벗어날 경우, 시스템(`fixDataIntegrity`)이 상단부터 비어 있는 공간을 찾아 자동으로 최적 배치합니다.

### 2. 반응형 그리드 아키텍처 (Responsive Design)
- **기기 맞춤형 레이아웃**: 스마트폰(4열)과 태블릿(6열) 환경을 감지하여 화면 폭에 최적화된 그리드 시스템을 제공합니다.
- **스크롤 제로(Zero-Scroll) 정책**: 화면 높이에 맞춰 위젯 칸의 높이를 자동 계산하여, 어떤 기기에서도 대시보드 전체가 한눈에 들어오는 고정형 뷰를 유지합니다.
- **Fitted UI**: 위젯 크기에 따라 아이콘과 텍스트의 배치와 크기가 유동적으로 변하며, 1x1의 아주 작은 크기에서도 요소가 겹치지 않도록 자동 스케일링(`FittedBox`)됩니다.

### 3. 직관적인 조작 및 피드백 (Tactile UX)
- **이원화된 기록 방식**:
    *   **Tap**: 현재 시각으로 즉시 기록되는 '1초 퀵 로그'.
    *   **Long Press**: 날짜/시각/상세 메모를 입력할 수 있는 '과거 기록 추가'.
- **고해상도 햅틱 반응**: 기록 성공 시 손끝으로 전달되는 물리적 진동을 통해 화면을 보지 않고도 확실한 조작 확인이 가능합니다.
- **테마 일체형 알림**: 기록 완료 시 나타나는 알림 바가 해당 데이터의 고유 컬러와 테마 배경색을 실시간으로 반영하여 디자인 일관성을 높였습니다.

### 4. 데이터 정밀도 및 안정성 (Precision & Safety)
- **로컬 타임존 매칭**: 서버 없이도 현지 시각 기준 00:00~24:00 데이터를 완벽하게 그룹화하여 통계 화면에서 누락 없는 타임라인을 보장합니다.
- **데이터 보존 마이그레이션**: 스키마 버전 11로의 업데이트 과정에서도 기존 데이터를 안전하게 보존하며, 누락된 프리셋 항목을 자동으로 복구합니다.

## 📂 프로젝트 구조
- `lib/database/`: Drift v11 스키마, 무결성 검사 및 반응형 배치 로직.
- `lib/ui/screens/`: 
    - `main_screen.dart`: 드래그/리사이즈 엔진이 탑재된 반응형 기록 대시보드.
    - `statistics_screen.dart`: 고해상도 타임라인 차트 및 정밀 데이터 관리.
- `lib/ui/widgets/`: `custom_picker_utils.dart` 등 재사용 가능한 UI 컴포넌트.
- `lib/core/utils/`: 수면 효율 분석 및 Epoch 시간 계산 유틸리티.

## ⚙️ 실행 방법
```bash
# 의존성 설치
flutter pub get

# 코드 생성 (Drift DB 및 Serializer)
dart run build_runner build --delete-conflicting-outputs

# 앱 실행
flutter run
```
