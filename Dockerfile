FROM node:20

# Install vips for image processing
RUN apt-get update && apt-get install -y \
    libvips-dev \
    python3 \
    make \
    g++ \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY package.json package-lock.json ./

# Install ALL dependencies
ENV NODE_ENV=development
RUN npm install

# CRITICAL: Rebuild SWC with correct architecture
RUN npm rebuild @swc/core

COPY . .

# Build with production
ENV NODE_ENV=production
RUN npm run build

# Clean up dev dependencies
RUN npm prune --production

RUN chown -R node:node /app
USER node

EXPOSE 1337

CMD ["npm", "run", "start"]
