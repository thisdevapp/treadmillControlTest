# 🌙 Sleep Prototype (로컬 전용 정밀 수면일지)

정신과 진료 시 의사에게 정확하고 정밀한 수면 데이터를 제공하기 위한 **Consensus Sleep Diary (CSD)** 기반의 고성능 수면 관리 앱입니다.

## 🚀 프로젝트 철학
- **Privacy First**: 모든 데이터는 기기 내부 SQLite(Drift)에만 저장되며, 외부 서버와 통신하지 않는 완전한 로컬 프라이버시를 보장합니다.
- **Doctor-Friendly**: 의사가 진료실에서 10초 이내에 환자의 수면 패턴, 효율, 약물 복용 시점을 한눈에 파악할 수 있도록 최적화된 리포트 뷰를 제공합니다.
- **Precision Data**: 단순 기록을 넘어 Unix Timestamp 기반으로 모든 수면 세션을 초 단위로 정밀하게 관리합니다.

## 🛠 기술 스택
- **Framework**: Flutter (Material 3)
- **Database**: Drift (SQLite) - **Schema v9 (Generic Custom Data)**
- **State Management**: RxDart (Stream 통합 및 실시간 동기화)
- **UI Engine**: Custom Painter (지능형 통합 지표 시스템 탑재)
- **Navigation**: PageView & IndexedStack

## ✨ 핵심 기능 및 업데이트 (v3.0 - Lifestyle Integration)

### 1. 범용 커스텀 데이터 아키텍처 (Lifestyle Logging)
- **무한 확장성**: 수면과 약 복용에 국한되지 않고 커피, 담배, 술, 운동 등 사용자가 원하는 모든 수면 영향 요소를 직접 정의하고 기록할 수 있습니다.
- **동적 유형 관리**: 설정 메뉴를 통해 각 기록 항목의 아이콘과 고유 색상을 커스텀할 수 있으며, 이는 앱 전체(기록/통계/범례)에 즉시 반영됩니다.
- **지능형 기록 제안**: 동일 항목에 대해 이전에 입력했던 텍스트(예: "졸피뎀 10mg")를 분석하여 칩 형태의 자동 완성 제안을 제공, 타이핑 피로도를 최소화합니다.

### 2. 고도화된 기록 일지 (Journal UI)
- **날짜 네비게이터**: 상단 캘린더 제어부를 통해 과거 특정 시점의 기록을 직관적으로 조회하고 추가할 수 있습니다.
- **1초 퀵 로그**: 자주 기록하는 항목은 그리드 버튼 탭 한 번으로 현재 시각에 즉시 기록되며, 실수 방지를 위한 '실행 취소(Undo)' 기능을 지원합니다.
- **통합 타임라인**: 해당 날짜에 발생한 모든 이벤트(수면, 카페인, 약물 등)를 시간 역순으로 일목요연하게 확인하고 관리할 수 있습니다.

### 3. 차세대 시각화 엔진 (Dynamic Statistics)
- **동적 범례(Legend) 시스템**: 사용자가 추가한 모든 커스텀 유형을 차트 하단 범례에 실시간으로 매핑하여 표시합니다.
- **다목적 렌더링**: '수면'은 정밀한 기둥(Bar)으로, 기타 일상 지표는 지정된 색상의 마커(Circle)로 플로팅합니다.
- **인터랙티브 제어**: 차트 위 요소를 **길게 누르면(Long Press)** 해당 기록의 상세 정보를 확인하고 즉시 삭제할 수 있는 정밀 편집 기능을 제공합니다.

### 4. 안전한 데이터 마이그레이션 (Safety First)
- **데이터 보존 정책**: 데이터베이스 스키마 변경 시 이전 테이블을 삭제하지 않고 `backup_v5_...` 형태로 이름을 변경하여 보존함으로써 개발 및 업데이트 중 데이터 유실을 원천 차단합니다.
- **자동 복구 엔진**: 구버전 데이터 발견 시 새로운 범용 데이터 구조(`CustomDataRecord`)로 자동 변환하여 이전 기록을 완벽하게 승계합니다.

## 📂 프로젝트 구조
- `lib/database/`: Drift v9 스키마, 제네릭 데이터 모델링 및 안전 마이그레이션 로직.
- `lib/ui/screens/`: 
    - `main_screen.dart`: 통합 기록 일지, 날짜 네비게이션 및 유형 관리 인터페이스.
    - `statistics_screen.dart`: 동적 지표 매핑 기반의 CustomPainter 그래프 엔진.
- `lib/ui/widgets/`: `custom_picker_utils.dart` 등 재사용 가능한 UI 컴포넌트.
- `lib/core/utils/`: 수면 분석 및 시간 계산 알고리즘.

## ⚙️ 실행 방법
```bash
# 의존성 설치
flutter pub get

# 코드 생성 (Drift DB 및 Serializer)
dart run build_runner build --delete-conflicting-outputs

# 앱 실행
flutter run
```
