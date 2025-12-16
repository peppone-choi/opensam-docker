#!/bin/bash

# ==========================================
# OpenSAM Docker 자동 설치 스크립트
# ==========================================
# 
# 사용법: ./install.sh
# 
# 이 스크립트는 다음을 수행합니다:
#   1. Docker 및 Docker Compose 확인
#   2. Git 저장소 클론 (백엔드/프론트엔드)
#   3. 환경 변수 설정
#   4. Docker 컨테이너 빌드 및 실행
#   5. 초기 데이터 설정
# ==========================================

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 로고 출력
print_logo() {
    echo -e "${BLUE}"
    echo "  ___                   ____    _    __  __ "
    echo " / _ \ _ __   ___ _ __ / ___|  / \  |  \/  |"
    echo "| | | | '_ \ / _ \ '_ \\___ \ / _ \ | |\/| |"
    echo "| |_| | |_) |  __/ | | |___) / ___ \| |  | |"
    echo " \___/| .__/ \___|_| |_|____/_/   \_\_|  |_|"
    echo "      |_|                                    "
    echo -e "${NC}"
    echo -e "${GREEN}삼국지 모의전투 OpenSAM Docker 설치${NC}"
    echo ""
}

# 메시지 함수
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Docker 확인
check_docker() {
    log_info "Docker 설치 확인 중..."
    
    if ! command -v docker &> /dev/null; then
        log_error "Docker가 설치되어 있지 않습니다."
        echo "다음 링크에서 Docker를 설치하세요:"
        echo "  - Linux/Mac: https://docs.docker.com/install/"
        echo "  - Windows: https://docs.docker.com/docker-for-windows/install/"
        exit 1
    fi
    
    if ! docker info &> /dev/null; then
        log_error "Docker 데몬이 실행 중이지 않습니다."
        echo "Docker Desktop을 실행하거나 'sudo systemctl start docker'를 실행하세요."
        exit 1
    fi
    
    log_success "Docker 확인 완료"
}

# Docker Compose 확인
check_docker_compose() {
    log_info "Docker Compose 확인 중..."
    
    if docker compose version &> /dev/null; then
        COMPOSE_CMD="docker compose"
    elif command -v docker-compose &> /dev/null; then
        COMPOSE_CMD="docker-compose"
    else
        log_error "Docker Compose가 설치되어 있지 않습니다."
        exit 1
    fi
    
    log_success "Docker Compose 확인 완료 ($COMPOSE_CMD)"
}

# Git 저장소 클론
clone_repositories() {
    log_info "Git 저장소 클론 중..."
    
    # Backend 클론
    if [ ! -d "open-sam-backend" ]; then
        log_info "Backend 저장소 클론..."
        git clone https://github.com/peppone-choi/open-sam-backend.git
    else
        log_warning "Backend 폴더가 이미 존재합니다. 최신 버전으로 업데이트..."
        cd open-sam-backend && git pull && cd ..
    fi
    
    # Frontend 클론
    if [ ! -d "open-sam-front" ]; then
        log_info "Frontend 저장소 클론..."
        git clone https://github.com/peppone-choi/open-sam-front.git
    else
        log_warning "Frontend 폴더가 이미 존재합니다. 최신 버전으로 업데이트..."
        cd open-sam-front && git pull && cd ..
    fi
    
    log_success "저장소 클론 완료"
}

# 환경 변수 설정
setup_environment() {
    log_info "환경 변수 설정 중..."
    
    if [ ! -f ".env" ]; then
        cp env.example .env
        
        # 랜덤 비밀번호 생성
        MONGO_PASS=$(openssl rand -hex 16 2>/dev/null || cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
        REDIS_PASS=$(openssl rand -hex 16 2>/dev/null || cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
        JWT_SECRET=$(openssl rand -hex 32 2>/dev/null || cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 64 | head -n 1)
        JWT_REFRESH=$(openssl rand -hex 32 2>/dev/null || cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 64 | head -n 1)
        
        # .env 파일 업데이트
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS
            sed -i '' "s/changeme_secure_password/$MONGO_PASS/" .env
            sed -i '' "s/changeme_redis_password/$REDIS_PASS/" .env
            sed -i '' "s/your_jwt_secret_key_here_please_change_this/$JWT_SECRET/" .env
            sed -i '' "s/your_jwt_refresh_secret_key_here_please_change_this/$JWT_REFRESH/" .env
        else
            # Linux
            sed -i "s/changeme_secure_password/$MONGO_PASS/" .env
            sed -i "s/changeme_redis_password/$REDIS_PASS/" .env
            sed -i "s/your_jwt_secret_key_here_please_change_this/$JWT_SECRET/" .env
            sed -i "s/your_jwt_refresh_secret_key_here_please_change_this/$JWT_REFRESH/" .env
        fi
        
        log_success "환경 변수 파일 생성 완료 (.env)"
        log_warning "필요시 .env 파일을 수정하세요."
    else
        log_warning ".env 파일이 이미 존재합니다. 건너뜁니다."
    fi
}

# Docker 이미지 빌드 및 실행
start_services() {
    log_info "Docker 서비스 시작 중..."
    
    # 기존 컨테이너 정리
    $COMPOSE_CMD down --remove-orphans 2>/dev/null || true
    
    # 이미지 빌드 및 컨테이너 시작
    $COMPOSE_CMD up -d --build
    
    log_success "Docker 서비스 시작 완료"
}

# 서비스 상태 확인
check_services() {
    log_info "서비스 상태 확인 중..."
    
    echo ""
    $COMPOSE_CMD ps
    echo ""
    
    # 헬스체크 대기
    log_info "서비스 초기화 대기 중 (최대 60초)..."
    
    for i in {1..12}; do
        if curl -sf http://localhost:8080/health > /dev/null 2>&1; then
            log_success "Backend API 정상"
            break
        fi
        echo -n "."
        sleep 5
    done
    echo ""
}

# 완료 메시지
print_completion() {
    echo ""
    echo -e "${GREEN}===========================================${NC}"
    echo -e "${GREEN}     설치 완료!${NC}"
    echo -e "${GREEN}===========================================${NC}"
    echo ""
    echo -e "🌐 ${BLUE}프론트엔드:${NC} http://localhost:3000"
    echo -e "🔧 ${BLUE}백엔드 API:${NC} http://localhost:8080"
    echo -e "📚 ${BLUE}API 문서:${NC}   http://localhost:8080/api-docs"
    echo ""
    echo -e "${YELLOW}다음 단계:${NC}"
    echo "  1. 관리자 계정 생성: ./create-admin.sh"
    echo "  2. 게임 세션 초기화: ./init-sessions.sh"
    echo "  3. 로그 확인: docker compose logs -f"
    echo ""
    echo -e "${YELLOW}유용한 명령어:${NC}"
    echo "  - 서비스 중지: docker compose down"
    echo "  - 서비스 재시작: docker compose restart"
    echo "  - 업데이트: ./update.sh"
    echo ""
}

# 메인 실행
main() {
    print_logo
    
    check_docker
    check_docker_compose
    clone_repositories
    setup_environment
    start_services
    check_services
    print_completion
}

main "$@"

