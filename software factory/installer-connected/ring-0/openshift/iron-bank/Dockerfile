ARG BASE_REPO=ocpacr.azurecr.us/opensource/nodejs/nodejs
ARG BASE_TAG=12.16-development

FROM $BASE_REPO:$BASE_TAG

WORKDIR /usr/src/app

COPY ./helloAzureGov/package*.json ./

RUN npm install

COPY ./helloAzureGov .
EXPOSE 8080

ENTRYPOINT ["node", "./bin/www"]