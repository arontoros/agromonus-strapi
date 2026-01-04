FROM node:20 AS build

WORKDIR /app

# Copy package files
COPY package.json package-lock.json ./

# Install dependencies (this will use Linux-compatible binaries)
RUN npm ci

# Copy source
COPY . .

# Build
ENV NODE_ENV=production
RUN npm run build

# Production stage
FROM node:20

RUN apt-get update && apt-get install -y \
    libvips-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy built app from build stage
COPY --from=build /app/package.json /app/package-lock.json ./
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist
COPY --from=build /app/build ./build
COPY --from=build /app/public ./public
COPY --from=build /app/.strapi ./.strapi
COPY --from=build /app/config ./config
COPY --from=build /app/database ./database
COPY --from=build /app/src ./src

ENV NODE_ENV=production

RUN chown -R node:node /app
USER node

EXPOSE 1337

CMD ["npm", "run", "start"]
