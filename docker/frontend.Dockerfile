FROM node:24-alpine AS builder

WORKDIR /builder

COPY package.json package-lock.json* ./

RUN npm ci

COPY . .

RUN npm run build


FROM nginx:alpine

WORKDIR /home/frontend

# 设置时区
ENV TIME_ZONE Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TIME_ZONE /etc/localtime && echo $TIME_ZONE > /etc/timezone

# 创建日志目录、pid目录并设置权限
RUN mkdir -p /home/frontend/logs \
    /home/frontend/run \
    && chown -R nginx:nginx /home/frontend \
    /var/cache/nginx \
    /var/run \
    /var/log/nginx

COPY --from=builder /builder/dist/apps/web /usr/share/nginx/html

COPY ./docker/default.conf /etc/nginx/conf.d/

COPY ./docker/nginx.conf /etc/nginx/nginx.conf

USER nginx

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
