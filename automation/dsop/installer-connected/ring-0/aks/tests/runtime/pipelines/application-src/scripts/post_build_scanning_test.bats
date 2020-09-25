#!/usr/bin/env bats

# load test_helper

setup() {
  # export TEST_TEMP_DIR=`dirname $(mktemp -u)`
  # export YAML_PATH="${TEST_TEMP_DIR}/test.yaml"
  # export WORKDIR_PATH="${TEST_TEMP_DIR}/workdir"
  
  source src/runtime/pipelines/application-src/scripts/post_build_scanning.sh
}

