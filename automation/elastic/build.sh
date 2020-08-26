az group create -n my-rg -l "usgovvirginia"

az aks create \
    --resource-group demo-testing \
    --name demoAKSCluster \
    --node-count 5 \
    --enable-addons monitoring \
    --generate-ssh-keys --vm-set-type AvailabilitySet

# az aks install-cli

az aks get-credentials --resource-group demo-testing --name demoAKSCluster

kubectl apply -f eck.yaml

kubectl wait --for=condition=Ready -n elastic-system pod/elastic-operator-0

kubectl create secret docker-registry regcred \
    --docker-server=registry1.dsop.io \
    --docker-username= \
    --docker-password=

kubectl apply -f elastic-and-kibana.yaml
