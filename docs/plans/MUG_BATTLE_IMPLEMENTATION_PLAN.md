# MUG 스타일 전투 시스템 및 미구현 기능 구현 계획

**최종 업데이트**: 2024-12-23
**상태**: 계획 수립 완료

---

## 개요

이 문서는 레거시 PHP(core/) 버전에 있지만 open-sam-backend/open-sam-front에 없거나 부족한 기능들을 구현하기 위한 상세 계획입니다.

### 핵심 목표
1. MUG(Multi-User Game) 스타일 실시간 성 전투 시스템 구현
2. 레거시 기능 완전 이식
3. 프론트엔드 전투 UI 구현

### 참고 이미지 분석 (i14066525220.jpg)
- **성 중심 맵**: 성벽과 내부 구조가 보이는 실시간 전투 맵
- **병종 시스템**: 창(1), 검(2), 강노(3), 연노(4), 발석거(1) 등 다양한 병종
- **전투 명령**: 공격(M), 매복(W), 낙석(J), 기습(D), 화공(J), 설복(기)
- **장수 정보**: 군대수, 사기, 훈련도, 무기 등
- **실시간 채팅**: 전투 중 메시지 시스템
- **비상도주**: 긴급 퇴각 기능

---

## Phase 1: 전투 엔진 핵심 개편 (MUG Battle Engine)
**예상 리스크**: 🟠 High
**상태**: ⏳ Pending

### 목표
기존 MUDBattleEngine을 MUG 스타일의 실시간 성 전투로 확장

### 작업 목록

#### 1.1 전투 타입 정의
- [ ] 야전(Field Battle) vs 공성전(Siege Battle) 분리
- [ ] 성벽 전투, 성문 전투, 내성 전투 구분
- [ ] 전투 페이즈(Phase) 시스템 구현

#### 1.2 병종별 전투 특성 구현 (core/hwe/sammo/ActionSpecialWar/ 참고)
- [ ] 보병(창병, 검병) 특성 - `che_보병.php` 참고
- [ ] 궁병(강노, 연노) 특성 - `che_궁병.php` 참고
- [ ] 기병 특성 - `che_기병.php` 참고
- [ ] 공성 병기 특성 - `che_공성.php` 참고
- [ ] 귀병(특수부대) 특성 - `che_귀병.php` 참고

#### 1.3 전투 스킬 시스템
- [ ] 돌격(che_돌격.php) - 기병 돌파 공격
- [ ] 저격(che_저격.php) - 원거리 정밀 사격
- [ ] 매복(che_매복) - 매복 기습 공격
- [ ] 반계(che_반계.php) - 상대 계략 무효화
- [ ] 화계 - 화공 공격
- [ ] 낙석 - 공성전 방어 특화
- [ ] 집중(che_집중.php) - 집중 공격
- [ ] 필살(che_필살.php) - 필살기 발동

#### 1.4 전투 보정 시스템
- [ ] 지형 보정 (성벽, 평지, 산악, 수상)
- [ ] 날씨 보정 (맑음, 비, 눈, 안개)
- [ ] 사기(士氣) 영향 계산
- [ ] 훈련도 영향 계산
- [ ] 병량 보급선 영향

### 품질 검증
```bash
npm run test -- --grep "MUGBattle"
npm run lint
npm run build
```

---

## Phase 2: 전쟁 특수 스킬 시스템 (ActionSpecialWar)
**예상 리스크**: 🟡 Medium
**상태**: ⏳ Pending

### 목표
PHP의 ActionSpecialWar 디렉토리 기능 완전 이식

### 작업 목록

#### 2.1 공격 특기
- [ ] 격노(che_격노.php) - 분노 공격력 증가
- [ ] 무쌍(che_무쌍.php) - 연속 공격
- [ ] 위압(che_위압.php) - 상대 사기 저하
- [ ] 돌격(che_돌격.php) - 기병 돌파

#### 2.2 방어 특기
- [ ] 견고(che_견고.php) - 방어력 증가
- [ ] 신중(che_신중.php) - 신중한 방어
- [ ] 척사(che_척사.php) - 계략 방어

#### 2.3 특수 특기
- [ ] 의술(che_의술.php) - 부상 회복
- [ ] 환술(che_환술.php) - 혼란 유발
- [ ] 신산(che_신산.php) - 전략적 계산

#### 2.4 병종 특기
- [ ] 징병(che_징병.php) - 병력 보충 효율
- [ ] 공성(che_공성.php) - 공성전 보너스

### 품질 검증
```bash
npm run test -- --grep "WarSkill"
npm run lint
```

---

## Phase 3: 실시간 전투 맵 시스템
**예상 리스크**: 🟠 High
**상태**: ⏳ Pending

### 목표
MUG 스타일의 실시간 성 전투 맵 구현

### 작업 목록

#### 3.1 백엔드 - 전투 맵 서버
- [ ] 실시간 전투 세션 관리 (Socket.IO 확장)
- [ ] 전투 맵 상태 브로드캐스트
- [ ] 유닛 위치/이동 동기화
- [ ] 전투 명령 큐 처리

#### 3.2 백엔드 - 전투 명령 처리
- [ ] 이동 명령 (Move)
- [ ] 공격 명령 (Attack) - 직접 공격
- [ ] 매복 명령 (Ambush) - 숨어서 기습
- [ ] 화공 명령 (Fire Attack) - 화계
- [ ] 낙석 명령 (Rock Drop) - 공성 방어
- [ ] 비상도주 (Emergency Retreat)

#### 3.3 프론트엔드 - 전투 맵 UI
- [ ] 성 맵 렌더링 컴포넌트
- [ ] 유닛 표시 및 애니메이션
- [ ] 전투 명령 패널 UI
- [ ] 장수 정보 패널 UI
- [ ] 실시간 전투 로그 표시

### 품질 검증
```bash
npm run test:e2e -- --grep "BattleMap"
npm run build
```

---

## Phase 4: 외교 시스템 완전 구현
**예상 리스크**: 🟡 Medium
**상태**: ⏳ Pending

### 목표
PHP t_diplomacy.php 및 관련 기능 완전 이식

### 작업 목록

#### 4.1 외교 문서 시스템
- [ ] 선전포고 (Declaration of War)
- [ ] 불가침 조약 제의/수락/파기
- [ ] 동맹 제의/수락/해제
- [ ] 종전 협정 제의/수락

#### 4.2 외교 상태 관리
- [ ] 국가간 외교 상태 테이블
- [ ] 외교 쿨다운 시스템
- [ ] 외교 이벤트 로그

#### 4.3 프론트엔드 외교 UI
- [ ] 외교 현황 대시보드
- [ ] 외교 문서함 UI
- [ ] 외교 제안/응답 모달

### 품질 검증
```bash
npm run test -- --grep "Diplomacy"
```

---

## Phase 5: 토너먼트 시스템
**예상 리스크**: 🟡 Medium
**상태**: ⏳ Pending

### 목표
PHP b_tournament.php, func_tournament.php 기능 이식

### 작업 목록

#### 5.1 토너먼트 로직
- [ ] 정기 토너먼트 스케줄러
- [ ] 대진표 자동 생성 알고리즘
- [ ] 1:1 일기토 시뮬레이션 로직
- [ ] 라운드별 진행 처리

#### 5.2 베팅 시스템
- [ ] 토너먼트 베팅 참여
- [ ] 베팅 배당률 계산
- [ ] 베팅 결과 정산

#### 5.3 프론트엔드 UI
- [ ] 토너먼트 대진표 뷰어
- [ ] 실시간 경기 결과 표시
- [ ] 베팅 참여 UI

---

## Phase 6: 역사/연표 시스템
**예상 리스크**: 🟢 Low
**상태**: ⏳ Pending

### 목표
PHP v_history.php, func_history.php 기능 이식

### 작업 목록

#### 6.1 백엔드 이벤트 기록
- [ ] 주요 사건 자동 기록 (전쟁, 건국, 멸망)
- [ ] 장수 업적 기록
- [ ] 국가 통계 스냅샷

#### 6.2 프론트엔드 연대기 UI
- [ ] 타임라인 뷰어
- [ ] 이벤트 필터링
- [ ] 상세 이벤트 모달

---

## Phase 7: 장수 커맨드 미구현 기능
**예상 리스크**: 🟡 Medium
**상태**: ⏳ Pending

### 목표
PHP Command/General/ 중 미구현 커맨드 이식

### 현재 상태 분석

| PHP 커맨드 | Backend 구현 | 비고 |
|-----------|-------------|------|
| che_출병.php | deploy.ts | 구현됨 |
| che_이동.php | move.ts | 구현됨 |
| che_모병.php | recruitSoldiers.ts | 구현됨 |
| che_훈련.php | train.ts | 구현됨 |
| che_물자조달.php | procureSupply.ts | 구현됨 |
| che_강행.php | forceMarch.ts | 구현됨 |
| che_전투태세.php | battleStance.ts | 구현됨 |
| che_소집해제.php | disband.ts | 구현됨 |
| che_집합.php | gather.ts | 구현됨 |
| che_숙련전환.php | convertDex.ts | 구현됨 |
| che_화계.php | fireAttack.ts | 구현됨 |
| che_파괴.php | destroy.ts | 구현됨 |

### 미구현/부분구현 커맨드
- [ ] che_거병.php - 거병 (의병 시작)
- [ ] che_랜덤임관.php - 무작위 임관 개선
- [ ] che_모반시도.php - 모반 시스템 심화
- [ ] che_탈취.php - 물자 탈취

---

## Phase 8: 국가 커맨드 미구현 기능
**예상 리스크**: 🟡 Medium
**상태**: ⏳ Pending

### 목표
PHP Command/Nation/ 중 미구현 커맨드 이식

### 미구현 커맨드
- [ ] che_발령.php - 부대 발령 시스템 심화
- [ ] che_부대탈퇴지시.php - 부대 관리
- [ ] che_의병모집.php - 의병 시스템
- [ ] che_이호경식.php - 이이제이 외교술
- [ ] che_피장파장.php - 응수 전략
- [ ] che_허보.php - 허위 정보 유포

### 병과 연구 이벤트
- [ ] event_극병연구.php - 극병 해금
- [ ] event_대검병연구.php - 대검병 해금
- [ ] event_무희연구.php - 무희 해금
- [ ] event_산저병연구.php - 산저병 해금
- [ ] event_상병연구.php - 상병 해금
- [ ] event_원융노병연구.php - 원융노병 해금
- [ ] event_음귀병연구.php - 음귀병 해금
- [ ] event_화륜차연구.php - 화륜차 해금
- [ ] event_화시병연구.php - 화시병 해금

---

## Phase 9: Static Event 시스템 확장
**예상 리스크**: 🟢 Low
**상태**: ⏳ Pending

### 목표
PHP StaticEvent/ 디렉토리 기능 확장

### 작업 목록
- [ ] event_부대발령즉시집합.php - 즉시 집합 이벤트
- [ ] event_부대탑승즉시이동.php - 즉시 이동 이벤트
- [ ] 추가 정적 이벤트 확장

---

## Phase 10: 프론트엔드 전투 UI 완성
**예상 리스크**: 🟠 High
**상태**: ⏳ Pending

### 목표
MUG 스타일 전투 화면 완전 구현

### 작업 목록

#### 10.1 전투 맵 컴포넌트
- [ ] 성 맵 그리드 시스템
- [ ] 유닛 스프라이트/아이콘 표시
- [ ] 전투 이펙트 애니메이션
- [ ] 미니맵 표시

#### 10.2 전투 UI 패널
- [ ] 장수 정보 패널 (HP, 사기, 훈련도)
- [ ] 병종 선택 패널
- [ ] 전투 명령 버튼 패널
- [ ] 비상도주 버튼

#### 10.3 실시간 기능
- [ ] 전투 로그 실시간 스크롤
- [ ] 전투 중 채팅
- [ ] 전투 상태 HUD

---

## 구현 우선순위 요약

| 우선순위 | Phase | 핵심 기능 | 리스크 |
|---------|-------|----------|--------|
| 1 | Phase 1 | MUG 전투 엔진 핵심 | 🟠 High |
| 2 | Phase 2 | 전쟁 특수 스킬 | 🟡 Medium |
| 3 | Phase 3 | 실시간 전투 맵 | 🟠 High |
| 4 | Phase 10 | 프론트엔드 전투 UI | 🟠 High |
| 5 | Phase 4 | 외교 시스템 | 🟡 Medium |
| 6 | Phase 5 | 토너먼트 | 🟡 Medium |
| 7 | Phase 7 | 장수 커맨드 | 🟡 Medium |
| 8 | Phase 8 | 국가 커맨드 | 🟡 Medium |
| 9 | Phase 6 | 역사/연표 | 🟢 Low |
| 10 | Phase 9 | Static Event | 🟢 Low |

---

## 기술 스택

### 백엔드
- Node.js + TypeScript
- Express.js
- Socket.IO (실시간 전투)
- MongoDB

### 프론트엔드
- Next.js 14
- React 18
- Tailwind CSS
- Socket.IO Client

### 테스트
- Jest
- Playwright (E2E)

---

## 참고 파일

### Core PHP 핵심 파일
- `core/hwe/process_war.php` - 전쟁 처리 메인
- `core/hwe/battle_simulator.php` - 전투 시뮬레이터
- `core/hwe/sammo/WarUnit.php` - 전투 유닛 기본
- `core/hwe/sammo/WarUnitGeneral.php` - 장수 전투 유닛
- `core/hwe/sammo/WarUnitCity.php` - 성 전투 유닛
- `core/hwe/sammo/ActionSpecialWar/*.php` - 전투 특기
- `core/hwe/sammo/Command/General/*.php` - 장수 커맨드
- `core/hwe/sammo/Command/Nation/*.php` - 국가 커맨드

### Backend 관련 파일
- `open-sam-backend/src/battle/MUDBattleEngine.ts` - 현재 전투 엔진
- `open-sam-backend/src/battle/ProcessWar.ts` - 전쟁 처리
- `open-sam-backend/src/battle/WarUnit*.ts` - 전투 유닛

### Frontend 관련 파일
- `open-sam-front/src/components/tactical-battle/` - 전술 전투 컴포넌트
- `open-sam-front/src/app/battle/` - 전투 페이지

---

## Notes

### Phase 1 Implementation Notes
_(Phase 완료 후 자동 기록)_

