FROM node:24-alpine AS builder

WORKDIR /builder

COPY package.json package-lock.json* ./

RUN npm ci

COPY . .

RUN npm run build


FROM nginx:alpine

COPY --from=builder /builder/dist/apps/web /usr/share/nginx/html

# 复制 Nginx 配置（解决 SPA 路由问题）
# 注意路径：nginx.conf 放在 docker 文件夹中
COPY ./docker/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
