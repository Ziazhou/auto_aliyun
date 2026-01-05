#!/bin/bash

set -e

echo "🔄 开始部署流程..."
cd /opt/vue-app

# 登录GitHub Container Registry（如果未登录）
if ! docker login ghcr.io -u YOUR_GITHUB_USERNAME -p $GHCR_TOKEN > /dev/null 2>&1; then
    echo "⚠️  需要登录GitHub Container Registry"
    echo "请先在服务器上执行: echo $GHCR_TOKEN | docker login ghcr.io -u YOUR_GITHUB_USERNAME --password-stdin"
    exit 1
fi

# 拉取最新镜像
echo "📥 拉取最新镜像..."
docker compose pull

# 重新创建并启动容器（不停机）
echo "🚀 更新容器..."
docker compose up -d --remove-orphans

# 清理旧镜像
echo "🧹 清理旧镜像..."
docker image prune -af --filter "label!=com.docker.compose.project=vue-app"

# 检查状态
echo "✅ 部署完成！当前状态："
docker compose ps

echo "📋 最新日志："
docker compose logs --tail=20