# Iron Bank Verification Script

1. Ensure that you have the `.kube/config` file setup on your machine for deployment to your k8s cluster
2. Download the `nodejs-12.16` image and supporting files from the [iron bank](https://ironbank.dsop.io/) and place them into the ironbank folder. Files include:
   1. ironbank.asc
   2. manifest.json
   3. nodejs-12-16.tar
   4. signature.sig
3. Execute the `./build.sh` script
