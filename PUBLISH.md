# OpenSAM Docker 이미지 배포 가이드

이 문서는 OpenSAM Docker 이미지를 GitHub Container Registry(ghcr.io)에 배포하는 방법을 설명합니다.

## 📋 사전 요구사항

1. GitHub 계정
2. Docker 설치
3. 저장소 쓰기 권한

## 🔐 GitHub Container Registry 인증

### Personal Access Token (PAT) 생성

1. GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
2. "Generate new token (classic)" 클릭
3. 권한 선택:
   - `write:packages`
   - `read:packages`
   - `delete:packages` (선택)
4. 토큰 복사 및 저장

### Docker 로그인

```bash
# 토큰으로 로그인
echo $GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin

# 또는 대화형으로
docker login ghcr.io
```

## 🏗️ 이미지 빌드

### Backend 이미지

```bash
cd open-sam-backend

# 빌드
docker build -t ghcr.io/peppone-choi/open-sam-backend:latest .

# 버전 태그 추가
docker tag ghcr.io/peppone-choi/open-sam-backend:latest \
           ghcr.io/peppone-choi/open-sam-backend:v1.0.0
```

### Frontend 이미지

```bash
cd open-sam-front

# 빌드
docker build -t ghcr.io/peppone-choi/open-sam-front:latest .

# 버전 태그 추가
docker tag ghcr.io/peppone-choi/open-sam-front:latest \
           ghcr.io/peppone-choi/open-sam-front:v1.0.0
```

## 📤 이미지 푸시

```bash
# Backend 푸시
docker push ghcr.io/peppone-choi/open-sam-backend:latest
docker push ghcr.io/peppone-choi/open-sam-backend:v1.0.0

# Frontend 푸시
docker push ghcr.io/peppone-choi/open-sam-front:latest
docker push ghcr.io/peppone-choi/open-sam-front:v1.0.0
```

## 🤖 GitHub Actions 자동화

`.github/workflows/docker-publish.yml` 파일 생성:

```yaml
name: Docker Build and Publish

on:
  push:
    branches: [main]
    tags: ['v*']
  pull_request:
    branches: [main]

env:
  REGISTRY: ghcr.io

jobs:
  build-backend:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
        with:
          submodules: recursive

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Log in to Container Registry
        uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ env.REGISTRY }}/${{ github.repository_owner }}/open-sam-backend
          tags: |
            type=ref,event=branch
            type=ref,event=pr
            type=semver,pattern={{version}}
            type=semver,pattern={{major}}.{{minor}}
            type=raw,value=latest,enable={{is_default_branch}}

      - name: Build and push Backend
        uses: docker/build-push-action@v5
        with:
          context: ./open-sam-backend
          push: ${{ github.event_name != 'pull_request' }}
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max

  build-frontend:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
        with:
          submodules: recursive

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Log in to Container Registry
        uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ env.REGISTRY }}/${{ github.repository_owner }}/open-sam-front
          tags: |
            type=ref,event=branch
            type=ref,event=pr
            type=semver,pattern={{version}}
            type=semver,pattern={{major}}.{{minor}}
            type=raw,value=latest,enable={{is_default_branch}}

      - name: Build and push Frontend
        uses: docker/build-push-action@v5
        with:
          context: ./open-sam-front
          push: ${{ github.event_name != 'pull_request' }}
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

## 📦 릴리스 프로세스

### 1. 버전 태그 생성

```bash
# 버전 태그 생성
git tag v1.0.0
git push origin v1.0.0
```

### 2. GitHub Actions 자동 빌드

태그 푸시 시 자동으로:
- Docker 이미지 빌드
- ghcr.io에 푸시
- 버전 태그 및 latest 태그 적용

### 3. 릴리스 노트 작성

GitHub → Releases → "Create a new release"
- 태그 선택
- 변경사항 작성
- 배포

## 🔍 이미지 확인

```bash
# 이미지 목록 확인
docker images | grep ghcr.io/peppone-choi

# 특정 이미지 정보
docker inspect ghcr.io/peppone-choi/open-sam-backend:latest
```

## 🗑️ 이미지 삭제

GitHub → Packages → 해당 패키지 → Package settings → Delete this package

---

## 📝 버전 관리 규칙

- `latest`: 최신 main 브랜치
- `v1.0.0`: 정식 릴리스
- `v1.0.0-rc1`: 릴리스 후보
- `v1.0.0-beta`: 베타 버전
- `main`: main 브랜치 최신




















