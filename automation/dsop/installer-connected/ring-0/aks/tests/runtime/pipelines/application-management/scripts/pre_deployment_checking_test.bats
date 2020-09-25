#!/usr/bin/env bats

setup() {
    source src/runtime/pipelines/application-management/scripts/pre_deployment_checking.sh
}

@test "lint no args" {
  run lint
  [ "$status" -eq 1 ]
}

@test "lint 1 arg" {
  run lint terraform
  [ "$status" -eq 1 ]
}

@test "lint tf" {
  run lint -terraform12 test-files/k8s.tf
  [ "$status" -eq 0 ]
}
