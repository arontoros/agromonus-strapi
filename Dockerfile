FROM node:20

# Install vips for image processing
RUN apt-get update && apt-get install -y \
    libvips-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY package.json ./

# CRITICAL: Regenerate package-lock.json in Linux environment
# This ensures SWC native bindings are correct for Linux
RUN npm install

COPY . .

# Build Strapi
ENV NODE_ENV=production
RUN npm run build

# Clean up dev dependencies
RUN npm prune --production

RUN chown -R node:node /app
USER node

EXPOSE 1337

CMD ["npm", "run", "start"]
