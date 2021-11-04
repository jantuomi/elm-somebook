FROM node:17 AS builder

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci --only-prod
COPY . ./
RUN npm run build

FROM halverneus/static-file-server:latest AS server

COPY --from=builder /app/dist /web
