FROM node:alpine
RUN mkdir /app
WORKDIR /app

COPY package.json /app/package.json
RUN npm install --production

COPY index.js /app/index.js
EXPOSE 8080

CMD npm start
