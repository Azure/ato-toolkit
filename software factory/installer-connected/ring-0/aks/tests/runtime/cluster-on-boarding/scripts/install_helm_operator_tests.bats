#!/usr/bin/env bats

setup() {
   source src/runtime/cluster-on-boarding/scripts/install_helm_operator.sh
   source tests/runtime/logging_setup.sh
   
   # temporal until we create our own docker image with the package added. 
   # otherwise we can't run the unit test local
   apk add --no-cache gettext
}

@test "render_helm_repositories_template fails on missing input" {

  run render_helm_repositories_template arg1 
  [ "$status" -eq 1 ]
  [[ $output == *"input parameter not received"* ]]
}


@test "render_helm_repositories_template renders the required fields" {

  run render_helm_repositories_template arg1 arg2 arg3 arg4
  [ "$status" -eq 0 ]
  [[ $output == *"cache: arg1-index.yaml"* ]]
  [[ $output == *"name: \"arg1\""* ]]
  [[ $output == *"url: \"arg2\""* ]]
  [[ $output == *"username: \"arg3\""* ]]
  [[ $output == *"password: \"arg4\""* ]]
}

@test "install_helm_operator fails it the ini file variable is not configured" {
  unset arg_f
  run install_helm_operator
  [ "$status" -eq 1 ]
  [[ $output == *"Configuration file argument not defined"* ]]
}