FROM node:20-alpine

RUN apk update && apk add --no-cache \
    build-base \
    gcc \
    autoconf \
    automake \
    zlib-dev \
    libpng-dev \
    nasm \
    bash \
    vips-dev \
    git

WORKDIR /app

COPY package.json package-lock.json ./

# Install with NODE_ENV=development to get ALL deps
ENV NODE_ENV=development
RUN npm install

COPY . .

# Build with production
ENV NODE_ENV=production
RUN npm run build

# Remove dev deps
RUN npm prune --production

RUN chown -R node:node /app
USER node

EXPOSE 1337

CMD ["npm", "run", "start"]
