#!/bin/bash

# ==========================================
# OpenSAM 게임 세션 초기화 스크립트
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
echo -e "${BLUE}     OpenSAM 게임 세션 초기화${NC}"
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

# 세션 정보 입력
echo ""
echo -e "${YELLOW}세션 초기화 옵션:${NC}"
echo "  1. 기본 시나리오 (삼국지)"
echo "  2. 커스텀 시나리오"
echo ""
read -p "선택 [1]: " scenario_choice
scenario_choice=${scenario_choice:-1}

case $scenario_choice in
    1)
        scenario="sangokushi"
        ;;
    2)
        read -p "시나리오 ID: " scenario
        if [ -z "$scenario" ]; then
            scenario="sangokushi"
        fi
        ;;
    *)
        scenario="sangokushi"
        ;;
esac

# 확인
echo ""
echo -e "${YELLOW}초기화 설정:${NC}"
echo "  시나리오: $scenario"
echo ""
log_warning "이 작업은 기존 게임 데이터를 모두 삭제합니다!"
read -p "계속하시겠습니까? (y/N): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log_info "취소되었습니다."
    exit 0
fi

# 세션 초기화 실행
log_info "게임 세션 초기화 중..."

# 도시 초기화
log_info "도시 데이터 초기화..."
docker exec opensam-backend npm run init-cities 2>/dev/null || log_warning "init-cities 스크립트 없음"

# 장수 명령 초기화
log_info "장수 명령 초기화..."
docker exec opensam-backend npm run init-general-commands 2>/dev/null || log_warning "init-general-commands 스크립트 없음"

# 서버 정보 업데이트
log_info "서버 정보 업데이트..."
docker exec opensam-backend npm run create-servers 2>/dev/null || log_warning "create-servers 스크립트 없음"

echo ""
log_success "게임 세션 초기화 완료!"
echo ""
echo -e "${YELLOW}다음 단계:${NC}"
echo "  1. 프론트엔드 접속: http://localhost:${FRONTEND_PORT:-3000}"
echo "  2. 회원가입 후 게임 시작"
echo ""






