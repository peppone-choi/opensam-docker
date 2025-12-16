# 삼국지 모의전투 OpenSAM Docker 설치

삼국지 모의전투 OpenSAM을 Docker, Docker-compose를 이용한 환경에서 설치할 수 있도록 지원하는 공간입니다.

## 지원환경

Docker-compose를 지원하는 모든 환경 (Windows 10/11 Pro 포함)

Docker가 설치되지 않았다면 다음을 통해 설치합니다.

* **POSIX (Linux/macOS)** - https://docs.docker.com/install/ 을 통해 Docker를, https://docs.docker.com/compose/install/ 를 통해 Docker-compose를 설치합니다.
* **Windows 10/11** - https://docs.docker.com/docker-for-windows/install/ 를 통해 Docker Desktop on Windows 를 설치합니다.
* **macOS** - https://docs.docker.com/docker-for-mac/install/ 를 통해 Docker Desktop을 설치합니다.

> ⚠️ **주의**: Docker Desktop on Windows는 WSL2를 사용합니다. Virtual Box, VMWare와 충돌할 수 있으니 주의하세요.

`docker run hello-world` 와 `docker compose version` 명령이 동작하면 설치가 완료된 것입니다.

---

## 설치

docker, docker-compose를 사용 가능한 상황임을 가정합니다.

### 방법 1: Git Clone (권장)

```bash
git clone https://github.com/peppone-choi/opensam-docker.git opensam
cd opensam
```

### 방법 2: ZIP 다운로드

https://github.com/peppone-choi/opensam-docker/archive/refs/heads/main.zip 링크를 통해 zip 파일을 다운받아 압축을 풉니다.

---

## 기본 설정

기본적으로 수정이 필요한 항목은 다음과 같습니다.

### 1. 환경 변수 파일 생성

```bash
cp env.example .env
```

### 2. `.env` 파일 수정

`.env` 파일을 열어 다음 항목들을 수정합니다:

```env
# ==========================================
# 필수 변경 항목
# ==========================================

# MongoDB 비밀번호 (반드시 변경!)
MONGO_PASSWORD=your_secure_password_here

# Redis 비밀번호 (반드시 변경!)
REDIS_PASSWORD=your_redis_password_here

# JWT 시크릿 키 (반드시 변경!)
# 생성 명령: openssl rand -hex 64
JWT_SECRET=your_very_long_random_string_here
JWT_REFRESH_SECRET=another_very_long_random_string_here

# ==========================================
# 서버 설정
# ==========================================

# 서버 이름 (게임 내 표시)
SERVER_NAME=내 삼국지 서버

# 세션 ID (여러 서버 운영 시 구분용)
SESSION_ID=default

# ==========================================
# 접속 주소 설정
# ==========================================

# 프론트엔드 포트
FRONTEND_PORT=3000

# 백엔드 API 포트  
BACKEND_PORT=8080

# 프론트엔드 URL (외부 접속 주소)
# 예: http://your-domain.com:3000 또는 http://공인IP:3000
FRONTEND_URL=http://localhost:3000

# 백엔드 API URL (프론트엔드에서 호출하는 주소)
NEXT_PUBLIC_API_URL=http://localhost:8080
```

> 💡 **팁**: `./setup.sh` 스크립트를 실행하면 대화형으로 설정할 수 있습니다.

> ⚠️ **중요**: 외부에서 접속하려면 `FRONTEND_URL`과 `NEXT_PUBLIC_API_URL`을 공인 IP 또는 도메인 주소로 변경해야 합니다.

---

## 소스 코드 다운로드

Backend와 Frontend 소스 코드를 다운로드합니다:

```bash
# Backend 클론
git clone https://github.com/peppone-choi/open-sam-backend.git

# Frontend 클론
git clone https://github.com/peppone-choi/open-sam-front.git
```

> 💡 **팁**: `./install.sh` 스크립트를 사용하면 이 과정이 자동으로 진행됩니다.

---

## 고급 설정

고급 설정이 필요하다면 다음을 수정합니다.

### `docker-compose.yml`

* `mongodb/ports`: 27017 포트 대신 다른 포트를 선택하고자 할 경우 수정합니다. (보안상 외부 노출 비권장)
* `redis/ports`: 6379 포트 대신 다른 포트를 선택하고자 할 경우 수정합니다. (보안상 외부 노출 비권장)
* `backend/ports`: 8080 포트 대신 다른 포트를 선택할 경우 수정합니다. `.env`의 `BACKEND_PORT`와 동일하게 유지해야 합니다.
* `frontend/ports`: 3000 포트 대신 다른 포트를 선택할 경우 수정합니다. `.env`의 `FRONTEND_PORT`와 동일하게 유지해야 합니다.

### `.env` 추가 옵션

```env
# Redis 최대 메모리 (기본: 2gb)
REDIS_MAXMEMORY=2gb

# 턴 처리 간격 (밀리초, 기본: 10000 = 10초)
TURN_INTERVAL=10000

# DB 동기화 간격 (밀리초, 기본: 5000 = 5초)
DB_SYNC_INTERVAL=5000
```

---

## Docker-compose 실행

파일 설정이 모두 끝났다면, 콘솔에서 opensam 폴더로 이동하여 다음을 실행합니다.

```bash
docker compose up -d
```

총 5개의 컨테이너가 실행됩니다:

| 컨테이너 | 설명 | 포트 |
|----------|------|------|
| `opensam-mongodb` | MongoDB 데이터베이스 | 27017 |
| `opensam-redis` | Redis 캐시/세션 서버 | 6379 |
| `opensam-backend` | 게임 API 서버 | 8080 |
| `opensam-daemon` | 턴 처리/DB 동기화 데몬 | - |
| `opensam-frontend` | Next.js 웹 클라이언트 | 3000 |

### 실행 확인

```bash
# 컨테이너 상태 확인
docker compose ps

# 로그 확인
docker compose logs -f

# 특정 서비스 로그만 확인
docker compose logs -f backend
docker compose logs -f daemon
```

### Health Check

* Backend API: http://localhost:8080/health
* Frontend: http://localhost:3000

---

## 초기 설정

### 1. 관리자 계정 생성

```bash
./create-admin.sh
```

또는 수동으로:

```bash
docker exec -it opensam-backend npm run create-admin:js -- \
    --username admin \
    --email admin@example.com \
    --password your_password \
    --role admin
```

### 2. 게임 세션 초기화 (선택)

```bash
./init-sessions.sh
```

---

## 접속

설치가 완료되면 다음 주소로 접속할 수 있습니다:

| 서비스 | URL | 설명 |
|--------|-----|------|
| 게임 | http://localhost:3000 | 메인 게임 화면 |
| API 문서 | http://localhost:8080/api-docs | Swagger API 문서 |
| Health | http://localhost:8080/health | 서버 상태 확인 |

---

## 자주 사용하는 명령어

```bash
# 서비스 시작
docker compose up -d

# 서비스 중지
docker compose down

# 서비스 재시작
docker compose restart

# 로그 확인 (실시간)
docker compose logs -f

# 특정 서비스만 재시작
docker compose restart backend

# 이미지 재빌드 (코드 변경 후)
docker compose build --no-cache
docker compose up -d

# 볼륨 포함 완전 삭제 (데이터 초기화)
docker compose down -v
```

---

## 데이터베이스 관리

### MongoDB 접속

```bash
docker exec -it opensam-mongodb mongosh \
    -u admin \
    -p <MONGO_PASSWORD> \
    --authenticationDatabase admin \
    sangokushi
```

### Redis 접속

```bash
docker exec -it opensam-redis redis-cli -a <REDIS_PASSWORD>
```

### 데이터 백업

```bash
# MongoDB 백업
docker exec opensam-mongodb mongodump \
    -u admin -p <MONGO_PASSWORD> \
    --authenticationDatabase admin \
    --db sangokushi \
    --archive --gzip > backup_$(date +%Y%m%d).gz

# 복원
cat backup_20240101.gz | docker exec -i opensam-mongodb mongorestore \
    -u admin -p <MONGO_PASSWORD> \
    --authenticationDatabase admin \
    --archive --gzip --drop
```

---

## 개발 모드

개발 환경에서는 핫 리로드를 지원하는 개발용 구성을 사용합니다:

```bash
docker compose -f docker-compose.dev.yml up
```

개발 모드 특징:
* 소스 코드 변경 시 자동 재시작
* 상세 로그 출력
* Node.js 디버그 포트 노출 (9229)

---

## 문제 해결

### 서비스가 시작되지 않을 때

```bash
# 로그 확인
docker compose logs

# 특정 서비스 로그
docker compose logs backend
docker compose logs daemon

# 컨테이너 상태 확인  
docker compose ps -a
```

### 포트 충돌

다른 프로그램이 포트를 사용 중인 경우 `.env` 파일에서 포트를 변경합니다:

```env
FRONTEND_PORT=3001
BACKEND_PORT=8081
```

### 메모리 부족

Redis 메모리 제한을 조정합니다:

```env
REDIS_MAXMEMORY=1gb
```

### 외부에서 접속 안됨

1. 방화벽에서 해당 포트 열기
2. `.env`의 `FRONTEND_URL`, `NEXT_PUBLIC_API_URL`을 공인 IP로 변경
3. 서비스 재시작: `docker compose down && docker compose up -d`

---

## 업데이트

```bash
./update.sh
```

또는 수동으로:

```bash
# 서비스 중지
docker compose down

# 소스 업데이트
cd open-sam-backend && git pull && cd ..
cd open-sam-front && git pull && cd ..

# 이미지 재빌드 및 시작
docker compose build --no-cache
docker compose up -d
```

---

## 파일 구조

```
opensam/
├── docker-compose.yml      # 프로덕션 Docker 구성
├── docker-compose.dev.yml  # 개발용 Docker 구성
├── env.example             # 환경 변수 템플릿
├── .env                    # 실제 환경 변수 (git 제외)
├── install.sh              # 자동 설치 스크립트
├── setup.sh                # 환경 설정 스크립트
├── update.sh               # 업데이트 스크립트
├── create-admin.sh         # 관리자 생성 스크립트
├── init-sessions.sh        # 세션 초기화 스크립트
├── manage-session.sh       # 세션 관리 메뉴
├── open-sam-backend/       # Backend 소스 (git clone)
└── open-sam-front/         # Frontend 소스 (git clone)
```

---

## 관련 저장소

* **Docker 설정**: https://github.com/peppone-choi/opensam-docker
* **Backend**: https://github.com/peppone-choi/open-sam-backend
* **Frontend**: https://github.com/peppone-choi/open-sam-front

---

## 라이선스

MIT License
