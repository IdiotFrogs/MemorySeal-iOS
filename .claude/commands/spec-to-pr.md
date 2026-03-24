---
name: spec-to-pr
description: >
  자연어 요청(기획서 PDF, 텍스트, URL 등)을 받아 plan.md 작성부터 코드 구현, 코드 리뷰,
  커밋, PR 생성까지 전체 개발 파이프라인을 자동으로 수행합니다.
  "기획서", "구현해줘", "기능 추가", "spec-to-pr" 등을 언급할 때 사용합니다.
license: MIT
metadata:
  author: Fanmaum
  version: 1.0.0
  category: development-pipeline
  tags: [pipeline, automation, plan, implementation, pr, code-review]
---

# Spec to PR - 전체 개발 파이프라인

자연어 요청을 받아 plan.md 작성 → Deep Interview → 검증 → 구현 → 코드 리뷰 → Commit → PR 생성까지 전체 파이프라인을 자동으로 수행합니다.

## 사용법

```bash
# PDF 기획서 참고
/spec-to-pr 이 기획서 읽고 프로필 공유하기 기능 구현해줘 /path/to/기획서.pdf

# 텍스트 요청
/spec-to-pr 채팅방에서 이미지 전송 기능 추가해줘. 최대 5장, 10MB 제한

# URL 참고
/spec-to-pr 이 노션 문서 참고해서 결제 모듈 리팩토링해줘 https://notion.so/...

# 혼합
/spec-to-pr /path/to/spec.pdf 읽고 공유하기 부분만 구현해줘
```

## Instructions

### Phase 0: 입력 분석

사용자의 자연어 입력을 파싱하여 요구사항을 정제한다.

#### 0-1. 입력 소스 감지

입력 텍스트에서 아래 패턴을 감지하고 해당 소스를 읽는다:

| 패턴 | 동작 |
|------|------|
| `.pdf` 파일 경로 | Read 도구로 PDF 읽기 (20페이지씩 분할) |
| `.md`, `.txt` 등 파일 경로 | Read 도구로 파일 읽기 |
| `http://`, `https://` URL | WebFetch로 내용 가져오기 |
| 위 패턴 없음 | 입력 텍스트 자체를 요구사항으로 사용 |

#### 0-2. 작업 범위(scope) 추출

- 입력에서 구현할 기능/범위를 식별한다
- PDF 등 큰 문서일 경우 전체를 읽되, 작업 범위에 해당하는 부분을 집중 분석한다
- 범위가 불명확하면 Phase 3(Deep Interview)에서 확인한다

#### 0-3. 출력

정제된 요구사항 텍스트를 다음 Phase에 전달한다. 별도 파일로 저장하지 않는다.

---

### Phase 1: 코드베이스 탐색

기존 코드베이스를 탐색하여 구현에 필요한 컨텍스트를 수집한다.

#### 1-1. 탐색 실행

`explore` agent (haiku)를 실행하여 아래 항목을 조사한다:

- 관련 모듈/파일 구조
- 기존에 유사한 기능이 구현된 패턴 (재사용 가능한 코드)
- 수정 대상 파일 목록
- 기존 인프라 (네트워크, 네비게이션, DI 등)

#### 1-2. Feature Module Documentation 프로토콜

프로젝트의 CLAUDE.md에 Feature Module Documentation 프로토콜이 정의되어 있다면 반드시 따른다:
- 해당 feature 모듈의 문서 파일을 먼저 읽는다
- 문서의 아키텍처 패턴과 구현 방식을 코드 분석보다 우선시한다

#### 1-3. 출력

코드베이스 컨텍스트 (관련 파일, 패턴, 인프라 정보)를 다음 Phase에 전달한다.

---

### Phase 2: 초안 plan.md 생성

Phase 0의 요구사항 + Phase 1의 코드 컨텍스트를 기반으로 구현 계획서 초안을 작성한다.

#### 2-1. 디렉토리 생성

프로젝트에 `/start-new-work` skill이 있다면 해당 skill을 사용한다.
없다면 아래 경로에 직접 생성한다:

```
.claude/plan/{YY-MM-DD}-{브랜치이름}/plan.md
```

#### 2-2. plan.md 구조

```markdown
# {기능명} 구현 계획서

## 1. 개요
- 기능 설명
- 출처 (PDF 페이지, URL 등)

## 2. 구현 범위
### IN SCOPE
### OUT OF SCOPE

## 3. 기능 요구사항

## 4. 수락 기준 (Acceptance Criteria)
- [ ] AC-1: ...
- [ ] AC-2: ...

## 5. 기술 구현 상세
### 5.1 수정 파일 목록 (전체 경로)
### 5.2 구현 단계 (Step 1, 2, 3...)
### 5.3 기존 패턴 참고

## 6. 화면 흐름 (해당 시)

## 7. 의존성 및 제약사항

## 8. 미확인 / 검토 필요 사항

## 9. 구현 우선순위
```

#### 2-3. 핵심 원칙

- Phase 1에서 파악한 **실제 파일 경로**를 사용한다 (약식 경로 금지)
- 기존 코드 패턴을 참고하여 **구체적인 코드 예시**를 포함한다
- **미확인 사항**을 솔직하게 나열한다 (Phase 3에서 해소)

---

### Phase 3: Deep Interview (사람 개입 지점)

plan.md 초안의 불확실한 부분을 개발자에게 질문하여 해소한다.

#### 3-1. 질문 전략

- plan.md의 "미확인 / 검토 필요 사항"을 우선 타겟
- 한 번에 **1개 질문**만 한다
- `AskUserQuestion` 도구를 사용하여 선택지 제공
- 매 응답 후 ambiguity 점수 표시

#### 3-2. 점수 체계

| Dimension | Brownfield 가중치 | Greenfield 가중치 |
|-----------|------------------|------------------|
| Goal Clarity | 35% | 40% |
| Constraint Clarity | 25% | 30% |
| Success Criteria | 25% | 30% |
| Context Clarity | 15% | N/A |

`ambiguity = 1 - weighted_sum`

#### 3-3. 점수 표시 형식

```
Round {n} 완료

| Dimension | Score | Weight | Weighted | Gap |
|-----------|-------|--------|----------|-----|
| Goal | {s} | {w} | {s*w} | {gap or "Clear"} |
| ...
| **Ambiguity** | | | **{score}%** | |
```

#### 3-4. 종료 조건

- Ambiguity ≤ 20% (기본 임계값)
- 사용자가 "충분해", "진행해" 등 조기 종료 요청 (경고 후 진행)
- 최대 10 rounds

#### 3-5. 종료 후

- 인터뷰 결과를 반영하여 plan.md 업데이트
- "미확인 사항" 섹션에서 해소된 항목 제거/업데이트

---

### Phase 4: plan.md 검증 (Critic + Planner 병렬)

두 에이전트를 **병렬(동시에)**로 실행하여 plan.md를 검증한다.

#### 4-1. Critic Agent (Opus)

리뷰 관점:
- 기획적 누락 (요구사항에 있지만 plan에서 빠진 내용)
- 기술적 리스크 (구현 단계에서 놓친 이슈)
- 수락 기준이 기능을 충분히 커버하는지
- 의존성 분리가 적절한지

#### 4-2. Planner Agent (Opus)

리뷰 관점:
- 아키텍처 적합성 (기존 패턴과 일관성)
- 모듈 경계 (Clean Architecture 준수)
- 구현 단계의 구체성 및 순서 적절성
- 테스트 전략 포함 여부

#### 4-3. 이슈 반영

- CRITICAL/HIGH 이슈는 반드시 plan.md에 반영
- MEDIUM은 판단하여 반영
- LOW는 기록만 (구현 시 참고)
- 반영 후 plan.md에 "검증 이력" 섹션 추가

---

### Phase 5: 구현

검증 완료된 plan.md를 기반으로 코드를 구현한다.

#### 5-1. 사전 준비

- plan.md의 "수정 파일 목록"에 있는 모든 파일을 읽는다
- "확인 필요 파일"도 읽어서 의존성 확인

#### 5-2. 구현 실행

- plan.md의 Step 순서대로 구현
- 각 Step마다 Edit/Write 도구 사용
- 신규 파일은 기존 패턴(같은 디렉토리의 다른 파일)을 참고하여 생성

#### 5-3. 빌드 검증

- 수정된 모듈만 대상으로 빌드 실행
- 빌드 실패 시 에러 분석 → 수정 → 재빌드 (최대 3회)

#### 5-4. 핵심 원칙

- plan.md에 명시된 범위만 구현한다 (over-engineering 금지)
- 기존 코드 패턴을 따른다
- CLAUDE.md의 개발 가이드라인을 준수한다

---

### Phase 6: 코드 리뷰 + 수정

구현된 코드를 자동으로 리뷰하고 이슈를 수정한다.

#### 6-1. 코드 리뷰 실행

`code-reviewer` agent를 실행하여 변경된 파일들을 리뷰한다:
- 기존 코드 패턴과의 일관성
- 에러 핸들링 적절성
- 누락된 사항
- 프로젝트에 등록된 skill 기반 컨벤션 체크

#### 6-2. 이슈 대응

| 심각도 | 대응 |
|--------|------|
| CRITICAL | 반드시 수정 |
| HIGH | 수정 |
| MEDIUM | 판단하여 수정 또는 스킵 (사유 기록) |
| LOW | 수정 또는 스킵 |

#### 6-3. 재빌드

- 수정사항이 있으면 재빌드하여 검증
- BUILD SUCCESSFUL 확인 후 다음 Phase로

---

### Phase 7: Commit + PR

코드가 검증되면 커밋하고 Draft PR을 생성한다.

#### 7-1. Staging

- 구현에 관련된 파일만 선별적으로 `git add`
- `.env`, credentials 등 민감 파일 제외

#### 7-2. progress.md 업데이트

프로젝트에 `/commit` skill이 있다면 해당 skill을 사용한다.
없다면 직접 progress.md를 작성하고 커밋한다.

#### 7-3. Commit

컨벤셔널 커밋 메시지 생성:
```
{type}: {간결한 설명}

- {상세 변경 1}
- {상세 변경 2}
```

#### 7-4. Push + Draft PR

- `git push -u origin {branch}`
- 프로젝트에 `/write-pr` skill이 있다면 해당 skill을 사용한다
- 없다면 직접 `gh pr create --draft` 실행

#### 7-5. 완료 보고

최종 결과를 사용자에게 보고:
- PR URL
- 변경 파일 수 / 변경량
- 수락 기준 달성 상태
- 서버/외부 팀 확인 필요 사항 (있을 경우)

---

## Phase 간 상태 전달

각 Phase의 출력이 다음 Phase의 입력이 된다. 별도 상태 파일은 만들지 않고 대화 컨텍스트로 전달한다.

```
Phase 0 → 정제된 요구사항 텍스트
Phase 1 → 코드베이스 컨텍스트 (파일 목록, 패턴, 인프라)
Phase 2 → plan.md 파일 (디스크에 저장)
Phase 3 → 업데이트된 plan.md (인터뷰 결과 반영)
Phase 4 → 최종 plan.md (검증 결과 반영)
Phase 5 → 구현된 코드 (빌드 통과)
Phase 6 → 리뷰 통과한 코드 (재빌드 통과)
Phase 7 → PR URL + 완료 보고
```

## 실패 시 동작

| Phase | 실패 케이스 | 동작 |
|-------|-----------|------|
| 0 | PDF 읽기 실패 / URL 접근 불가 | 사용자에게 알리고 텍스트 입력 요청 |
| 1 | 관련 코드 없음 (Greenfield) | Context Clarity 가중치를 0으로 하고 계속 |
| 2 | plan.md 생성 실패 | 발생 불가 (텍스트 생성이므로) |
| 3 | 사용자 응답 없음 | 현재 상태로 plan.md 확정 (경고 표시) |
| 4 | Critic/Planner 에이전트 실패 | 해당 검증 스킵, 경고 표시 후 계속 |
| 5 | 빌드 3회 연속 실패 | 사용자에게 에러 보고, 수동 개입 요청 |
| 6 | 리뷰 이슈 수정 후에도 빌드 실패 | Phase 5로 돌아가서 재시도 (최대 1회) |
| 7 | PR 생성 실패 | gh auth 상태 확인 안내, 수동 PR 생성 가이드 |

## 제약사항

- 프로젝트의 CLAUDE.md 규칙을 최우선으로 준수한다
- 구현 범위를 plan.md에 명시된 범위로 한정한다
- 불필요한 리팩토링, 주석 추가, 타입 어노테이션 추가를 하지 않는다
- 빌드가 통과하지 않으면 절대 커밋하지 않는다