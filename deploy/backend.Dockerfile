FROM node:20-alpine

WORKDIR /app

COPY app/backend/package*.json ./
RUN npm ci --omit=dev

COPY app/backend/ .

ENV NODE_ENV=production
EXPOSE 3000

CMD ["node","index.js"]
