#!/usr/bin/env bats


setup() {
  source src/runtime/pipelines/application-src/scripts/image_build.sh
}


@test "image_build > image_build > ACR_IMAGE_URL env variable not set" {
  unset ACR_IMAGE_URL
  export IMAGE_REPOSITORY_USERNAME=value
  export IMAGE_REPOSITORY_PASSWORD=value
  run image_build "arg1"
  [ "$status" -eq 1 ]
  [ "$output" = "Error: ACR_IMAGE_URL is not set" ]
}
@test "image_build > image_build > IMAGE_REPOSITORY_USERNAME env variable not set" {
  unset IMAGE_REPOSITORY_USERNAME
  export IMAGE_REPOSITORY_PASSWORD=value
  export ACR_IMAGE_URL=value
  run image_build "arg1"
  [ "$status" -eq 1 ]
  [ "$output" = "Error: IMAGE_REPOSITORY_USERNAME is not set" ]
}
@test "image_build > image_build > IMAGE_REPOSITORY_PASSWORD env variable not set" {
  unset IMAGE_REPOSITORY_PASSWORD
  export IMAGE_REPOSITORY_USERNAME=value
  export ACR_IMAGE_URL=value
  run image_build "arg1"
  [ "$status" -eq 1 ]
  [ "$output" = "Error: IMAGE_REPOSITORY_PASSWORD is not set" ]
}

# # Private func tests

@test "image_build > normalize > Caps in string" {
  export ACR_IMAGE_URL=test_c12.azurecr.io
  run normalize Test_c12.azurecr.io
  [ "$status" -eq 0 ]
  [ "$output" = "test_c12.azurecr.io" ]
}
@test "image_build > lowerize > Caps in string" {
  export ACR_IMAGE_URL=test_c12.azurecr.io
  run lowerize "Test/HELLO"
  [ "$status" -eq 0 ]
  [ "$output" = "test/hello" ]
}

# @test "image_build > find_dockerfiles > with dockerfile" {
#   export ACR_IMAGE_URL=test_c12.azurecr.io
#   run find_dockerfiles "tests/runtime/application-development-pipeline/scripts/test-files/Dockerfile"
#   [ "$status" -eq 0 ]
# }

# @test "image_build > find_dockerfiles > no dockerfile" {
#   export ACR_IMAGE_URL=test_c12.azurecr.io
#   run find_dockerfiles 
#   [ "$status" -eq 0 ]
# }

# @test "image_build > image_build > with dockerfile" {
#   export ACR_IMAGE_URL=test_c12.azurecr.io
#   run build_images "tests/runtime/application-development-pipeline/scripts/test-files/Dockerfile"
#   [ "$status" -eq 0 ]
# }

# @test "image_build > build_images > no dockerfile" {
#   export ACR_IMAGE_URL=test_c12.azurecr.io
#   run build_images 
#   [ "$status" -eq 0 ]
# }

# @test "image_build > build_images > with dockerfile" {
#   export ACR_IMAGE_URL=test_c12.azurecr.io
#   run build_images "tests/runtime/application-development-pipeline/scripts/test-files/Dockerfile"
#   [ "$status" -eq 0 ]
# }

# @test "image_build > build > no dockerfile" {
#   export ACR_IMAGE_URL=test_c12.azurecr.io
#   run build 
#   [ "$status" -eq 127 ]
# }

# @test "image_build > build_versions > with dockerfile" {
#   export ACR_IMAGE_URL=test_c12.azurecr.io
#   run build_images "tests/runtime/application-development-pipeline/scripts/test-files/Dockerfile"
#   [ "$status" -eq 0 ]
# }

# @test "image_build > build_versions > no dockerfile" {
#   export ACR_IMAGE_URL=test_c12.azurecr.io
#   run build_images 
#   [ "$status" -eq 0 ]
# }

# @test "image_build > normalize > empty" {
#   export ACR_IMAGE_URL=test_c12.azurecr.io
#   run normalize ""
#   [ "$status" -eq 0 ]
# }

# @test "image_build > normalize > Caps in string" {
#   export ACR_IMAGE_URL=test_c12.azurecr.io
#   run normalize Test_c12.azurecr.io
#   [ "$status" -eq 0 ]
#   [ "$output" = "test_c12.azurecr.io" ]
# }