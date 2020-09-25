# Sample Node.js application

This demo application is a single static web app. The application represents a warehouse asset management solution. The app is called **disper**.

![disper](disper.png)


The folder contains

- the source code for the node.js app (```/package.json``` and ```/server.js```)
- the content for the website (```/pages/```)
- a ```/Dockerfile``` to build the app container (and a .dockerignore to ensure only the relevant content from ```/``` is copied to the container)
- a ```/helm-chart/disper/``` folder that contains a sample helm chart for deploying the app.

## Run the app locally
Before you can run the app locally, ensure you have [**node.js**](https://nodejs.org/en/download/) installed. The node.js installation will also install **npm**, which we will need to download the packages for the app.

Clone the repository, switch to the ```/src/sample-apps/nodejs``` path of the local clone in a terminal and execute ```npm install```. 

Once the modules are donwloaded you can start the app by running ```node server.js``` from the same path in your terminal.

The app will be started and listening on http://localhost:8080. Opening that url in your browser will open the webpage.

## Build the container
Before you can build the container, ensure you have the [**docker engine**](https://docs.docker.com/install/) installed and running.

In a terminal, switch to the ```/src/sample-apps/nodejs``` path of the local repository clone and execute 

```
sudo docker build -t your_registry_name/disper . 
```

The . specifies that the build context is the current directory.

Once the image is build, you can run the container with

```
sudo docker run --name disper -p 80:8080 -d your_registry_name/disper 
```
If you now browse to port 80 of the IP address of the docker host you will get the webpage.

## Deploy to Kubernetes with Helm
Obviously this procedure requires access to a Kubernetes cluster. Additional you will need to have [Helm](https://helm.sh/docs/intro/install/) installed.

Before you deploy the Helm chart, ensure you update the ```/helm-chart/disper/values.yaml file``` to reflect your environment. In particular the ```.image.repsotiory``` and ```.ingress.hosts.host``` sections.

The procedure to install the Helm chart can be found [here](https://helm.sh/docs/helm/helm_install/)

