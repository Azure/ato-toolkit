param (
    [string] $ResourceGroup = "demo-testing",
    [string] $ClusterName = "demoAKSCluster",
    [string] $Namespace = "elastic-system"
)
Write-Output ""
Write-Output "🎫 Getting the AKS credentials to cluster $ClusterName in resource group $ResourceGroup "
az aks get-credentials --resource-group $ResourceGroup --name $ClusterName | out-null

Write-Output ""
Write-Output "👩🏽‍💻 Applying the ECK operator"
kubectl apply -f eck.yaml

Write-Output ""
Write-Output "👀 Showing the ECK operator pod"
kubectl get pods -n $Namespace

Start-Sleep -Seconds 1
Write-Output ""
Write-Output "😬 Waiting for the ECK operator to complete"
kubectl wait --for=condition=Ready -n $Namespace pod/elastic-operator-0 --timeout=60s

Write-Output ""
Write-Output "👀 Showing the ECK operator pod"
kubectl get pods -n $Namespace
# this is needed if trying to pull straight from ironbank when that is ready
# Write-Output "Setting the secret to get the image from ironbank"
# kubectl create secret docker-registry regcred `
#     --docker-server=registry1.dsop.io `
#     --docker-username= `
#     --docker-password=

Write-Output ""
Write-Output "👨🏼‍💻 Applying elastic and kibana"
kubectl apply -f elastic-and-kibana.yaml -n $Namespace

Write-Output ""
Write-Output "😟 Waiting for the elastic and kibana containers to come up"

$Namespace="elastic-system"
do {
    $found = ""
    $kibanaPod = ( kubectl get pods -n $Namespace )
    foreach ($line in $kibanaPod) {
        if ($line.Contains("kibana"))
        {
            $found = $line
        }
    }
    Write-Output "☕️ 😕"
    Start-Sleep -Seconds 5
}
while (-not $found)

Write-Output ""
Write-Output "😲 Showing the elastic and kibana pods"
kubectl get pods -n $Namespace

Write-Output ""
Write-Output "🚀 ⭐️ 🚀 ⭐️ 🚀 ⭐️ 🚀 ⭐️ 🚀 ⭐️ 🚀 ⭐️ 🚀 ⭐️ 🚀"
Write-Output ""
