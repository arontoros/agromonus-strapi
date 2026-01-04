FROM node:18-alpine

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

# Install ALL dependencies INCLUDING devDependencies
ENV NODE_ENV=development
RUN npm install

COPY . .

# NOW build with NODE_ENV=production
ENV NODE_ENV=production
RUN npm run build

# Clean up dev dependencies AFTER build
RUN npm prune --production

RUN chown -R node:node /app
USER node

EXPOSE 1337

CMD ["npm", "run", "start"]
