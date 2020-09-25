#!/usr/bin/env bats

setup() {
   source src/runtime/cluster-on-boarding/scripts/create_cluster_folder_git.sh
   source tests/runtime/logging_setup.sh
}

@test "fails invokation with no args" {
  run create_folder_for_state_repo
  [ "$status" -eq 1 ]
  [[ "$output" == *"Expecting 2 arguments for this function" ]]
}
