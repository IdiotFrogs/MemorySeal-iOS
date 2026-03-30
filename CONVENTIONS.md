# MemorySeal-iOS 코드 컨벤션

실제 코드에서 추출한 패턴만 기술합니다. 각 규칙에는 출처 파일을 명시합니다.

---

## 1. 프로젝트 구조

```
Projects/
├── App/
├── Data/
│   └── BaseData/
├── Domain/
│   └── BaseDomain/
├── Feature/
│   └── {Feature}Feature/
│       ├── Coordinator/
│       └── DIContainer/
├── Presentation/
│   └── {Feature}Presentation/
│       ├── Controller/
│       └── ViewModel/
├── Shared/
│   └── DesignSystem/
└── ThridPartyLib/
```

레이어 의존 방향: `Feature` → `Presentation` → `Domain` ← `Data`

---

## 2. 네이밍 컨벤션

### 타입명 suffix 패턴

| 타입 | suffix | 예시 |
|------|--------|------|
| ViewController | `ViewController` | `EditProfileViewController` |
| ViewModel | `ViewModel` | `EditProfileViewModel` |
| Coordinator | `Coordinator` | `ProfileCoordinator` |
| DIContainer | `DIContainer` | `ProfileDIContainer` |
| Repository 프로토콜 | `Repository` | `UserRepository` |
| Repository 구현체 | `Default{Name}Repository` | `DefaultUserRepository` |
| UseCase 프로토콜 | `UseCase` | `UserUseCase` |
| UseCase 구현체 | `Default{Name}UseCase` | `DefaultUserUseCase` |
| TargetType | `TargetType` | `UserTargetType` |
| Network Provider | `DefaultProvider<T>` | `DefaultProvider<UserTargetType>` |
| Coordinator delegate | `{Name}CoordinatorDelegate` | `ProfileCoordinatorDelegate` |
| ViewModel delegate | `{Name}ViewModelDelegate` | `ProfileViewModelDelegate`, `EditProfileViewModelDelegate` |
| Entity | `{Name}Entity` | `UserInfoEntity` |
| Response DTO | `{Name}ResponseDTO` | `UserInfoResponseDTO` |
| Error 타입 | `{Name}Error` | `UserInfoError`, `EditProfileError` |
| CollectionViewCell | `{Name}CollectionViewCell` | `TicketCollectionViewCell`, `OpenedTicketCollectionViewCell` |
| UIView 컴포넌트 | 의미 있는 이름 + 타입 suffix | `DashedLineView`, `EditProfileButton`, `OAuthButton` |

### 변수명 패턴

```swift
// ViewController 내부 relay 이벤트: rx 접두사 사용
private let rxViewDidLoad: PublishRelay<Void> = .init()
// ProfileViewController.swift, HomeViewController.swift

// UI 컴포넌트: 역할 + 타입
private let navigationView: MemorySealNavigationView
private let nicknameTitleLabel: UILabel
private let nicknameTextField: UITextField
private let nicknameHelperLabel: UILabel
private let profileContainerView = UIView()
// EditProfileViewController.swift

// ViewModel delegate: weak var
public weak var delegate: ProfileViewModelDelegate?
// ProfileViewModel.swift, EditProfileViewModel.swift
```

### 메서드명 패턴

```swift
// DIContainer factory 메서드: make{TypeName}
func makeProfileViewModel() -> ProfileViewModel
func makeProfileViewController(with viewModel: ProfileViewModel) -> ProfileViewController
func makeUserRepository() -> UserRepository
// ProfileDIContainer.swift

// ViewController 초기화 순서 메서드
private func setInitialValues()  // 초기값 세팅 (데이터 주입)
private func addSubviews()       // 뷰 계층 구성
private func setLayout()         // SnapKit 제약조건
private func bindViewModel()     // RxSwift 바인딩
// EditProfileViewController.swift, ProfileViewController.swift

// 일부 파일에서는 addSubViews() (V 대문자) 혼용 있음
private func addSubViews()
// LoginViewController.swift — 일관성을 위해 addSubviews() 권장
```

---

## 3. import 순서

Apple 프레임워크 → 서드파티 → 내부 모듈 순서로 작성하며, 그룹 간 빈 줄 1개로 구분합니다.

```swift
import UIKit
import SnapKit
import RxSwift
import RxCocoa
import Kingfisher

import DesignSystem
// EditProfileViewController.swift, ProfileViewController.swift

// ---

import RxSwift
import RxCocoa

import BaseDomain
import Foundation
// EditProfileViewModel.swift

// ---

import Moya

import BaseDomain
import Foundation
// DefaultUserRepository.swift

// ---

import Foundation

import ProfilePresentation
import BaseData
import BaseDomain
// ProfileDIContainer.swift
```

**규칙 요약:**
- Apple/서드파티 그룹과 내부 모듈 그룹 사이에만 빈 줄 삽입
- `Foundation`은 서드파티 없을 경우 내부 모듈과 같은 블록에 위치하기도 함 (혼용 있음)

---

## 4. 파일 구조 및 `// MARK: -` 섹션

### ViewController 구성 패턴

```swift
public final class EditProfileViewController: UIViewController {
    // 1. 속성 선언 (disposeBag, viewModel, relay, UI 컴포넌트)
    // MARK: - {섹션명} (UI 그룹별로 구분)
    // 2. init(with:) + required init?(coder:)
    // 3. viewDidLoad()
    // 4. touchesBegan (필요시)
    // 5. private func setInitialValues()
}

// MARK: - Bind
extension EditProfileViewController { ... }

// MARK: - UIImagePickerControllerDelegate  (프로토콜 채택 시)
extension EditProfileViewController: ... { ... }

// MARK: - Layout
extension EditProfileViewController {
    private func addSubviews() { ... }
    private func setLayout() { ... }
}
// EditProfileViewController.swift
```

```swift
// ProfileViewController.swift — MARK 없이 확장으로 그룹화하는 경우도 있음
extension ProfileViewController { private func bindViewModel() }
// MARK: - Layout
extension ProfileViewController { addSubviews(), setLayout() }
// MARK: - UICollectionView
extension ProfileViewController: UICollectionViewDataSource, ... { ... }
```

확인된 `// MARK: -` 섹션 이름:

| 섹션 | 사용 위치 |
|------|-----------|
| `// MARK: - Navigation` | UI 그룹 구분 (EditProfileViewController) |
| `// MARK: - Profile Image` | UI 그룹 구분 |
| `// MARK: - Nickname` | UI 그룹 구분 |
| `// MARK: - Bottom Sheet` | UI 그룹 구분 |
| `// MARK: - Open Ticket Section` | UI 그룹 구분 (ProfileViewController) |
| `// MARK: - Bind` | bindViewModel extension |
| `// MARK: - Layout` | addSubviews + setLayout extension |
| `// MARK: - UICollectionView` | CollectionView delegate extension |
| `// MARK: - UIImagePickerControllerDelegate` | 이미지 피커 delegate extension |

---

## 5. ViewModel 패턴

### Input / Output struct

```swift
// ViewModel 내부에 중첩 struct로 선언 (접근 제어자 없음 = internal)
struct Input {
    let backButtonDidTap: ControlEvent<Void>
    let saveButtonDidTap: ControlEvent<Void>
    let nicknameText: ControlProperty<String?>
    let selectedProfileImage: BehaviorRelay<Data?>
}

struct Output {
    let userInfo: Driver<UserInfoEntity?>  // 데이터 반환이 필요할 때
}

struct Output {}  // 반환값 없을 때도 빈 struct 유지
// EditProfileViewModel.swift, ProfileViewModel.swift
```

### `translation(_:)` 메서드

```swift
// 반환값 있을 때
func translation(_ input: Input) -> Output {
    // ... 구독 설정 ...
    return Output(userInfo: userInfo.asDriver())
}

// 반환값 없을 때
func translation(_ input: Input) -> Output {
    // ... 구독 설정 ...
    return Output()
}
// ProfileViewModel.swift, EditProfileViewModel.swift
```

**주의:** `HomeViewModel`은 `transform(_:)` 사용 — 일관성을 위해 `translation(_:)` 권장

### BehaviorRelay vs PublishRelay 사용 기준

```swift
// BehaviorRelay: 초기값이 있거나 현재 상태를 유지해야 할 때
private let userInfo: BehaviorRelay<UserInfoEntity?> = .init(value: nil)
// ProfileViewModel.swift

// PublishRelay: 이벤트 트리거용 (viewDidLoad 신호 등)
private let rxViewDidLoad: PublishRelay<Void> = .init()
// ProfileViewController.swift, HomeViewController.swift

// ViewController에서 ViewModel로 전달하는 선택 상태
private let selectedProfileImage: BehaviorRelay<Data?> = .init(value: nil)
// EditProfileViewController.swift
```

### async/await 처리 패턴

```swift
// RxSwift subscribe 내부에서 Task {} 블록으로 async 호출
input.viewDidLoad
    .withUnretained(self)
    .subscribe(onNext: { (self, _) in
        Task {
            do {
                let user = try await self.userUseCase.fetchUserInfo()
                await MainActor.run {
                    self.userInfo.accept(user)
                }
            } catch {}
        }
    })
    .disposed(by: disposeBag)
// ProfileViewModel.swift

// ViewModel private 메서드로 분리하는 경우
private func editUserProfileInfo(nickname: String, profileImage: Data?) {
    Task {
        do {
            try await self.userUseCase.editProfile(
                nickname: nickname,
                profileImage: profileImage
            )
            await MainActor.run {
                self.delegate?.moveToBack()
            }
        } catch {}
    }
}
// EditProfileViewModel.swift
```

**규칙:** UI 업데이트는 반드시 `await MainActor.run { }` 내에서 수행

### ViewModel delegate 패턴

```swift
// ViewModel에서 delegate protocol 정의
public protocol EditProfileViewModelDelegate: AnyObject {
    func moveToBack()
}

// ViewModel에 weak var로 보유
public weak var delegate: EditProfileViewModelDelegate?
// EditProfileViewModel.swift

// Coordinator가 다중 delegate 채택
extension ProfileCoordinator: ProfileViewModelDelegate, EditProfileViewModelDelegate, SettingsViewModelDelegate {
    public func moveToBack() {
        self.navigationController.popViewController(animated: true)
    }
}
// ProfileCoordinator.swift
```

---

## 6. ViewController 패턴

### viewDidLoad 초기화 순서

**EditProfileViewController (초기값 세팅이 필요한 화면):**
```swift
public override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white

    setInitialValues()   // 1. 초기값 세팅
    addSubviews()        // 2. 뷰 계층 구성
    setLayout()          // 3. 레이아웃 제약
    bindViewModel()      // 4. 바인딩

    bottomSheetView.transform = CGAffineTransform(translationX: 0, y: bottomSheetHeight)
}
// EditProfileViewController.swift
```

**ProfileViewController (viewDidLoad 이벤트를 relay로 전달하는 화면):**
```swift
public override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white

    bindViewModel()          // 1. 바인딩 먼저 (relay accept 전에 구독 필요)
    rxViewDidLoad.accept(()) // 2. viewDidLoad 이벤트 발행

    addSubviews()            // 3. 뷰 계층 구성
    setLayout()              // 4. 레이아웃 제약
}
// ProfileViewController.swift
```

**HomeViewController (동일 패턴):**
```swift
public override func viewDidLoad() {
    super.viewDidLoad()
    self.addSubviews()
    self.setLayout()
    self.bindViewModel()
    self.rxViewDidLoad.accept(())
}
// HomeViewController.swift — self. 접두사 혼용 있음, 일관성을 위해 생략 권장
```

### ViewController 생성자

```swift
// 모든 ViewController 동일 패턴
public init(with viewModel: SomeViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
}

required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
}
// EditProfileViewController.swift, ProfileViewController.swift, HomeViewController.swift, LoginViewController.swift
```

### UI 컴포넌트 선언 스타일

```swift
// 클로저 초기화 (설정이 필요한 컴포넌트)
private let navigationView: MemorySealNavigationView = {
    let view = MemorySealNavigationView()
    view.setTitle("프로필")
    return view
}()

// 단순 초기화 (기본값으로 충분한 컴포넌트)
private let profileContainerView = UIView()
private let dashedSeparator = DashedLineView()

// lazy (self 참조가 필요한 경우)
private lazy var ticketCollectionView: IntrinsicCollectionView = {
    // ...
    collectionView.dataSource = self
    collectionView.delegate = self
    return collectionView
}()
// EditProfileViewController.swift, ProfileViewController.swift
```

### `touchesBegan` 키보드 해제

```swift
// 텍스트 입력이 있는 화면에서 공통 적용
public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    view.endEditing(true)
}
// EditProfileViewController.swift, ProfileViewController.swift
```

---

## 7. RxSwift 바인딩 패턴

### `withUnretained(self)` 사용

```swift
// subscribe(onNext:) 시 순환참조 방지 — withUnretained 표준 패턴
editImageButton.rx.tap
    .withUnretained(self)
    .subscribe(onNext: { (self, _) in
        self.showBottomSheet()
    })
    .disposed(by: disposeBag)
// EditProfileViewController.swift

// ViewModel translation 내부에서도 동일 패턴
input.backButtonDidTap
    .withUnretained(self)
    .subscribe(onNext: { (self, _) in
        self.delegate?.moveToBack()
    })
    .disposed(by: disposeBag)
// ProfileViewModel.swift
```

### `drive(with:onNext:)` - Output Driver 바인딩

```swift
// Output이 Driver일 때 drive(with:onNext:) 사용
output.userInfo
    .drive(with: self, onNext: { (self, user) in
        guard let user = user else { return }
        self.nickNameLabel.text = user.nickname
    })
    .disposed(by: disposeBag)
// ProfileViewController.swift
```

### `bind(to:)` - CollectionView 바인딩

```swift
output.memoryList
    .bind(to: collectionView.rx.items(
        cellIdentifier: TicketCollectionViewCell.reuseIdentifier,
        cellType: TicketCollectionViewCell.self
    )) { (index, entity, cell) in
        cell.configure(with: entity)
    }
    .disposed(by: disposeBag)
// HomeViewController.swift
```

### Output 반환값 무시 처리

```swift
// Output이 빈 struct인 경우 let _ = 로 명시적 무시
let _ = viewModel.translation(input)
// EditProfileViewController.swift, LoginViewController.swift

// Output에 데이터가 있는 경우 let output = 으로 받아 사용
let output = viewModel.translation(input)
// ProfileViewController.swift
```

### `disposeBag` 선언

```swift
// ViewController, ViewModel 모두 동일 위치 — 타입 첫 번째 속성으로 선언
private let disposeBag: DisposeBag = DisposeBag()
// EditProfileViewController.swift, ProfileViewController.swift, EditProfileViewModel.swift, ProfileViewModel.swift
```

---

## 8. SnapKit 레이아웃 패턴

### 기본 스타일

```swift
// $0 shorthand 사용, 명시적 타입 없음
navigationView.snp.makeConstraints {
    $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
    $0.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
    $0.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
    $0.height.equalTo(56)
}
// EditProfileViewController.swift

// inset: leading/trailing 동시 적용
$0.leading.trailing.equalToSuperview().inset(20)

// offset: 단방향
$0.top.equalTo(nicknameTitleLabel.snp.bottom).offset(8)

// 정사각형
$0.width.height.equalTo(120)

// edges: 전체 채우기
$0.edges.equalToSuperview()
// ProfileViewController.swift
```

### NavigationBar 대신 커스텀 NavigationView 고정 패턴

```swift
// 모든 화면 공통 — safeAreaLayoutGuide 기준, 높이 56pt
navigationView.snp.makeConstraints {
    $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
    $0.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
    $0.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
    $0.height.equalTo(56)
}
// EditProfileViewController.swift, ProfileViewController.swift
```

---

## 9. Coordinator 패턴

```swift
// Coordinator: navigationController + DIContainer 보유
public final class ProfileCoordinator {
    private let navigationController: UINavigationController
    private let profileDIContainer: ProfileDIContainer = .init()
    public var delegate: ProfileCoordinatorDelegate?
}

// start() 에서 첫 화면 push
public func start() {
    let profileViewModel = profileDIContainer.makeProfileViewModel()
    profileViewModel.delegate = self  // Coordinator가 delegate 담당
    let profileViewController = profileDIContainer.makeProfileViewController(with: profileViewModel)
    self.navigationController.pushViewController(profileViewController, animated: true)
}

// Coordinator가 여러 ViewModel delegate를 동시에 채택
extension ProfileCoordinator: ProfileViewModelDelegate, EditProfileViewModelDelegate, SettingsViewModelDelegate {
    public func moveToBack() {
        self.navigationController.popViewController(animated: true)
    }
    public func moveToEditProfile(nickname: String, profileImageUrl: String) {
        // DIContainer에서 ViewModel 생성 → delegate 설정 → ViewController 생성 → push
        let vm = profileDIContainer.makeEditProfileViewModel(...)
        vm.delegate = self
        let vc = profileDIContainer.makeEditProfileViewController(with: vm)
        self.navigationController.pushViewController(vc, animated: true)
    }
}
// ProfileCoordinator.swift
```

---

## 10. DIContainer 조립 순서

```swift
// 하위 의존성부터 역순으로 make 메서드 체인
// Provider → Storage → Repository → UseCase → ViewModel → ViewController

private func makeUserProvider() -> DefaultProvider<UserTargetType>
private func makeUserDefaultStorage() -> UserDefaultStorage
private func makeUserRepository() -> UserRepository      // provider + storage 주입
private func makeUserUseCase() -> UserUseCase             // repository 주입
public func makeProfileViewModel() -> ProfileViewModel   // useCase 주입
public func makeProfileViewController(with:) -> ProfileViewController  // viewModel 주입

// 접근 제어: 인프라 레이어 메서드는 private, ViewModel/ViewController 생성은 public
// ProfileDIContainer.swift
```

---

## 11. Network / Data 레이어 패턴

### TargetType (Moya)

```swift
// enum으로 엔드포인트 정의
public enum UserTargetType {
    case userInfo
    case uploadProfileImage(userId: Int, file: String)
    case editProfile(nickname: String, profileImage: Data?)
}

// BaseTargetType 프로토콜 채택 (extension으로 분리)
extension UserTargetType: BaseTargetType {
    public var path: String { ... }
    public var method: Moya.Method { ... }
    public var task: Moya.Task { ... }
    public var headers: [String: String]? { return nil }
    public var validationType: ValidationType { return .successCodes }
    public var isNeededAccessToken: Bool { return true }  // 커스텀 프로퍼티
}
// UserTargetType.swift
```

### Repository 구현체

```swift
// async/await 기반, provider.request() 후 ResultHandler.handleResult() 패턴
public func fetchUserInfo() async throws -> UserInfoEntity {
    let result = await provider.request(.userInfo)
    let responseDTO = try ResultHandler.handleResult(
        result: result,
        responseType: UserInfoResponseDTO.self,
        errorType: UserInfoError.self
    )
    return responseDTO.toDomain  // DTO → Entity 변환은 toDomain 프로퍼티
}
// DefaultUserRepository.swift
```

### UseCase

```swift
// protocol + Default 구현체 패턴
public protocol UserUseCase {
    func fetchUserInfo() async throws -> UserInfoEntity
    func editProfile(nickname: String, profileImage: Data?) async throws
}

public final class DefaultUserUseCase: UserUseCase {
    private let userRepository: UserRepository
    // Repository 메서드를 그대로 위임 (단순 포워딩)
    public func fetchUserInfo() async throws -> UserInfoEntity {
        return try await userRepository.fetchUserInfo()
    }
}
// UserUseCase.swift
```

---

## 12. DesignSystem 사용 패턴

```swift
// 색상
DesignSystemAsset.ColorAssests.grey5.color
DesignSystemAsset.ColorAssests.primaryNormal.color
DesignSystemAsset.ColorAssests.backgroundNormal.color

// 이미지
DesignSystemAsset.ImageAssets.userDefaultProfileImage.image
DesignSystemAsset.ImageAssets.editIcon.image.withRenderingMode(.alwaysTemplate)

// 폰트
DesignSystemFontFamily.Pretendard.bold.font(size: 16)
DesignSystemFontFamily.Pretendard.medium.font(size: 14)
DesignSystemFontFamily.Pretendard.regular.font(size: 12)
DesignSystemFontFamily.Hs산토끼체20.regular.font(size: 56)

// EditProfileViewController.swift, ProfileViewController.swift, LoginViewController.swift
```

### CollectionViewCell reuseIdentifier

```swift
// 타입 프로퍼티로 선언하여 등록과 dequeue 시 동일하게 사용
collectionView.register(
    TicketCollectionViewCell.self,
    forCellWithReuseIdentifier: TicketCollectionViewCell.reuseIdentifier
)
// HomeViewController.swift, ProfileViewController.swift
```

---

## 13. 클래스 선언 규칙

```swift
// 모든 주요 타입: public final class
public final class EditProfileViewController: UIViewController { }
public final class EditProfileViewModel { }
public final class ProfileCoordinator { }
public final class ProfileDIContainer { }
public final class DefaultUserRepository: UserRepository { }
public final class DefaultUserUseCase: UserUseCase { }
public final class DashedLineView: UIView { }
// 전체 파일 공통
```

---

## 14. 확인된 혼용 사례 (주의)

| 항목 | 혼용 내용 | 권장 |
|------|-----------|------|
| `translation` vs `transform` | ProfileViewModel: `translation`, HomeViewModel: `transform` | `translation` |
| `addSubviews` vs `addSubViews` | 대부분 소문자, LoginViewController만 대문자 V | `addSubviews` |
| `self.` 접두사 | HomeViewController에서 `self.addSubviews()` 형태 혼용 | 생략 |
| `// MARK:` 없이 extension | bindViewModel extension에 MARK 없는 경우 있음 | `// MARK: - Bind` 추가 |
