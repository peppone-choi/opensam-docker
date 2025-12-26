#!/bin/bash

# ==========================================
# OpenSAM Docker 업데이트 스크립트
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
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

echo -e "${BLUE}===========================================${NC}"
echo -e "${BLUE}     OpenSAM 업데이트${NC}"
echo -e "${BLUE}===========================================${NC}"
echo ""

# Docker Compose 명령어 확인
if docker compose version &> /dev/null; then
    COMPOSE_CMD="docker compose"
elif command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
else
    log_error "Docker Compose가 설치되어 있지 않습니다."
    exit 1
fi

# 현재 서비스 상태 저장
log_info "현재 서비스 상태 확인..."
RUNNING_SERVICES=$($COMPOSE_CMD ps --services --filter "status=running" 2>/dev/null || echo "")

# 서비스 중지
log_info "서비스 중지 중..."
$COMPOSE_CMD down

# Docker 설정 업데이트
log_info "Docker 설정 업데이트 중..."
if [ -d ".git" ]; then
    git pull origin main || git pull
fi

# Backend 업데이트
if [ -d "open-sam-backend" ]; then
    log_info "Backend 업데이트 중..."
    cd open-sam-backend
    git fetch --all
    git reset --hard origin/main || git reset --hard origin/master
    cd ..
    log_success "Backend 업데이트 완료"
else
    log_warning "Backend 폴더가 없습니다. 클론합니다..."
    git clone https://github.com/peppone-choi/open-sam-backend.git
fi

# Frontend 업데이트
if [ -d "open-sam-front" ]; then
    log_info "Frontend 업데이트 중..."
    cd open-sam-front
    git fetch --all
    git reset --hard origin/main || git reset --hard origin/master
    cd ..
    log_success "Frontend 업데이트 완료"
else
    log_warning "Frontend 폴더가 없습니다. 클론합니다..."
    git clone https://github.com/peppone-choi/open-sam-front.git
fi

# Docker 이미지 재빌드
log_info "Docker 이미지 재빌드 중..."
$COMPOSE_CMD build --no-cache

# 서비스 시작
log_info "서비스 시작 중..."
$COMPOSE_CMD up -d

# 상태 확인
log_info "서비스 상태 확인..."
sleep 5
$COMPOSE_CMD ps

echo ""
log_success "업데이트 완료!"
echo ""
echo -e "${YELLOW}서비스 접속 정보:${NC}"
echo "  🌐 프론트엔드: http://localhost:${FRONTEND_PORT:-3000}"
echo "  🔧 백엔드 API: http://localhost:${BACKEND_PORT:-8080}"
echo ""




















