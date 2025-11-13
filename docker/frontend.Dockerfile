FROM node:24-alpine AS builder

WORKDIR /builder

COPY package.json package-lock.json* ./

RUN npm ci

COPY . .

RUN npm run build


FROM lipanski/docker-static-website:2.4.0

WORKDIR /home/static

COPY  --from=builder /builder/dist/apps/web/  /home/

COPY httpd.conf /home/static/httpd.conf

EXPOSE 80

CMD ["/busybox-httpd", "-f", "-v", "-p", "80", "-c", "httpd.conf"]
