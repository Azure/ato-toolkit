#!/usr/bin/env bats


setup() {
  source src/runtime/pipelines/application-src/scripts/pre_build_checking.sh
}

@test "pre_build_checking > lint no args" {
  run lint
  [ "$status" -eq 1 ]
}

@test "pre_build_checking > lint 1 arg" {
  run lint terraform
  [ "$status" -eq 1 ]
}

@test "pre_build_checking > lint tf" {
  run lint -terraform12 tests/runtime/application-development-pipeline/scripts/test-files/k8s.tf
  [ "$status" -eq 0 ]
}

@test "pre_build_checking > lint YAML" {
  run lint "-rules tests/runtime/lint/config-lint/rules/yaml.yml" tests/runtime/application-development-pipeline/scripts/test-files/simple.yaml
  [ "$status" -eq 0 ]
}

@test "pre_build_checking > dependency_checks no args" {
  run dependency_checks
  [ "$status" -eq 1 ]
}

@test "pre_build_checking > dependency_checks full test scan" {
  IMAGE_DEPENDENCY_CHECK="test_c12.azurecr.io/dependency-check"
  run dependency_checks "."
  [ "$status" -eq 0 ]
}

@test "pre_build_checking > dependency_checks undefined IMAGE_DEPENDENCY_CHECK var fails" {
  unset IMAGE_DEPENDENCY_CHECK
  run dependency_checks "."
  [ "$status" -eq 1 ]
  [ "${lines[-1]}" = "IMAGE_DEPENDENCY_CHECK is not set" ]
}

@test "pre_build_checking > code_scanning no args" {
  run code_scanning
  [ "$status" -eq 1 ]
}

@test "pre_build_checking > code_scanning full test scan" {
  IMAGE_SONAR_SCANNER="test_c12.azurecr.io/sonar-scanner-cli"
  SONAR_HOST_URL=SONAR_HOST_URL
  SONAR_TOKEN=fa1895f6604fd860f32ef6e5f89c271378bafbc1
  run code_scanning "."
  [ "$status" -eq 0 ]
}

@test "pre_build_checking > code_scanning undefined SONAR_HOST_URL var fails" {
  unset SONAR_HOST_URL
  run code_scanning "."
  [ "$status" -eq 1 ]
  [ "${lines[-1]}" = "SONAR_HOST_URL is not set" ]
}

@test "pre_build_checking > code_scanning undefined SONAR_TOKEN var fails" {
  SONAR_HOST_URL=SONAR_HOST_URL
  unset SONAR_TOKEN
  run code_scanning "."
  [ "$status" -eq 1 ]
  [ "${lines[-1]}" = "SONAR_TOKEN is not set" ]
}

@test "pre_build_checking > code_scanning undefined IMAGE_SONAR_SCANNER var fails" {
  SONAR_HOST_URL=SONAR_HOST_URL
  SONAR_TOKEN=fa1895f6604fd860f32ef6e5f89c271378bafbc1
  unset IMAGE_SONAR_SCANNER
  run code_scanning "."
  [ "$status" -eq 1 ]
  [ "${lines[-1]}" = "IMAGE_SONAR_SCANNER is not set" ]
}

@test "pre_build_checking > compile no args" {
  run compile
  [ "$status" -eq 1 ]
}

@test "pre_build_checking > compile wrong arg" {
  run compile "hello"
  [ "$status" -eq 1 ]
  [ "${lines[-1]}" = "Unknown Compile step \'hello\'" ]
}

@test "pre_build_checking > compile correct arg" {
  run compile mvn
  [ "$status" -eq 0 ]
}

@test "pre_build_checking > unit_test no args" {
  run unit_test
  [ "$status" -eq 1 ]
}

@test "pre_build_checking > unit_test wrong arg" {
  run unit_test "hello"
  [ "$status" -eq 1 ]
  [ "${lines[-1]}" = "Unknown test step \'hello\'" ]
}

@test "pre_build_checking > unit_test correct arg" {
  run unit_test mvn
  [ "$status" -eq 0 ]
}

@test "pre_build_checking > integration_test no args" {
  run integration_test
  [ "$status" -eq 1 ]
}

@test "pre_build_checking > integration_test wrong arg" {
  run integration_test "hello"
  [ "$status" -eq 1 ]
  [ "${lines[-1]}" = "Unknown integration test step \'hello\'" ]
}

@test "pre_build_checking > integration_test correct arg" {
  run integration_test mvn
  [ "$status" -eq 0 ]
}