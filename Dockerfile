FROM node:20 AS build

WORKDIR /app

# Copy only package.json (NOT package-lock.json)
COPY package.json ./

# This will create a fresh Linux-compatible package-lock.json
RUN npm install

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

# Copy from build stage
COPY --from=build /app ./

ENV NODE_ENV=production

RUN chown -R node:node /app
USER node

EXPOSE 1337

CMD ["npm", "run", "start"]
