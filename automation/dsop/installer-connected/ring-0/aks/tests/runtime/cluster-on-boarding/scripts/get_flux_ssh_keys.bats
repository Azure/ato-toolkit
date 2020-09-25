#!/usr/bin/env bats

setup() {
   source src/runtime/cluster-on-boarding/scripts/get_flux_ssh_keys.sh
   source tests/runtime/logging_setup.sh
}

@test "get_flux_ssh_keys fails without arguments" {
  run get_flux_ssh_keys
  [ "$status" -eq 1 ]
  [[ "$output" == *"Expecting 2 arguments for this function"* ]]
}
