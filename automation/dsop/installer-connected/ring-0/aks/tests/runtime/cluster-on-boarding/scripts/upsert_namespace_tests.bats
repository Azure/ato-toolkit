#!/usr/bin/env bats

setup() {
   source src/runtime/cluster-on-boarding/scripts/upsert_namespace.sh
   source tests/runtime/logging_setup.sh
}

@test "undefined_admin_namespace_var_fails" {
  run upsert_namespace
  [ "$status" -eq 1 ]
  [[ "$output" == *"Missing input parameters"* ]]
}
