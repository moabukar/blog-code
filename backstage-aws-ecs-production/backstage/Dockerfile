# Stage 1: Build
FROM node:18-bookworm-slim AS build

WORKDIR /app

# Install build dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    g++ \
    make \
    git \
    && rm -rf /var/lib/apt/lists/*

# Copy package files
COPY package.json yarn.lock ./
COPY packages/app/package.json ./packages/app/
COPY packages/backend/package.json ./packages/backend/

# Install dependencies
RUN yarn install --frozen-lockfile --network-timeout 600000

# Copy source
COPY . .

# Build backend
RUN yarn build:backend

# Stage 2: Production
FROM node:18-bookworm-slim AS production

WORKDIR /app

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    g++ \
    make \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy built backend
COPY --from=build /app/packages/backend/dist ./packages/backend/dist
COPY --from=build /app/yarn.lock ./
COPY --from=build /app/package.json ./

# Copy backend package.json
COPY --from=build /app/packages/backend/package.json ./packages/backend/

# Install production dependencies
RUN yarn install --frozen-lockfile --production --network-timeout 600000

# Copy app-config
COPY app-config.yaml app-config.production.yaml ./

# Set environment
ENV NODE_ENV=production

# Create non-root user
RUN groupadd -r backstage && useradd -r -g backstage backstage
RUN chown -R backstage:backstage /app
USER backstage

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:7007/healthcheck || exit 1

EXPOSE 7007

CMD ["node", "packages/backend", "--config", "app-config.yaml", "--config", "app-config.production.yaml"]
