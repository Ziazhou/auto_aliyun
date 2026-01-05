#!/bin/bash

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}🔄 开始部署流程${NC}"

# 检查必要环境变量
if [ -z "$GHCR_TOKEN" ]; then
    echo -e "${RED}❌ 错误: GHCR_TOKEN 未设置${NC}"
    exit 1
fi

cd /opt/vue-app

# 自动登录
echo -e "${YELLOW}🔐 登录 GitHub Container Registry${NC}"
echo "$GHCR_TOKEN" | docker login ghcr.io -u ziazhou --password-stdin

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Docker 登录失败${NC}"
    exit 1
fi

# 拉取镜像
echo -e "${YELLOW}📥 拉取最新镜像${NC}"
docker compose pull

# 部署
echo -e "${YELLOW}🚀 更新容器${NC}"
docker compose up -d --remove-orphans

# 清理
echo -e "${YELLOW}🧹 清理旧镜像${NC}"
docker image prune -af --filter "label!=com.docker.compose.project=vue-app" || true

echo -e "${GREEN}✅ 部署完成${NC}"
docker compose ps
docker compose logs --tail=10