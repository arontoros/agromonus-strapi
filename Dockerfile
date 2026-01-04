# Creating multi-stage build for production
FROM node:20-alpine AS build
RUN apk update && apk add --no-cache build-base gcc autoconf automake zlib-dev libpng-dev vips-dev git python3 > /dev/null 2>&1

WORKDIR /app

# Copy package files
COPY package.json package-lock.json ./

# Install ALL dependencies (including dev)
RUN npm install

# Copy source code
COPY . .

# Build Strapi admin panel
ENV NODE_ENV=production
RUN npm run build

# Creating final production image
FROM node:20-alpine
RUN apk add --no-cache vips-dev

WORKDIR /app

# Copy package files
COPY package.json package-lock.json ./

# Install only production dependencies
RUN npm install --omit=dev

# Copy built application from build stage
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