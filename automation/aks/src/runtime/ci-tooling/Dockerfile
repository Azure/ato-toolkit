# Start from the latest golang base image
FROM golang:1.14.1-stretch as builder

# Add Maintainer Info
LABEL maintainer="C12"

# Set the Current Working Directory inside the container
WORKDIR /build

# Build the Go app
RUN mkdir bin 

# Copy go mod and sum files
COPY . .

RUN make

# Final image with just the binaries, for some reason that I haven't gone deep alpine does not run the binary.
FROM debian:stretch

RUN apt-get update && apt-get install -y --no-install-recommends jq git tree curl ca-certificates apt-transport-https lsb-release python3-pip python3-setuptools python3-yaml && rm -rf /var/lib/apt/lists/*
RUN pip3 install yq
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash && rm -rf /var/lib/apt/lists/*
RUN curl https://releases.hashicorp.com/terraform/0.12.24/terraform_0.12.24_linux_amd64.zip --output - | gunzip > /usr/local/bin/terraform && chmod +x /usr/local/bin/terraform
RUN curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

#Enable github volumes to be mounted. 
VOLUME [ "/github/workspace" ]
VOLUME [ "/github/workflow" ]

WORKDIR /app

COPY --from=builder /build/bin /app