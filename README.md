# 🌙 Sleep Prototype (로컬 전용 정밀 수면일지)

정신과 진료 시 의사에게 정확하고 정밀한 수면 데이터를 제공하기 위한 **Consensus Sleep Diary (CSD)** 기반의 고성능 수면 관리 앱입니다.

## 🚀 프로젝트 철학
- **Privacy First**: 모든 데이터는 기기 내부 SQLite(Drift)에만 저장되며, 외부 서버와 통신하지 않는 완전한 로컬 프라이버시를 보장합니다.
- **Doctor-Friendly**: 의사가 진료실에서 10초 이내에 환자의 수면 패턴, 효율, 약물 복용 시점을 한눈에 파악할 수 있도록 최적화된 리포트 뷰를 제공합니다.
- **Precision Data**: 단순 기록을 넘어 Unix Timestamp 기반으로 모든 수면 세션을 초 단위로 정밀하게 관리합니다.

## 🛠 기술 스택
- **Framework**: Flutter (Material 3)
- **Database**: Drift (SQLite) - **Schema v11**
- **State Management**: RxDart (Stream 통합 및 실시간 동기화)
- **UI Engine**: Custom Painter (지능형 통합 지표 시스템 탑재)
- **UX**: Haptic Feedback Engine (물리적 기록 확인 시스템)

## 📐 개발 및 설계 원칙 (반드시 준수)

### 1. 데이터 입력의 완전 모듈화 (Modularized Data Input)
향후 UI/UX를 일괄적으로 전면 개편하기 쉽도록 모든 데이터 입력 로직은 반드시 모듈화되어야 합니다.
- **`RecordManager` 사용**: 대시보드(메인)나 통계 화면 등 어디서든 데이터를 입력/수정할 때는 반드시 `lib/ui/widgets/record_manager.dart`에 정의된 메서드를 호출해야 합니다.
- **UI 일관성**: 화면마다 별도의 입력 폼을 만들지 마세요. `RecordManager` 내부의 통합 다이얼로그를 사용하여 앱 전체에서 동일한 입력 경험을 보장해야 합니다.
- **로직 분리**: 데이터베이스 접근 로직과 복잡한 시간 계산(수면 시간 보정 등)은 UI 코드에 직접 작성하지 않고 모듈 내부에 은폐합니다.

### 2. 데이터베이스 관리 및 마이그레이션 (Safety First)
- **버전 관리**: DB 구조 변경 시 `database.dart`의 `schemaVersion`을 반드시 상향합니다.
- **선 백업 후 마이그레이션**: 마이그레이션 로직 실행 직전, 기존 DB 파일을 `db.sqlite.backup`으로 복사하는 백업 과정을 반드시 선행합니다.
- **방어적 코드**: 테이블/컬럼 추가 시 `try-catch`를 사용하여 이미 존재하는 경우에도 안전하게 넘어가도록 설계합니다.

## ✨ 최근 업데이트 기능

### 1. 지능형 메모 시스템 (Smart Memo System)
- **메모 자동 상속**: '지금 기록 추가' 시 가장 최근에 입력한 메모를 자동으로 불러옵니다.
- **기간별 일괄 적용**: 특정 기간을 설정하여 해당 범위 내의 모든 기록에 메모를 한꺼번에 적용/수정할 수 있습니다.

### 2. 통계 화면 조작성 및 시각화 강화
- **지능형 2단계 렌더링 (2-Stage Rendering)**: 모든 막대와 점의 위치를 먼저 파악한 후, 텍스트가 겹치지 않는 최적의 위치(위/아래 반전 등)를 찾아 배치하여 가독성을 극대화했습니다.
- **경계면 자동 회피**: 00:00 또는 24:00에 인접한 기록의 텍스트가 차트 영역 밖으로 잘리지 않도록 내부로 자동 클램핑(Clamping) 처리합니다.
- **통합 관리 메뉴**: 기록을 꾹 누르면 [수정/삭제]를 선택할 수 있는 세로형 큰 버튼 메뉴가 나타납니다.
- **터치 정밀도 보정**: 14일/30일 보기처럼 요소가 작을 때도 꾹 누르는 도중 미세한 드래그(20px 이내)를 허용하며, 터치 타겟 반경을 25px 이상 확보하여 조작 실패를 방지합니다.
- **수정 기능**: 기존 기록의 시간과 메모 내용을 `RecordManager` 통합 다이얼로그를 통해 간편하게 수정할 수 있습니다.

### 3. 기기 최적화 (Device Optimization)
- **Z Flip 대응**: 좁고 긴 특수 해상도에서 2x1 위젯의 텍스트가 찌그러지지 않도록 **유동적 중앙 정렬(Dynamic Center)** 방식을 적용했습니다.

## 📂 프로젝트 구조
- `lib/database/`: Drift 스키마 및 마이그레이션 로직.
- `lib/ui/screens/`: 대시보드 엔진 및 통계 뷰.
- `lib/ui/widgets/`: `record_manager.dart` (기록 통합 모듈), 공용 피커 등.

## ⚙️ 실행 방법
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```
