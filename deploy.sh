#!/bin/bash

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🔄 开始部署流程...${NC}"

# 检查 GHCR_TOKEN 是否存在
if [ -z "$GHCR_TOKEN" ]; then
    echo -e "${RED}❌ 错误: GHCR_TOKEN 环境变量未设置${NC}"
    echo -e "${YELLOW}请在 GitHub Secrets 中配置 GHCR_TOKEN${NC}"
    exit 1
fi

cd /opt/vue-app

# 自动登录 GitHub Container Registry
echo -e "${YELLOW}🔐 登录到 GitHub Container Registry...${NC}"
echo "$GHCR_TOKEN" | docker login ghcr.io -u Ziazhou --password-stdin

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Docker 登录失败，请检查 GHCR_TOKEN 是否有效${NC}"
    exit 1
fi

# 拉取最新镜像
echo -e "${YELLOW}📥 拉取最新镜像...${NC}"
docker compose pull

# 重新创建并启动容器（零停机部署）
echo -e "${YELLOW}🚀 更新容器...${NC}"
docker compose up -d --remove-orphans

# 清理旧镜像（保留当前使用的镜像）
echo -e "${YELLOW}🧹 清理旧镜像...${NC}"
docker image prune -af --filter "label!=com.docker.compose.project=vue-app" || true

echo -e "${GREEN}✅ 部署完成！${NC}"

# 显示容器状态
echo -e "${YELLOW}📋 容器状态：${NC}"
docker compose ps

# 显示最新日志
echo -e "${YELLOW}📋 最新日志：${NC}"
docker compose logs --tail=10