#!/usr/bin/env bash
# -*- coding: utf-8 -*-


function lint() {
    echo "lint app.yaml files"
  if [ "$1" ] && [ "$2" ]
  then
    docker run --mount src="$(pwd)",target=/mount-dir,type=bind stelligent/config-lint "$1" "$2"
    return 0
  else
    echo "No args.."
    echo "The program can also read files from a separate YAML file, and can scan these types of files:"
    return 1
  fi
}

function compile () {
  echo "compile Example" 
  case "$1" in
  "mvn")
      info "mvn clean install"
      exit 0
      ;;
  "go" | "gobuild")
      info "go build"
      exit 0
      ;;
  *)
      echo "Unknown Compile step \'$1\'"
      exit 1
      ;;
  esac
}

function unit_test () {
  echo "Unit Test Example" 
  case "$1" in
  "mvn")
      info "mvn test-DskipITs=true"
      exit 0
      ;;
  "go" | "gotest")
      info "go test"
      exit 0
      ;;
  *)
      echo "Unknown test step \'$1\'"
      exit 1
      ;;
  esac
}

function integration_test () {
  echo "Integration Test Example" 
  case "$1" in
  "mvn")
      info "mvn test -DskipITs=false"
      exit 0
      ;;
  "go" | "gotest")
      info "go test -run 'Integration'"
      exit 0
      ;;
  *)
      echo "Unknown integration test step \'$1\'"
      exit 1
      ;;
  esac
}

function code_scanning () {
  echo "code_scanning" 

  if [ -z "$SONAR_HOST_URL" ] 
	then
	  echo "SONAR_HOST_URL is not set"
	  exit 1
	fi

  if [ -z "$SONAR_TOKEN" ] 
	then
		echo "SONAR_TOKEN is not set"
		exit 1
	fi

  if [ -z "$IMAGE_SONAR_SCANNER" ] 
	then
		echo "IMAGE_SONAR_SCANNER is not set"
		exit 1
	fi

  if [ "$1" ]
  then
    docker run -e SONAR_HOST_URL="$SONAR_HOST_URL" -e SONAR_TOKEN="$SONAR_TOKEN" -e SONAR_PROJECT_BASE_DIR="$1" --user="$(id -u):$(id -g)" -it -v "$(PWD):/src" "$IMAGE_SONAR_SCANNER"
    return 0
  else
    echo "No args.."
    echo "The program can scan code with sonar-scanner-cli to a sonarqube instance specified, required Argument scanning dir path."
    return 1
  fi    
}

function dependency_checks () {
  echo "dependency_checks"

  if [ -z "$IMAGE_DEPENDENCY_CHECK" ] 
	  then
		  echo "IMAGE_DEPENDENCY_CHECK is not set"
		  exit 1
	fi

  if [ "$1" ]
  then
    docker run --rm --volume "$(pwd)":/src "$IMAGE_DEPENDENCY_CHECK" --scan "$1" --format "ALL" --out "$(pwd)/reports/dependency_checks/"
    echo "Reports Location: '$(pwd)'/reports/dependency_checks/"
    return 0
  else
    echo "No args.."
    echo "The program can scan code and dependency for OSWAP known vulnerabilities, required Arugment scanning dir path."
    return 1
  fi
}
