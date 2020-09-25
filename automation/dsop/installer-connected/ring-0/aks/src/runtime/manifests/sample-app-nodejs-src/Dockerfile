FROM node:10-alpine

# Create app directory
WORKDIR /usr/src/app

# Install app dependencies
COPY package*.json ./

RUN npm install --no-package-lock

# Copy app source
COPY . .

EXPOSE 8080
CMD [ "node", "server.js" ]