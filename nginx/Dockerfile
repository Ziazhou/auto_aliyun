FROM nginx:alpine

# 复制Nginx配置
COPY nginx/default.conf /etc/nginx/conf.d/default.conf

# 复制前端静态文件
COPY frontend/dist /usr/share/nginx/html

# 设置时区
RUN apk add --no-cache tzdata && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone

EXPOSE 80