# OpenSAM Docker 배포 저장소

이 저장소는 OpenSAM(삼국지 모의전투)을 Docker로 간편하게 배포하기 위한 전용 저장소입니다.

## 🚀 한 줄로 설치

```bash
git clone https://github.com/peppone-choi/opensam-docker.git opensam
cd opensam
./install.sh
```

**완료!** 모든 것이 자동으로 설치되고 실행됩니다.

---

## 📦 구성 요소

| 서비스 | 설명 | 포트 |
|--------|------|------|
| MongoDB | 게임 데이터베이스 | 27017 |
| Redis | 캐시/세션/큐 | 6379 |
| Backend API | 게임 API 서버 | 8080 |
| Backend Daemon | 턴 처리/DB 동기화 | - |
| Frontend | Next.js 웹 클라이언트 | 3000 |

---

## 📁 이 저장소에 포함된 것

```
opensam-docker/
├── docker-compose.yml      # 프로덕션 구성
├── docker-compose.dev.yml  # 개발 구성
├── env.example            # 환경 변수 템플릿
├── install.sh             # 자동 설치 스크립트
├── setup.sh               # 환경 설정 스크립트
├── update.sh              # 업데이트 스크립트
├── manage-session.sh      # 세션 관리 (대화형)
├── create-admin.sh        # 관리자 계정 생성
├── init-sessions.sh       # 게임 세션 초기화
├── README.md              # 이 문서
├── PUBLISH.md             # GitHub 배포 가이드
└── LICENSE                # MIT 라이선스
```

---

## 🎯 실행 방법

### 초기 설치

```bash
git clone https://github.com/peppone-choi/opensam-docker.git opensam
cd opensam
./install.sh
```

### 환경 설정만 (대화형)

```bash
./setup.sh
```

### 업데이트

```bash
./update.sh
```

### 세션 관리 (대화형 메뉴)

```bash
./manage-session.sh
```

---

## 🔧 수동 실행

### 1. 환경 설정

```bash
cp env.example .env
# .env 파일을 편집하여 비밀번호 등 설정
```

### 2. Docker 실행

```bash
# 프로덕션
docker compose up -d

# 개발 모드
docker compose -f docker-compose.dev.yml up
```

### 3. 관리자 생성

```bash
./create-admin.sh
```

### 4. 게임 세션 초기화

```bash
./init-sessions.sh
```

---

## 🛠️ 유용한 명령어

```bash
# 서비스 상태 확인
docker compose ps

# 로그 확인
docker compose logs -f

# 특정 서비스 로그
docker compose logs -f backend
docker compose logs -f daemon
docker compose logs -f frontend

# 서비스 재시작
docker compose restart

# 서비스 중지
docker compose down

# 볼륨 포함 완전 삭제
docker compose down -v

# 이미지 재빌드
docker compose build --no-cache
docker compose up -d
```

---

## 🗃️ 데이터베이스 관리

### MongoDB 접속

```bash
docker exec -it opensam-mongodb mongosh -u admin -p <비밀번호> --authenticationDatabase admin sangokushi
```

### Redis 접속

```bash
docker exec -it opensam-redis redis-cli -a <비밀번호>
```

### 데이터 백업

```bash
# MongoDB 백업
docker exec opensam-mongodb mongodump -u admin -p <비밀번호> --authenticationDatabase admin --db sangokushi --archive --gzip > backup.gz

# 복원
cat backup.gz | docker exec -i opensam-mongodb mongorestore -u admin -p <비밀번호> --authenticationDatabase admin --archive --gzip --drop
```

---

## 🌐 접속 정보

| 서비스 | URL |
|--------|-----|
| 프론트엔드 | http://localhost:3000 |
| 백엔드 API | http://localhost:8080 |
| API 문서 | http://localhost:8080/api-docs |
| Health Check | http://localhost:8080/health |

---

## ⚙️ 환경 변수 설명

`.env` 파일의 주요 설정:

| 변수 | 설명 | 기본값 |
|------|------|--------|
| `MONGO_USER` | MongoDB 사용자명 | admin |
| `MONGO_PASSWORD` | MongoDB 비밀번호 | (자동 생성) |
| `REDIS_PASSWORD` | Redis 비밀번호 | (자동 생성) |
| `JWT_SECRET` | JWT 서명 키 | (자동 생성) |
| `SESSION_ID` | 게임 세션 ID | default |
| `SERVER_NAME` | 서버 이름 | OpenSAM |
| `FRONTEND_PORT` | 프론트엔드 포트 | 3000 |
| `BACKEND_PORT` | 백엔드 포트 | 8080 |

---

## 🔒 보안 권장사항

1. **비밀번호 변경**: `.env`의 모든 비밀번호를 강력한 값으로 변경
2. **방화벽 설정**: MongoDB(27017), Redis(6379) 포트는 외부에 노출하지 않기
3. **HTTPS 설정**: 프로덕션에서는 Nginx/Traefik으로 SSL 적용
4. **정기 백업**: 데이터베이스 정기 백업 설정

---

## 📡 원격 저장소 정보

- **Docker 설정**: https://github.com/peppone-choi/opensam-docker
- **Backend**: https://github.com/peppone-choi/open-sam-backend
- **Frontend**: https://github.com/peppone-choi/open-sam-front

---

## 🐛 문제 해결

### 서비스가 시작되지 않을 때

```bash
# 로그 확인
docker compose logs

# 컨테이너 상태 확인
docker compose ps

# 네트워크 확인
docker network ls
```

### 포트 충돌

`.env` 파일에서 포트 변경:
```env
FRONTEND_PORT=3001
BACKEND_PORT=8081
```

### 메모리 부족

Redis 메모리 제한 조정:
```env
REDIS_MAXMEMORY=1gb
```

---

## 📝 라이선스

MIT License - 자유롭게 사용, 수정, 배포 가능

---

## 🤝 기여

버그 리포트, 기능 제안, PR 환영합니다!

- Issues: https://github.com/peppone-choi/opensam-docker/issues
- Pull Requests: https://github.com/peppone-choi/opensam-docker/pulls

