# 타임 캡슐 오픈 로직 구현 계획서

## 1. 개요
- Home/Profile에서 오픈된(`.opened`) 타임 캡슐을 탭했을 때, **로컬 오픈 기록** 유무로 분기하여 오픈 연출 화면(2개) 또는 추억 메세지 리스트로 랜딩한다.
- 리스트는 `GET /api/time-capsule-content/{capsuleId}/contents`(전체 참여자)로 채운다. 본인 전용 화면은 신규 `GET /my-contents`로 전환한다.
- 출처: `.omc/specs/deep-interview-timecapsule-open-flow.md` (deep-interview 6라운드, ambiguity ~17%).

## 2. 구현 범위
### IN SCOPE
- Home 필터 변경: `.opened` + 로컬 기록 없음 캡슐 노출.
- 오픈 여부 분기 라우팅(`.opened` 탭 → 기록 없음: 연출 플로우 / 기록 있음: 바로 리스트).
- 로컬 오픈 기록 저장소(capsuleId + userId).
- 신규 화면 2개: 오픈 안내(Screen A) → 추억 메세지 확인 버튼(Screen B).
- `MemoryMessages` 실데이터 연동(전체 참여자, mock 제거).
- `/my-contents` 신규 TargetType/DTO/Repository/UseCase + `MyTicketMessages` 전환.

### OUT OF SCOPE
- 서버측 오픈/언실 API, 사용자별 오픈 상태 서버 저장.
- 풀 Lottie 오픈 리빌 애니메이션.
- 리스트 무한 스크롤/페이지네이션 UI (MVP: 단일 요청/첫 페이지).
- 비오픈 티켓의 Home 탭 라우팅 변경(기존 `TicketDetail` 유지).
- 추억 메세지 작성/삭제 로직 변경.

## 3. 기능 요구사항
스펙의 Goal/Constraints를 그대로 따른다. 핵심 분기:
```
탭한 캡슐.status == .opened ?
  ├─ 로컬기록(capsuleId, userId) 있음 → MemoryMessages(리스트) 바로 push
  └─ 로컬기록 없음 → ScreenA(오픈안내) → 티켓탭 → ScreenB(확인버튼) → 버튼탭 → MemoryMessages
캡슐.status != .opened → 기존 TicketDetail (변경 없음)
리스트 로드 성공 시 로컬기록 저장
```

## 4. 수락 기준 (Acceptance Criteria)
스펙 AC-1 ~ AC-18을 그대로 사용한다. (`.omc/specs/deep-interview-timecapsule-open-flow.md#acceptance-criteria`)

## 5. 기술 구현 상세

### 5.1 수정/신규 파일 목록 (전체 경로)

**[A] 로컬 오픈 기록 저장 (Domain/Data)**
- 확인: `Projects/Data/BaseData/Sources/.../UserDefaultStorage.swift` (프로토콜/키 enum, `DefaultUserDefaultStorage`, `.userId` 키) — 실제 경로 구현 시 grep.
- 신규 or 확장: 오픈 캡슐 id 집합 저장/조회. 후보 A) `UserDefaultStorage`에 `openedCapsuleIds` 키 추가 + get/set; 후보 B) 신규 `OpenedCapsuleRecordStorage` 래퍼. → Planner 판단(기존 패턴 우선).
- 키 전략: `userId`별 `Set<Int>`. (예: `"opened_capsules_\(userId)"`)

**[B] `/my-contents` 엔드포인트 (Data/Domain)**
- 수정 `Projects/Data/TicketData/Sources/TargetType/CapsuleContentTargetType.swift`: `case fetchMyCapsuleContents(capsuleId: Int)` 추가 → path `"/api/time-capsule-content/\(capsuleId)/my-contents"`, `.get`, `.requestPlain`, accessToken 필요.
- 신규 DTO `Projects/Data/TicketData/Sources/ResponseDTO/MyCapsuleContentResponseDTO.swift`:
  ```swift
  struct MyCapsuleContentResponseDTO: Decodable {
      let contentId: Int
      let content: String?
      let attachedFiles: [AttachedFileDTO]?
  }
  struct AttachedFileDTO: Decodable {
      let id: Int
      let fileUrl: String
      let fileType: String   // "IMAGE"
  }
  // toDomain: content 비어있지 않으면 .text, 아니면 .photo(imageUrls: attachedFiles.map(\.fileUrl))
  ```
- 수정 `Projects/Domain/TicketDomain/Sources/Repository/CapsuleContentRepository.swift`: `func fetchMyContents(capsuleId: Int) async throws -> [CapsuleContent]` 추가.
- 수정 `Projects/Data/TicketData/Sources/Repository/DefaultCapsuleContentRepository.swift`: `fetchMyContents` 구현(신규 DTO 디코딩 → `[CapsuleContent]`).

**[C] 전체 그룹 UseCase (Domain)**
- 수정 `Projects/Domain/TicketDomain/Sources/UseCase/CapsuleContentUseCase.swift`:
  - `func fetchAllGroups(capsuleId: Int) async throws -> [CapsuleContentGroupEntity]` 추가 (필터 없음, repository.fetchCapsuleContents 그대로 반환).
  - `func fetchMyContents(capsuleId: Int) async throws -> [CapsuleContent]` 추가 → repository.fetchMyContents 위임.
  - 기존 `execute(capsuleId:)`(fetch-all+필터)는 유지하되, MyTicketMessages를 `fetchMyContents`로 전환 후 미사용화 검토(제거는 Critic 판단).

**[D] MemoryMessages 실데이터 (Presentation)**
- 수정 `Projects/Presentation/TicketPresentation/Sources/MemoryMessages/Model/MemoryMessageModels.swift`:
  - `MemoryMessageContent.photo(count:)` → 실제 이미지 렌더 필요 시 `photo(imageUrls: [String])`로 확장(셀 `MemoryPhotoCardCell` 확인 후 결정). 최소 변경 시 `.photo(count: imageUrls.count)` 매핑.
  - `MemoryMessageMock` 제거(또는 `#if DEBUG`).
  - 프로필 이미지: `MemoryParticipant`가 `UIImage?` 대신 URL 문자열도 받도록 확장(Kingfisher 로딩). → `profileImageUrl: String?` 추가 검토.
- 수정 `Projects/Presentation/TicketPresentation/Sources/MemoryMessages/ViewModel/MemoryMessagesViewModel.swift`:
  - `init(action:, capsuleId: Int, capsuleContentUseCase: CapsuleContentUseCase, currentUserId: Int?, onOpened: (() -> Void)?)`.
  - `rxViewDidLoad` 시 `Task { fetchAllGroups(capsuleId:) }` → `[CapsuleContentGroupEntity]` → `[MemoryConversation]` 매핑(`isMine = group.userId == currentUserId`), `await MainActor.run`.
  - 로딩/빈/에러 상태 Output 추가(`isLoading: Driver<Bool>`, `errorMessage` 등 — 기존 화면 패턴 참고).
  - 성공 로드 시 `onOpened?()` 호출(로컬 기록 저장 트리거).
- 확인 `.../MemoryMessages/Controller/MemoryMessagesViewController.swift`, `.../View/MemoryProfileBarView.swift`, `.../View/Cell/MemoryPhotoCardCell.swift`(사진 렌더 방식).

**[E] 오픈 연출 화면 2개 (Presentation) — 신규**
- 신규 `Projects/Presentation/TicketPresentation/Sources/OpenCapsule/OpenIntro/{Controller,ViewModel}` (Screen A "티켓을 열어서 추억을 확인해보세요"). Action: `ticketDidTap`.
- 신규 `Projects/Presentation/TicketPresentation/Sources/OpenCapsule/OpenConfirm/{Controller,ViewModel}` (Screen B "추억 메세지 확인" 버튼). Action: `confirmDidTap`.
- Figma 상세: A=`465:25445`/`465:25425`, B=`465:25515`/`598:5534` (구현 시 get_design_context로 카피/레이아웃 확보). SnapKit + 기존 VC 초기화 순서(`setInitialValues`→`addSubviews`→`setLayout`→`bindViewModel`).

**[F] 코디네이터/DIContainer/분기 (Feature)**
- 수정 `Projects/Feature/TicketFeature/Sources/Coordinator/TicketCoordinator.swift`:
  - `startOpenFlow()`: 로컬 기록 조회 → 있음: `startMemoryMessages()` 직행 / 없음: `startOpenIntro()`.
  - `startOpenIntro()` → ScreenA push; ticketDidTap → `startOpenConfirm()`.
  - `startOpenConfirm()` → ScreenB push; confirmDidTap → `startMemoryMessages()`.
  - `startMemoryMessages()` 수정: `makeMemoryMessagesViewController(action:, capsuleId:)`로 실데이터 주입, 성공 로드 시 로컬 기록 저장(onOpened).
- 수정 `Projects/Feature/TicketFeature/Sources/DIContainer/TicketDIContainer.swift`:
  - `makeMemoryMessagesViewController(action:, capsuleId:)`로 시그니처 변경 — provider/repo/usecase/userId 주입.
  - ScreenA/B 팩토리 추가.
  - `makeMyTicketMessagesViewModel`을 `/my-contents` 경로로 전환(UseCase 메서드 교체).
- 수정 `Projects/Feature/MainFeature/Sources/Coordinator/MainCoordinator.swift`:
  - `moveToOpenCapsuleCoordinator(capsuleId:)` 추가 → `TicketCoordinator(capsuleId:).startOpenFlow()`.
  - Home/Profile Dependency에 `moveToOpenCapsule` 전달.
- 수정 `Projects/Feature/HomeFeature/Sources/Coordinator/HomeCoordinator.swift`: `Dependency`에 `moveToOpenCapsule` 추가, `HomeViewModel.Action`에 전달.
- 수정 `Projects/Presentation/HomePresentation/Sources/Home/ViewModel/HomeViewModel.swift`: `Action`에 `moveToOpenCapsule` 추가. 탭 처리 분기: `entity.timeCapsuleStatus == .opened ? moveToOpenCapsule(id) : moveToTicket(id)`.
- Profile: `Projects/Feature/ProfileFeature/.../ProfileCoordinator.swift` + Profile VM — 오픈 캡슐 탭을 `moveToOpenCapsule`로 라우팅(현재 `moveToTicket` 존재). 구현 시 Profile VM 탭 핸들러 확인.

**[G] Home 필터 변경 (Domain)**
- 수정 `Projects/Domain/HomeDomain/Sources/UseCase/HomeUseCase.swift`:
  - `fetchMyTimeCapsules(role:)`가 `.opened` + 로컬 기록 없음 캡슐도 포함하도록 변경.
  - 로컬 기록 조회 의존성 주입 필요(UseCase에 storage 주입 or Repository 경유). 필터: `(status != .opened) || (status == .opened && !openedLocally(id))` 그리고 `role == role`.
  - `HomeDIContainer`/`HomeRepository` 조립부 수정(로컬 기록 소스 주입).

### 5.2 구현 단계 (순서)
1. **[A]** 로컬 오픈 기록 저장소 (기반).
2. **[B]** `/my-contents` TargetType/DTO/Repository.
3. **[C]** UseCase 메서드(`fetchAllGroups`, `fetchMyContents`).
4. **[D]** MemoryMessages VM/Model 실데이터 연동.
5. **[E]** 오픈 연출 화면 A/B (신규 VC/VM).
6. **[F]** Coordinator/DIContainer/분기 배선 + MyTicketMessages 전환.
7. **[G]** Home 필터 변경 + Home/Profile 탭 분기.
8. 빌드(`tuist generate` 후 영향 모듈 빌드) → 리뷰 → 커밋 → PR.

### 5.3 기존 패턴 참고
- Provider→Repository→UseCase→ViewModel→ViewController 수동 DI (`TicketDIContainer` 참고).
- ViewModel Input/Output + `transform`, `BehaviorRelay`, `Task{}+MainActor.run` (`HomeViewModel`, `MyTicketMessagesViewModel` 참고).
- Coordinator 클로저 `Dependency`/`Action` (`HomeCoordinator`, `TicketCoordinator` 참고).
- `withUnretained(self)`, `weak`, `// MARK: -` 외 주석 금지.

## 6. 화면 흐름
```
[Home] .opened+무기록 티켓 탭 ─▶ moveToOpenCapsule ─▶ TicketCoordinator.startOpenFlow
                                                          │ 무기록
                                                          ▼
                                             [ScreenA 오픈안내] ─(티켓 탭)─▶ [ScreenB 확인버튼] ─(버튼 탭)─▶ [MemoryMessages 리스트/fetch/기록저장]
[Profile] .opened 티켓 탭 ─▶ moveToOpenCapsule ─▶ startOpenFlow ─(기록 있음)─▶ [MemoryMessages 리스트 직행]
```

## 7. 의존성 및 제약사항
- Tuist 프로젝트 → 파일 추가/시그니처 변경 후 `tuist generate` 필요.
- `TicketDomain`/`TicketData`/`TicketPresentation`/`TicketFeature`/`HomeDomain`/`HomePresentation`/`HomeFeature`/`ProfileFeature`/`MainFeature` 모듈 영향.
- `/my-contents` 응답 shape는 서버 확인 필요(가정: 스펙 명시 shape).
- 코드 규칙: 주석 금지, 한국어 커밋 컨벤션.

## 8. 미확인 / 검토 필요 사항 (구현 중 확정)
- `UserDefaultStorage` 실제 경로/프로토콜 형태 및 키 추가 방식.
- `MemoryPhotoCardCell`의 사진 렌더 방식(count vs imageUrls) → 모델 확장 여부.
- `MemoryProfileBarView`/`MemoryMessagesViewController`의 프로필 이미지 소스(현재 `UIImage?`) → URL 로딩 확장 여부.
- Profile VM의 오픈 캡슐 탭 핸들러 위치/시그니처.
- Home 필터에 로컬 기록 소스를 어떻게 주입할지(UseCase DI 변경 범위).

## 9. 구현 우선순위
P0: [A][B][C][D][F(리스트 배선)] — 오픈 플로우 리스트 랜딩(핵심 가치).
P1: [E][F(연출 배선)][G] — 연출 화면 + Home/Profile 노출·분기.
P2: MyTicketMessages `/my-contents` 전환 정리.

## 10. 검증 이력 및 확정 사항 (Planner + Critic 반영)
Planner: APPROVE-WITH-CHANGES / Critic: REVISE. 아래는 반드시 반영할 확정 지침(모호 항목 override).

### CRITICAL
- **C1 — Home 리프레시 경로 확보 (AC-6 필수).** Home은 `viewDidLoad`에서만 fetch, 오픈 플로우 복귀 시 리프레시 없음 → 오픈한 캡슐이 Home에서 사라지지 않음.
  - `MainCoordinator.moveToOpenCapsuleCoordinator(capsuleId:)`는 완료 콜백을 `TicketCoordinator`에 전달하고, 리스트 로드 성공(기록 저장) 시 `homeCoordinator?.refreshHome()` 호출. (`moveToCreateTicketCoordinator`의 `didCreateTicket` 패턴 참고, `MainCoordinator.swift:70-79`)
  - 신규 `TicketCoordinator` 인스턴스는 `MainCoordinator`가 프로퍼티로 **retain** (`ticketCoordinator = coordinator`, `MainCoordinator.swift:83`)해야 클로저가 중간 해제되지 않음.
- **C1b (H4) — `refreshHome()`가 host 탭만 갱신.** `HomeCoordinator.refreshHome()`는 `hostHomeViewModel?.refresh()`만 호출(`HomeCoordinator.swift:38-40`), contributor VM은 인라인 생성(`:58`)되어 retain/refresh 불가. → contributor `HomeViewModel`도 프로퍼티로 retain하고 두 탭 모두 refresh.

### 아키텍처 (CRITICAL, Planner)
- **[G] `UserDefaultStorage`를 HomeDomain에 주입 금지** (Domain→Data 역전). 대신:
  1. **BaseDomain** 포트 신규: `Projects/Domain/BaseDomain/Sources/Repository/OpenedCapsuleStore.swift`
     ```swift
     public protocol OpenedCapsuleStore {
         func isOpened(capsuleId: Int) -> Bool
         func markOpened(capsuleId: Int)
     }
     ```
  2. **BaseData** 구현 신규: `Projects/Data/BaseData/Sources/UserDefaults/DefaultOpenedCapsuleStore.swift` — `UserDefaults.standard` 직접 사용, 키 `"opened_capsules_\(userId)"`, `Set<Int>`를 `[Int]`로 영속. userId는 내부에서 `UserDefaultStorage`(`.userId`)로 해소(`DefaultCapsuleContentRepository.swift:31-33` 패턴). userId nil이면 안전 no-op.
  3. `DefaultHomeUseCase.init`에 `OpenedCapsuleStore`(BaseDomain 추상) 주입, 필터 `HomeUseCase.swift:20-22`: `((status != .opened) || (status == .opened && !store.isOpened(id))) && role == role`. `fetchOpenedTimeCapsules`(`:25-31`)는 store 미참조(Profile은 전부 노출).
  4. 조립: `HomeDIContainer.makeHomeViewModel`(`HomeDIContainer.swift:53-62`) + `ProfileDIContainer.makeHomeUseCase()`(`ProfileDIContainer.swift:46`) 둘 다 `DefaultOpenedCapsuleStore()` 주입. (HomeFeature/ProfileFeature 모두 BaseData 접근 가능 → 신규 Tuist 엣지 0)
- **[A] 로컬 저장은 `UserDefaultsKeys` enum 확장 아님.** enum API는 `.userId` 단일 케이스 정적 문자열이라 동적 per-user 키 표현 불가(`UserDefaultStorage.swift:11-19`). → 위 `DefaultOpenedCapsuleStore` 래퍼로 처리.

### MAJOR — 데이터 충실도 (커밋 필수, 옵션 아님)
- **M2 — 사진 렌더:** `MemoryMessageContent.photo(count:)` → **`.photo(imageUrls: [String])`**. `MemoryPhotoCardCell.configure`(`MemoryPhotoCardCell.swift:66-76`)가 현재 회색 플레이스홀더만 → Kingfisher로 URL 로딩(`MessagePhotoCardCell.swift:61-64` 템플릿). 도메인 `CapsuleContent.photo(imageUrls:)` 그대로 전달.
- **M3 — 프로필 이미지:** `MemoryParticipant`에 **`profileImageUrl: String?`** 추가(`MemoryMessageModels.swift:7-21`). `MemoryProfileItemView.configure`(`:73-77`)와 `MemoryTextBubbleCell`(`:100`)에서 Kingfisher 로딩, 기본값 `userDefaultProfileImage` 유지. 서버 `CapsuleContentGroupEntity.profileImageUrl`(`CapsuleContentGroupEntity.swift:6`) 매핑.
- **M4 — 연출 화면 백스택 정리:** B→리스트 전환 시 A/B를 스택에서 제거(리스트 push 전 `popToViewController(Home)` 또는 `setViewControllers([...홈, 리스트])`)하여 리스트에서 back 시 Home으로 복귀. (연출은 1회성)

### MEDIUM
- **m1/[B] — `/my-contents` 디코딩은 최상위 배열** `[MyCapsuleContentResponseDTO]` (envelope 아님, `DefaultHomeRepository.swift:20` 패턴). 중첩 DTO는 `MyContentAttachedFileDTO`로 접두어.
- **m2 — 페이지네이션:** `/contents`는 참여자 그룹이 페이징(`content,last,totalPages`). MVP 첫 페이지만 → **알려진 한계로 명시(주석 금지이므로 PR 본문/plan에 기록)**. 참여자 수가 페이지 크기 초과 시 일부 누락 가능.
- **m3 — AC-15 VC UI:** `MemoryMessagesViewController`에 로딩 인디케이터/빈 상태/에러+재시도 UI 추가(현재 테이블만, `:32-67`). VM Output만으로 불충분.
- **m4 — 기록 저장 엣지:** (a) **빈 contents 성공**도 기록 저장(오픈 완료로 간주) + 빈 상태 UI 표시. (b) `fetchCurrentUserId()`가 nil이면 저장/조회 모두 no-op(불일치 방지). 저장 시점 = 리스트 **fetch 성공** 시(`onOpened`).

### 배선 (MEDIUM)
- **[F] routing:** `moveToOpenCapsule` 클로저를 체인 관통 추가 — `HomeViewModel.Action`(`:19-25`, 탭 분기 `:71-78`: `status == .opened ? moveToOpenCapsule : moveToTicket`), `HomeCoordinator.Dependency`(`:14-24`, wired `:53`), `MainCoordinator`(`:38-42`, `:48-68`), `ProfileCoordinator.Dependency`(`ProfileCoordinator.swift:14-31`, `:44-50`), `ProfileViewModel.Action` → **`ProfileViewModel.swift:123` 변경**(`moveToTicket`→`moveToOpenCapsule`). Profile는 전부 `.opened`이므로 항상 open flow 진입, 분기는 `startOpenFlow()` 내부 기록 조회로 결정(Profile도 no-record면 연출 진입 — 의도됨, spec Round 4).
- **onOpened 배선:** `MemoryMessagesViewModel`이 성공 로드 시 `onOpened?()` 호출 → `TicketCoordinator`가 `store.markOpened(capsuleId)` + Home refresh 콜백 실행. `TicketPresentation`은 저장소 의존성 없음.

### LOW
- 기존 `CapsuleContentUseCase.execute`(필터, `:18-26`)는 유지(유일 caller MyTicketMessages가 `/my-contents`로 이전 후 미사용화) — 제거는 별도. Profile의 `moveToTicket` 클로저는 미사용화되나 삭제는 후속.
- 서버 계약(`/my-contents` 배열 shape, `/contents` 페이지 크기)은 미검증 가정 → PR 본문에 백엔드 확인 요청 명시.
