#!/usr/bin/env bats


setup() {
   source src/runtime/pipelines/application-src/scripts/image_publishing.sh
}


@test "image_publishing > IMAGE_REPOSITORY_USERNAME env variable not set" {
  unset IMAGE_REPOSITORY_USERNAME
  export IMAGE_REPOSITORY_PASSWORD=value
  run image_publishing arg1 arg2
  [ "$status" -eq 1 ]
  [ "$output" = "Error: IMAGE_REPOSITORY_USERNAME is not set" ]
}

@test "image_publishing > IMAGE_REPOSITORY_PASSWORD env variable not set" {
  export IMAGE_REPOSITORY_USERNAME=value
  unset IMAGE_REPOSITORY_PASSWORD
  run image_publishing arg1 arg2 
  [ "$status" -eq 1 ]
  [ "$output" = "Error: IMAGE_REPOSITORY_PASSWORD is not set" ]
}

@test "image_publishing > Run the function without any arguments" {
    run image_publishing 
    [ "$status" -eq 1 ]
    [ "$output" = "Error: Expecting 2 arguments for this function" ]
}

@test "image_publishing > Run the function with too many arguments" {
    run image_publishing arg1 arg2 arg3
    [ "$status" -eq 1 ]
    [ "$output" = "Error: Expecting 2 arguments for this function" ]
}

