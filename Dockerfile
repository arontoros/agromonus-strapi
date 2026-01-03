FROM node:20

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .

# DON'T BUILD - use pre-built admin
# Admin panel will auto-build on first start in production

EXPOSE 1337

CMD ["npm", "start"]