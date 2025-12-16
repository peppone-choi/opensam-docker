#!/bin/bash

# ==========================================
# OpenSAM Docker 환경 설정 스크립트
# ==========================================
# 
# 사용법: ./setup.sh
# 
# 이 스크립트는 .env 파일만 설정합니다.
# 전체 설치는 ./install.sh를 사용하세요.
# ==========================================

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }

echo -e "${BLUE}===========================================${NC}"
echo -e "${BLUE}     OpenSAM 환경 설정${NC}"
echo -e "${BLUE}===========================================${NC}"
echo ""

# env.example 확인
if [ ! -f "env.example" ]; then
    log_error "env.example 파일이 없습니다."
    exit 1
fi

# .env 파일 존재 확인
if [ -f ".env" ]; then
    read -p "기존 .env 파일이 있습니다. 덮어쓰시겠습니까? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "설정을 취소합니다."
        exit 0
    fi
    mv .env .env.backup
    log_info "기존 .env 파일을 .env.backup으로 백업했습니다."
fi

# env.example 복사
cp env.example .env

# 대화형 설정
echo ""
log_info "환경 변수를 설정합니다. (Enter로 기본값 사용)"
echo ""

# MongoDB 설정
read -p "MongoDB 사용자명 [admin]: " mongo_user
mongo_user=${mongo_user:-admin}

read -p "MongoDB 비밀번호 (자동 생성하려면 Enter): " mongo_pass
if [ -z "$mongo_pass" ]; then
    mongo_pass=$(openssl rand -hex 16 2>/dev/null || cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
    log_info "MongoDB 비밀번호 자동 생성됨"
fi

read -p "MongoDB 데이터베이스명 [sangokushi]: " mongo_db
mongo_db=${mongo_db:-sangokushi}

# Redis 설정
read -p "Redis 비밀번호 (자동 생성하려면 Enter): " redis_pass
if [ -z "$redis_pass" ]; then
    redis_pass=$(openssl rand -hex 16 2>/dev/null || cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
    log_info "Redis 비밀번호 자동 생성됨"
fi

# 서버 설정
read -p "서버 이름 [OpenSAM]: " server_name
server_name=${server_name:-OpenSAM}

read -p "세션 ID [default]: " session_id
session_id=${session_id:-default}

# 포트 설정
read -p "프론트엔드 포트 [3000]: " frontend_port
frontend_port=${frontend_port:-3000}

read -p "백엔드 API 포트 [8080]: " backend_port
backend_port=${backend_port:-8080}

# JWT 시크릿 생성
jwt_secret=$(openssl rand -hex 32 2>/dev/null || cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 64 | head -n 1)
jwt_refresh=$(openssl rand -hex 32 2>/dev/null || cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 64 | head -n 1)

# .env 파일 업데이트
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s/MONGO_USER=.*/MONGO_USER=$mongo_user/" .env
    sed -i '' "s/MONGO_PASSWORD=.*/MONGO_PASSWORD=$mongo_pass/" .env
    sed -i '' "s/MONGO_DB=.*/MONGO_DB=$mongo_db/" .env
    sed -i '' "s/REDIS_PASSWORD=.*/REDIS_PASSWORD=$redis_pass/" .env
    sed -i '' "s/SERVER_NAME=.*/SERVER_NAME=$server_name/" .env
    sed -i '' "s/SESSION_ID=.*/SESSION_ID=$session_id/" .env
    sed -i '' "s/FRONTEND_PORT=.*/FRONTEND_PORT=$frontend_port/" .env
    sed -i '' "s/BACKEND_PORT=.*/BACKEND_PORT=$backend_port/" .env
    sed -i '' "s/your_jwt_secret_key_here_please_change_this/$jwt_secret/" .env
    sed -i '' "s/your_jwt_refresh_secret_key_here_please_change_this/$jwt_refresh/" .env
    sed -i '' "s|FRONTEND_URL=.*|FRONTEND_URL=http://localhost:$frontend_port|" .env
    sed -i '' "s|CORS_ORIGIN=.*|CORS_ORIGIN=http://localhost:$frontend_port|" .env
    sed -i '' "s|NEXT_PUBLIC_API_URL=.*|NEXT_PUBLIC_API_URL=http://localhost:$backend_port|" .env
else
    # Linux
    sed -i "s/MONGO_USER=.*/MONGO_USER=$mongo_user/" .env
    sed -i "s/MONGO_PASSWORD=.*/MONGO_PASSWORD=$mongo_pass/" .env
    sed -i "s/MONGO_DB=.*/MONGO_DB=$mongo_db/" .env
    sed -i "s/REDIS_PASSWORD=.*/REDIS_PASSWORD=$redis_pass/" .env
    sed -i "s/SERVER_NAME=.*/SERVER_NAME=$server_name/" .env
    sed -i "s/SESSION_ID=.*/SESSION_ID=$session_id/" .env
    sed -i "s/FRONTEND_PORT=.*/FRONTEND_PORT=$frontend_port/" .env
    sed -i "s/BACKEND_PORT=.*/BACKEND_PORT=$backend_port/" .env
    sed -i "s/your_jwt_secret_key_here_please_change_this/$jwt_secret/" .env
    sed -i "s/your_jwt_refresh_secret_key_here_please_change_this/$jwt_refresh/" .env
    sed -i "s|FRONTEND_URL=.*|FRONTEND_URL=http://localhost:$frontend_port|" .env
    sed -i "s|CORS_ORIGIN=.*|CORS_ORIGIN=http://localhost:$frontend_port|" .env
    sed -i "s|NEXT_PUBLIC_API_URL=.*|NEXT_PUBLIC_API_URL=http://localhost:$backend_port|" .env
fi

echo ""
log_success "환경 설정 완료!"
echo ""
echo -e "${YELLOW}설정 요약:${NC}"
echo "  MongoDB: $mongo_user@localhost:27017/$mongo_db"
echo "  Redis: localhost:6379"
echo "  Frontend: http://localhost:$frontend_port"
echo "  Backend: http://localhost:$backend_port"
echo "  Server Name: $server_name"
echo "  Session ID: $session_id"
echo ""
echo -e "${YELLOW}다음 단계:${NC}"
echo "  docker compose up -d"
echo ""

