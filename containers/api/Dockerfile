FROM node:18-alpine

WORKDIR /app
COPY package.json .
RUN npm install

COPY app.js .

EXPOSE 3000
RUN apk add --no-cache curl
CMD ["npm", "start"]
