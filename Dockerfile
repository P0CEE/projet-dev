FROM node:20-alpine AS base

RUN apk add --no-cache libc6-compat python3 make g++ openssl dos2unix && \
    corepack enable && corepack prepare pnpm@latest --activate

FROM base AS dev
WORKDIR /app
ENV NODE_ENV=development
ENV PATH /app/node_modules/.bin:$PATH

COPY package.json pnpm-lock.yaml ./

RUN pnpm install --frozen-lockfile

COPY . ./

CMD ["sh", "-c", "pnpm dev"]

FROM base AS deps
WORKDIR /app

COPY package.json pnpm-lock.yaml ./
COPY prisma ./prisma/

RUN pnpm install --frozen-lockfile --prod
RUN npx prisma generate

FROM base AS builder
WORKDIR /app

COPY --from=deps /app/node_modules ./node_modules
COPY . ./

RUN pnpm build && npx prisma generate

FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production

RUN addgroup -S nodejs && adduser -S nextjs -G nodejs

COPY --from=builder /app/public ./public
COPY --from=builder /app/prisma ./prisma
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/node_modules/.prisma ./node_modules/.prisma

COPY entrypoint.sh ./entrypoint.sh
RUN chmod +x ./entrypoint.sh

USER nextjs

EXPOSE 3000

ENTRYPOINT []
CMD ["/bin/sh", "./entrypoint.sh"]