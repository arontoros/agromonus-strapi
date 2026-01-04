FROM node:20

RUN apt-get update && apt-get install -y \
    libvips-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy only package.json (NOT package-lock.json)
COPY package.json ./

# Install all dependencies (including pg)
RUN npm install

# Copy source code
COPY . .

# Build Strapi admin
ENV NODE_ENV=production
RUN npm run build

# IMPORTANT: Do NOT run npm prune - we need pg module!

RUN chown -R node:node /app
USER node

EXPOSE 1337

CMD ["npm", "run", "start"]
