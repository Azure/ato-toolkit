#!/usr/bin/env bats

setup() {
  source src/runtime/cluster-on-boarding/scripts/import_images.sh
  source tests/runtime/logging_setup.sh
}

@test "to_full_qualified_image_name no input should fail" {
  run to_full_qualified_image_name
  [ "$status" -eq 1 ]
  [[ "$output" == *"input parameter not received"* ]]
}

@test "to_full_qualified_image_name library image should be converted" {
  run to_full_qualified_image_name memcached
  [ "$status" -eq 0 ]
  [ "$output" = "docker.io/library/memcached" ]
}

@test "to_full_qualified_image_name non library image should be prepend docker.io" {
  run to_full_qualified_image_name homeassistant/home-assistant
  [ "$status" -eq 0 ]
  [ "$output" = "docker.io/homeassistant/home-assistant" ]
}

@test "to_full_qualified_image_name non library image with full name should not be modified" {
  run to_full_qualified_image_name docker.io/homeassistant/home-assistant
  [ "$status" -eq 0 ]
  [ "$output" = "docker.io/homeassistant/home-assistant" ]
}

@test "to_full_qualified_image_name non docker hub images must remain unchanged" {
  run to_full_qualified_image_name mcr.microsoft.com/dotnet/core/samples
  [ "$status" -eq 0 ]
  [ "$output" = "mcr.microsoft.com/dotnet/core/samples" ]
}

@test "strip_tag missing arg fails" {
  run strip_tag
  [ "$status" -eq 1 ]
  [[ "$output" == *"input parameter not received"* ]]

}

@test "strip_tag adds latest on missing tag" {
  run strip_tag mcr.microsoft.com/dotnet/core/samples
  [ "$status" -eq 0 ]
  [ "$output" = "mcr.microsoft.com/dotnet/core/samples" ]
}

@test "strip_tag removes image with text tag" {
  run strip_tag mcr.microsoft.com/dotnet/core/samples:latest
  [ "$status" -eq 0 ]
  [ "$output" = "mcr.microsoft.com/dotnet/core/samples" ]
}

@test "strip_tag removes image with numeric tag" {
  run strip_tag mcr.microsoft.com/dotnet/core/samples:1.4.5.6
  [ "$status" -eq 0 ]
  [ "$output" = "mcr.microsoft.com/dotnet/core/samples" ]
}

@test "get_image_tag missing arg fails" {
  run get_image_tag
  [ "$status" -eq 1 ]
  [[ "$output" == *"input parameter not received"* ]]

}

@test "get_image_tag adds latest on missing tag" {
  run get_image_tag mcr.microsoft.com/dotnet/core/samples
  [ "$status" -eq 0 ]
  [ "$output" = "latest" ]
}

@test "get_image_tag gets named tag" {
  run get_image_tag mcr.microsoft.com/dotnet/core/samples:latest
  [ "$status" -eq 0 ]
  [ "$output" = "latest" ]
}

@test "get_image_tag gets numeric tag" {
  run get_image_tag mcr.microsoft.com/dotnet/core/samples:1.4.5.6
  [ "$status" -eq 0 ]
  [ "$output" = "1.4.5.6" ]
}

@test "import_image fails on missing arg" {
  run get_image_tag 
  [ "$status" -eq 1 ]
}


@test "rewrite_full_qualified_image_name fails on missing args" {
    run rewrite_full_qualified_image_name
    [ "$status" -eq 1 ]
    [[ "$output" == *"input parameter not received"* ]]

}


@test "rewrite_full_qualified_image_name renames correctly a full qualified image name" {
  run rewrite_full_qualified_image_name "docker.io/library/memcached" "testacr.azure.com"
  [ "$status" -eq 0 ]
  [[ "$output" == "testacr.azure.com/library/memcached" ]]
}
