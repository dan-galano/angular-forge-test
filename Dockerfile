FROM node:20-alpine AS deps
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --ignore-scripts

FROM node:20-alpine AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN node_modules/.bin/ng build --configuration production

FROM node:20-alpine AS runner
WORKDIR /app
ENV PORT=80
ENV NODE_ENV=production
COPY --from=builder /app/dist/forge-angular-test ./dist/forge-angular-test
COPY --from=builder /app/node_modules ./node_modules
EXPOSE 80
CMD ["node", "dist/forge-angular-test/server/server.mjs"]
