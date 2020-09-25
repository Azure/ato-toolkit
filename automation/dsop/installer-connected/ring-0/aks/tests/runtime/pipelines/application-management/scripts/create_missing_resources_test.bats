#!/usr/bin/env bats

setup() {
    source src/runtime/pipelines/application-management/scripts/create_missing_resources.sh
}

@test "copy_container_acr > SP_APP_ID env variable not set" {
  unset SP_APP_ID
  export SP_APP_PASSWORD=value
  run copy_container_acr arg1 arg2 arg3 arg4
  [ "$status" -eq 1 ]
  [ "$output" = "Error: SP_APP_ID is not set" ]
}

@test "copy_container_acr > SP_APP_PASSWORD env variable not set" {
  export SP_APP_ID=value
  unset SP_APP_PASSWORD
  run copy_container_acr arg1 arg2 arg3 arg4
  [ "$status" -eq 1 ]
  [ "$output" = "Error: SP_APP_PASSWORD is not set" ]
}

@test "copy_container_acr > Run the function without any arguments" {
    run copy_container_acr arg1
    [ "$status" -eq 1 ]
    [ "$output" = "Error: Expecting 4 arguments for this function" ]
}