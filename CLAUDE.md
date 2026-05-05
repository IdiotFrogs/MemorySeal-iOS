# MemorySeal iOS - CLAUDE.md

## 프로젝트 개요

타임캡슐 저널링 iOS 앱. Tuist 기반 멀티 모듈 아키텍처로 구성된 Swift 프로젝트.

## 빌드 시스템

- **Tuist** 로 프로젝트 생성 (`tuist generate` 실행 후 작업)
- 메인 타겟: `MemorySeal` (Bundle ID: `io.tuist.MemorySeal`)
- 배포 대상: iOS 16+

## 아키텍처: Clean Architecture + MVVM-C + Feature Modules

### 레이어 구조

```
Feature/{Name}       → Coordinator + DIContainer (네비게이션 + 의존성 조립)
Presentation/{Name}  → ViewController + ViewModel (UI + 상태 관리)
Domain/{Name}        → UseCase + Entity + Repository Protocol (비즈니스 로직)
Data/{Name}          → Repository 구현체 + TargetType + DTO (네트워크/저장소)
Shared/DesignSystem  → 공통 UI 컴포넌트
ThirdPartyLib        → 외부 라이브러리 래핑
```

### 피처 모듈 목록

App, Splash, Login, SignUp, Auth, Home, Profile, Memory, CreateTicket, MessageList

## 핵심 패턴

### 1. Coordinator 패턴 (네비게이션)

- `SceneDelegate` → `AppCoordinator` → 각 Feature Coordinator
- 각 Feature Coordinator는 내부 화면 전환 담당
- 부모 Coordinator로 이벤트 전달 시 delegate 사용

```swift
// ProfileCoordinator 예시
public func moveToEditProfile(nickname: String, profileImageUrl: String) {
    let vm = profileDIContainer.makeEditProfileViewModel(nickname: nickname, profileImageUrl: profileImageUrl)
    vm.delegate = self
    let vc = profileDIContainer.makeEditProfileViewController(with: vm)
    navigationController.pushViewController(vc, animated: true)
}
```

### 2. ViewModel Input/Output 패턴

```swift
struct Input {
    let backButtonDidTap: ControlEvent<Void>
    let saveButtonDidTap: ControlEvent<Void>
    // ...
}
struct Output {
    let userInfo: Driver<UserInfoEntity?>
}

func translation(_ input: Input) -> Output { ... }
```

- 상태 관리: `BehaviorRelay`
- 비동기: `Task { try await ... }` + `await MainActor.run { ... }`
- RxSwift + async/await 혼용

### 3. DIContainer 패턴

각 Feature 모듈의 DIContainer가 의존성을 조립:

```
Provider<TargetType> → Repository → UseCase → ViewModel → ViewController
```

외부 DI 프레임워크 없이 수동 DI 사용.

### 4. Moya TargetType (API 엔드포인트)

- `BaseTargetType` 프로토콜 준수
- `isNeededAccessToken: Bool` 로 인증 토큰 자동 주입 제어
- 이미지 업로드: `.uploadCompositeMultipart`
- 일반 요청: `.requestParameters(encoding: URLEncoding.queryString)` 또는 `.requestJSONEncodable`

## 주요 프레임워크

| 프레임워크 | 용도 |
|---|---|
| RxSwift / RxCocoa | 반응형 프로그래밍 |
| Moya | 네트워크 추상화 |
| SnapKit | AutoLayout DSL |
| Kingfisher | 이미지 로딩/캐싱 |
| Lottie | 애니메이션 |
| GoogleSignIn | OAuth 로그인 |

## 새 기능 추가 시 체크리스트

1. **Domain**: Entity, Repository Protocol, UseCase Protocol + Default 구현체 추가
2. **Data**: TargetType case 추가, Repository 구현체에 메서드 추가
3. **Presentation**: ViewModel (Input/Output), ViewController 작성
4. **Feature**: DIContainer에 factory 메서드 추가, Coordinator에 화면 전환 추가

## 브랜치 컨벤션

```
feature/{camelCase}   → 기능 개발  (예: feature/myInfoEditBinding)
fix/{camelCase}       → 버그 수정  (예: fix/loginCrash)
refactor/{camelCase}  → 리팩터링   (예: refactor/profileViewModel)
docs/{camelCase}      → 문서 작업  (예: docs/projectClaudeDocs)
```

- 베이스 브랜치: `master`
- 슬래시(`/`) 구분자 사용 (언더스코어 방식 `feature_xxx` 는 구버전, 사용 지양)

## 커밋 컨벤션

```
Feature: {기능 설명}
Fix: {버그 수정 설명}
Refactor: {리팩터링 설명}
Chore: {빌드, 설정, 의존성 등 기능과 무관한 작업}
```

한국어 설명 사용. 예: `Feature: PUT /users/me API 연동 후 프로필 수정 화면 UI 바인딩`

## 코드 규칙

- `// MARK: -` 로 섹션 구분 (Navigation, Profile Image, Nickname, Bottom Sheet 등)
- `private let disposeBag: DisposeBag = DisposeBag()` 뷰모델/뷰컨 모두 사용
- `withUnretained(self)` 로 메모리 누수 방지
- ViewController UI 초기화는 `setInitialValues()` → `addSubviews()` → `setLayout()` → `bindViewModel()` 순서
- ViewModel delegate는 `weak var delegate` 로 선언
- **주석 작성 금지**: `// MARK: -` 섹션 구분 외에는 어떠한 주석도 추가하지 않는다 (설명 / 의도 / TODO / 워크어라운드 메모 모두 포함). 새 코드 작성 시는 물론 기존 코드 수정 시에도 주석을 새로 만들지 말 것. 변경 의도는 커밋 메시지 / PR 본문으로만 기록한다.
