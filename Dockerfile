FROM node:18-alpine
WORKDIR /app
COPY package.json ./
RUN npm install --production
COPY . .
RUN mkdir -p /app/scripts
RUN mkdir -p /app/data
EXPOSE 3080
VOLUME ["/app/data"]
CMD ["node", "server.js"]
