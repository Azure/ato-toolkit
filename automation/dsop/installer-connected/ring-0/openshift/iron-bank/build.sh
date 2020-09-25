#!/bin/bash
BASE_PATH=./ironbank
BASE_IMAGE_ARCHIVE=$BASE_PATH/nodejs-12.16.tar
BASE_REPO_SERVER=ocpacr.azurecr.us
BASE_REPO_SERVER_USERNAME=[YOUR USERNAME]
BASE_REPO_SERVER_PASSWORD=[YOUR PASSWORD]
BASE_REPO=$BASE_REPO_SERVER/ironbank/opensource/nodejs/nodejs
BASE_TAG=12.16-development
APPLICATION_IMAGE=$BASE_REPO_SERVER/demo/hello-azure-gov:dev
APPLICATION_K8S_NAMESPACE=azure-gov-demo

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
HEADER=''
NC='\033[0m' # No Color

echo -e "\n\n${HEADER}Importing Iron Bank public key${NC}"
echo -e "----------------------------------------------------\n"
gpg --import $BASE_PATH/ironbank.asc


echo -e "\n\n${HEADER}Checking manifest using Iron Bank signature${NC}"
echo -e "----------------------------------------------------"

gpg --verify $BASE_PATH/signature.sig $BASE_PATH/manifest.json

echo -e  "\n\n${HEADER}Getting image checksum${NC}"
echo -e  "----------------------------------------------------"
EXPECTED_IMAGE_256_CHECKSUM=$(jq -r '.critical.image["image-tar-sha256-checksum"]' $BASE_PATH/manifest.json)
echo -e "Expected checksum is: " ${BLUE}${EXPECTED_IMAGE_256_CHECKSUM}${NC}
echo -e "Comparing against .tar file..."
ACTUAL_IMAGE_256_CHECKSUM=$(sha256sum $BASE_PATH/nodejs-12.16.tar)
echo -e "Actual checksum is:   " ${BLUE}${ACTUAL_IMAGE_256_CHECKSUM}${NC}
docker run -ti --rm mpepping/ponysay --colour "1;35" --pony spike checksums match!!
read

echo -e  "\n\n${HEADER}Loading, tagging, and pushing image${NC}"
echo -e  "----------------------------------------------------"
LOADED_IMAGE="$(docker load -i $BASE_IMAGE_ARCHIVE | awk '{print $3}')"
echo -e "Loaded image:" $LOADED_IMAGE
TARGET_IMAGE="${LOADED_IMAGE/localhost/$BASE_REPO_SERVER}"
echo -e "Target image:" ${GREEN} $TARGET_IMAGE ${NC}
echo -e "${BLUE}Retagging...${NC}"
docker tag $LOADED_IMAGE $TARGET_IMAGE
echo -e "${BLUE}Pushing " $TARGET_IMAGE ${NC}
docker push $TARGET_IMAGE
echo -e "${GREEN}Completed base image push!${NC}"


echo -e  "\n\n${HEADER}Build and push application image${NC}"
echo -e  "----------------------------------------------------"
echo -e "${BLUE}Building image...${NC}"
docker build -t $APPLICATION_IMAGE . >> /dev/null
echo -e ""
echo -e "${BLUE}Pushing image...${NC}"
docker push $APPLICATION_IMAGE
echo -e "${GREEN}Completed application image push!${NC}"

echo -e  "\n\n${HEADER}Deploy application image${NC}"
echo -e  "----------------------------------------------------"
kubectl create namespace $APPLICATION_K8S_NAMESPACE
kubectl create secret docker-registry ocpacr --docker-server=$BASE_REPO_SERVER --docker-username=$BASE_REPO_SERVER_USERNAME --docker-password=$BASE_REPO_SERVER_PASSWORD -n $APPLICATION_K8S_NAMESPACE

APPLICATION_IMAGE_HASH=$(docker inspect ${APPLICATION_IMAGE} | jq -r '.[0].RepoDigests[0]')
echo -e "${BLUE}Using Helm to deploy image with digest hash: ${APPLICATION_IMAGE_HASH##*@}${NC}"
helm install -n ${APPLICATION_K8S_NAMESPACE} hello-azure-gov ./charts/helloAzureGov --set image.sha=${APPLICATION_IMAGE_HASH##*@} --wait

sleep 5

echo -e  "\n\nPods${NC}"
echo -e  "----------------------------------------------------"
kubectl get pods -n $APPLICATION_K8S_NAMESPACE

echo -e  ""
docker run -ti --rm mpepping/ponysay --colour "0;32" --pony gummy Application ready: https://website.$APPLICATION_K8S_NAMESPACE.cloudfitdsop.com/
