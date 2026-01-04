# Creating multi-stage build for production
FROM node:20-alpine AS build
RUN apk update && apk add --no-cache build-base gcc autoconf automake zlib-dev libpng-dev vips-dev git python3 > /dev/null 2>&1
ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}

WORKDIR /opt/
COPY package.json package-lock.json ./
RUN npm install -g node-gyp
# ÚJ: npm install (NEM --only=production) + rebuild
RUN npm config set fetch-retry-maxtimeout 600000 -g && npm install
RUN npm rebuild @swc/core
ENV PATH=/opt/node_modules/.bin:$PATH
WORKDIR /opt/app
COPY . .
RUN npm run build

# Creating final production image
FROM node:20-alpine
RUN apk add --no-cache vips-dev
ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}
WORKDIR /opt/
# ÚJ: install production dependencies újra a final image-ben
COPY package.json package-lock.json ./
RUN npm install --omit=dev
WORKDIR /opt/app
COPY --from=build /opt/app/dist ./dist
COPY --from=build /opt/app/build ./build
COPY --from=build /opt/app/public ./public
COPY --from=build /opt/app/.strapi ./.strapi
COPY --from=build /opt/app/config ./config
COPY --from=build /opt/app/database ./database
COPY --from=build /opt/app/src ./src
COPY --from=build /opt/app/package.json ./package.json
ENV PATH=/opt/node_modules/.bin:$PATH

RUN chown -R node:node /opt/app
USER node
EXPOSE 1337
CMD ["npm", "run", "start"]