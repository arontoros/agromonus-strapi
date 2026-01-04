FROM node:20

# Install vips for image processing
RUN apt-get update && apt-get install -y \
    libvips-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY package.json package-lock.json ./

# Install with development mode to get all deps
ENV NODE_ENV=development
RUN npm install

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
