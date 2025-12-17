#!/bin/bash

# ==========================================
# OpenSAM 관리자 계정 생성 스크립트
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
echo -e "${BLUE}     OpenSAM 관리자 계정 생성${NC}"
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

# 서비스 확인
if ! $COMPOSE_CMD ps | grep -q "opensam-backend.*running"; then
    log_error "Backend 서비스가 실행 중이지 않습니다."
    echo "먼저 'docker compose up -d'를 실행하세요."
    exit 1
fi

# 관리자 정보 입력
echo ""
read -p "관리자 사용자명: " admin_username
if [ -z "$admin_username" ]; then
    log_error "사용자명을 입력하세요."
    exit 1
fi

read -p "관리자 이메일: " admin_email
if [ -z "$admin_email" ]; then
    log_error "이메일을 입력하세요."
    exit 1
fi

read -s -p "관리자 비밀번호: " admin_password
echo ""
if [ -z "$admin_password" ]; then
    log_error "비밀번호를 입력하세요."
    exit 1
fi

read -s -p "비밀번호 확인: " admin_password_confirm
echo ""
if [ "$admin_password" != "$admin_password_confirm" ]; then
    log_error "비밀번호가 일치하지 않습니다."
    exit 1
fi

# 관리자 계정 생성
log_info "관리자 계정 생성 중..."

docker exec -it opensam-backend npm run create-admin:js -- \
    --username "$admin_username" \
    --email "$admin_email" \
    --password "$admin_password" \
    --role admin

if [ $? -eq 0 ]; then
    echo ""
    log_success "관리자 계정 생성 완료!"
    echo ""
    echo -e "${YELLOW}로그인 정보:${NC}"
    echo "  사용자명: $admin_username"
    echo "  이메일: $admin_email"
    echo ""
else
    log_error "관리자 계정 생성 실패"
    exit 1
fi



