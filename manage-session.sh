#!/bin/bash

# ==========================================
# OpenSAM 세션 관리 스크립트
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

# Docker Compose 명령어 확인
if docker compose version &> /dev/null; then
    COMPOSE_CMD="docker compose"
elif command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
else
    log_error "Docker Compose가 설치되어 있지 않습니다."
    exit 1
fi

show_menu() {
    clear
    echo -e "${BLUE}===========================================${NC}"
    echo -e "${BLUE}     OpenSAM 세션 관리${NC}"
    echo -e "${BLUE}===========================================${NC}"
    echo ""
    echo "  1. 서비스 상태 확인"
    echo "  2. 서비스 시작"
    echo "  3. 서비스 중지"
    echo "  4. 서비스 재시작"
    echo "  5. 로그 보기 (전체)"
    echo "  6. 로그 보기 (Backend)"
    echo "  7. 로그 보기 (Daemon)"
    echo "  8. 로그 보기 (Frontend)"
    echo "  9. MongoDB 쉘 접속"
    echo "  10. Redis CLI 접속"
    echo "  11. Backend 쉘 접속"
    echo "  12. 데이터베이스 백업"
    echo "  13. 데이터베이스 복원"
    echo "  14. 캐시 초기화 (Redis)"
    echo "  0. 종료"
    echo ""
    read -p "선택: " choice
}

service_status() {
    echo ""
    log_info "서비스 상태"
    echo ""
    $COMPOSE_CMD ps
    echo ""
    read -p "계속하려면 Enter..."
}

service_start() {
    log_info "서비스 시작 중..."
    $COMPOSE_CMD up -d
    log_success "서비스 시작 완료"
    read -p "계속하려면 Enter..."
}

service_stop() {
    log_info "서비스 중지 중..."
    $COMPOSE_CMD down
    log_success "서비스 중지 완료"
    read -p "계속하려면 Enter..."
}

service_restart() {
    log_info "서비스 재시작 중..."
    $COMPOSE_CMD restart
    log_success "서비스 재시작 완료"
    read -p "계속하려면 Enter..."
}

view_logs_all() {
    $COMPOSE_CMD logs -f --tail=100
}

view_logs_backend() {
    $COMPOSE_CMD logs -f --tail=100 backend
}

view_logs_daemon() {
    $COMPOSE_CMD logs -f --tail=100 daemon
}

view_logs_frontend() {
    $COMPOSE_CMD logs -f --tail=100 frontend
}

mongo_shell() {
    source .env 2>/dev/null || true
    docker exec -it opensam-mongodb mongosh \
        -u "${MONGO_USER:-admin}" \
        -p "${MONGO_PASSWORD:-changeme}" \
        --authenticationDatabase admin \
        "${MONGO_DB:-sangokushi}"
}

redis_cli() {
    source .env 2>/dev/null || true
    docker exec -it opensam-redis redis-cli -a "${REDIS_PASSWORD:-changeme}"
}

backend_shell() {
    docker exec -it opensam-backend sh
}

backup_database() {
    source .env 2>/dev/null || true
    BACKUP_DIR="./backups"
    BACKUP_FILE="$BACKUP_DIR/mongodb_$(date +%Y%m%d_%H%M%S).gz"
    
    mkdir -p "$BACKUP_DIR"
    
    log_info "MongoDB 백업 중..."
    docker exec opensam-mongodb mongodump \
        -u "${MONGO_USER:-admin}" \
        -p "${MONGO_PASSWORD:-changeme}" \
        --authenticationDatabase admin \
        --db "${MONGO_DB:-sangokushi}" \
        --archive --gzip | cat > "$BACKUP_FILE"
    
    log_success "백업 완료: $BACKUP_FILE"
    read -p "계속하려면 Enter..."
}

restore_database() {
    source .env 2>/dev/null || true
    BACKUP_DIR="./backups"
    
    if [ ! -d "$BACKUP_DIR" ]; then
        log_error "백업 폴더가 없습니다."
        read -p "계속하려면 Enter..."
        return
    fi
    
    echo ""
    echo "사용 가능한 백업:"
    ls -la "$BACKUP_DIR"/*.gz 2>/dev/null || echo "백업 파일 없음"
    echo ""
    
    read -p "복원할 백업 파일 경로: " backup_file
    if [ ! -f "$backup_file" ]; then
        log_error "파일을 찾을 수 없습니다: $backup_file"
        read -p "계속하려면 Enter..."
        return
    fi
    
    log_warning "이 작업은 기존 데이터를 덮어씁니다!"
    read -p "계속하시겠습니까? (y/N): " -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "취소되었습니다."
        read -p "계속하려면 Enter..."
        return
    fi
    
    log_info "MongoDB 복원 중..."
    cat "$backup_file" | docker exec -i opensam-mongodb mongorestore \
        -u "${MONGO_USER:-admin}" \
        -p "${MONGO_PASSWORD:-changeme}" \
        --authenticationDatabase admin \
        --archive --gzip --drop
    
    log_success "복원 완료"
    read -p "계속하려면 Enter..."
}

clear_redis() {
    source .env 2>/dev/null || true
    
    log_warning "이 작업은 모든 캐시 데이터를 삭제합니다!"
    read -p "계속하시겠습니까? (y/N): " -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "취소되었습니다."
        read -p "계속하려면 Enter..."
        return
    fi
    
    log_info "Redis 캐시 초기화 중..."
    docker exec opensam-redis redis-cli -a "${REDIS_PASSWORD:-changeme}" FLUSHALL
    
    log_success "캐시 초기화 완료"
    log_warning "서비스 재시작을 권장합니다."
    read -p "계속하려면 Enter..."
}

# 메인 루프
while true; do
    show_menu
    case $choice in
        1) service_status ;;
        2) service_start ;;
        3) service_stop ;;
        4) service_restart ;;
        5) view_logs_all ;;
        6) view_logs_backend ;;
        7) view_logs_daemon ;;
        8) view_logs_frontend ;;
        9) mongo_shell ;;
        10) redis_cli ;;
        11) backend_shell ;;
        12) backup_database ;;
        13) restore_database ;;
        14) clear_redis ;;
        0) 
            echo "종료합니다."
            exit 0
            ;;
        *)
            log_error "잘못된 선택입니다."
            read -p "계속하려면 Enter..."
            ;;
    esac
done






