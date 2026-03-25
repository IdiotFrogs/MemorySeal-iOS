# users/me API 연동 후 ProfileViewController UI 바인딩 구현 계획서

## 1. 개요
- ProfileViewController에서 `GET /users/me` API를 호출하여 닉네임과 프로필 이미지를 UI에 바인딩한다.
- ProfileViewModel에 UserUseCase를 주입하고, Output으로 UserInfoEntity를 노출한다.

## 2. 구현 범위
### IN SCOPE
- `UserUseCase` 프로토콜 + `DefaultUserUseCase` 생성 (BaseDomain)
- `ProfileViewModel` 업데이트: UserUseCase 주입, viewDidLoad Input, userInfo Output
- `ProfileViewController` 업데이트: viewDidLoad 트리거, nickNameLabel/profileImageView 바인딩
- `ProfilePresentation/Project.swift`: BaseDomain 의존성 추가
- `ProfileFeature/Project.swift`: BaseData, BaseDomain 의존성 추가
- `ProfileDIContainer` 업데이트: UserProvider, UserRepository, UserUseCase 팩토리 메서드 추가

### OUT OF SCOPE
- EditProfileViewController 바인딩
- 프로필 이미지 업로드
- 오픈된 티켓(CollectionView) API 연동

## 3. 기능 요구사항
- 화면 진입 시(`viewDidLoad`) `GET /users/me`를 호출한다.
- 응답의 `nickname`을 `nickNameLabel`에 표시한다.
- 응답의 `profileImageUrl`을 `userProfileImageView`에 로드한다.
- API 실패 시 UI는 기본 상태(기본 이미지, 빈 닉네임)를 유지한다.

## 4. 수락 기준 (Acceptance Criteria)
- [ ] AC-1: 프로필 화면 진입 시 닉네임이 서버 데이터로 표시된다.
- [ ] AC-2: 프로필 화면 진입 시 프로필 이미지가 서버 URL에서 로드된다.
- [ ] AC-3: API 실패 시 앱이 크래시 없이 기본 상태를 유지한다.
- [ ] AC-4: 빌드가 성공한다.

## 5. 기술 구현 상세

### 5.1 수정 파일 목록 (전체 경로)
| 파일 | 작업 |
|------|------|
| `Projects/Domain/BaseDomain/Sources/UseCase/UserUseCase.swift` | **신규 생성** |
| `Projects/Presentation/ProfilePresentation/Sources/ViewModel/ProfileViewModel.swift` | 수정 |
| `Projects/Presentation/ProfilePresentation/Sources/Controller/ProfileViewController.swift` | 수정 |
| `Projects/Presentation/ProfilePresentation/Project.swift` | 수정 (BaseDomain 추가) |
| `Projects/Feature/ProfileFeature/Sources/DIContainer/ProfileDIContainer.swift` | 수정 |
| `Projects/Feature/ProfileFeature/Project.swift` | 수정 (BaseData, BaseDomain 추가) |

### 5.2 구현 단계

**Step 1: UserUseCase 생성 (BaseDomain)**
- `TimeCapsuleUseCase.swift` 패턴 그대로 복사
- protocol + DefaultUserUseCase를 같은 파일에 작성
- `fetchUserInfo() async throws -> UserInfoEntity` 메서드

**Step 2: ProfilePresentation/Project.swift 수정**
- `.Domain.BaseDomain` 의존성 추가

**Step 3: ProfileViewModel 수정**
- `import BaseDomain` 추가
- `init(userUseCase: UserUseCase)` 로 변경
- `Input`에 `viewDidLoad: PublishRelay<Void>` 추가
- `Output`에 `userInfo: PublishRelay<UserInfoEntity>` 추가
- `translation(_:)` 내부: viewDidLoad subscribe → Task { fetchUserInfo → MainActor.run { userInfo.accept } }

**Step 4: ProfileViewController 수정**
- `private let rxViewDidLoad: PublishRelay<Void> = .init()` 추가
- `viewDidLoad` 에서 `rxViewDidLoad.accept(())` 호출
- `bindViewModel`에서 Input에 `rxViewDidLoad` 전달
- output의 `userInfo`를 구독 → `nickNameLabel.text`, `userProfileImageView` 바인딩
- 이미지 로드: `URL(string:)`로 변환 후 `URLSession` or Kingfisher(프로젝트 내 사용 여부에 따라)

**Step 5: ProfileFeature/Project.swift 수정**
- `.Data.BaseData`, `.Domain.BaseDomain` 의존성 추가

**Step 6: ProfileDIContainer 수정**
- `import BaseData`, `import BaseDomain` 추가
- `makeUserProvider()`, `makeUserRepository()`, `makeUserUseCase()` 추가
- `makeProfileViewModel()` → `ProfileViewModel(userUseCase: makeUserUseCase())`

### 5.3 기존 패턴 참고
```swift
// HomeViewModel 패턴
input.rxViewDidLoad
    .withUnretained(self)
    .subscribe(onNext: { (self, _) in
        Task {
            do {
                let user = try await self.userUseCase.fetchUserInfo()
                await MainActor.run {
                    self.userInfo.accept(user)
                }
            } catch { }
        }
    })
    .disposed(by: disposeBag)
```

## 6. 의존성 및 제약사항
- `UserRepository`, `DefaultUserRepository`, `UserTargetType`, `UserInfoEntity` 모두 이미 구현되어 있음
- 이미지 로드 방식: ThirdPartyLib에 Kingfisher 포함 여부 확인 필요

## 7. 미확인 / 검토 필요 사항
- 프로필 이미지 URL 로딩 라이브러리: Kingfisher? 단순 URLSession?

## 8. 구현 우선순위
Step 1 → Step 2 → Step 3 → Step 4 → Step 5 → Step 6 (순서 중요, 빌드 의존성)
