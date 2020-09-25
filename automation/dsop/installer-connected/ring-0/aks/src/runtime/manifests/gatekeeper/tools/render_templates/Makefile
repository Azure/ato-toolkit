SHELL:=/bin/bash
ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
# VERSION=$(shell git describe --long --tags)
VERSION=latest
APP_NAME=c12/gatekeeper-tooling

.PHONY: all
.DEFAULT: all

all: docker_build generate_crds

docker_build:
	docker build . -t $(APP_NAME):$(VERSION)

generate_crds:
	docker run -it --rm -v $(ROOT_DIR)/../../:/src/runtime/manifests/gatekeeper $(APP_NAME):$(VERSION)