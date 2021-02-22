#!/usr/bin/env bats

setup() {
   source src/runtime/cluster-on-boarding/scripts/install_flux.sh
   source tests/runtime/logging_setup.sh
   # temporal until we create our own docker image with the package added. 
   # otherwise we can't run the unit test local
   apk add --no-cache gettext
}

@test "render_flux_helm_release fails on missing input" {
  run render_flux_helm_release 
  [ "$status" -eq 1 ]
  [[ $output == *"Required paramater not supplied"* ]]
}


@test "render_flux_helm_release renders the required fields" {
  run render_flux_helm_release arg1 arg2 arg3 arg4 arg5 arg6 arg7

  [ "$status" -eq 0 ]
  [[ $output == *"name: \"arg1-flux\""* ]]
  [[ $output == *"namespace: \"arg1\""* ]]
  [[ $output == *"releaseName: \"arg1-flux\""* ]]
  [[ $output == *"targetNamespace: \"arg1\""* ]]
  [[ $output == *"repository: \"arg2\""* ]]
  [[ $output == *"name: \"arg3\""* ]]
  [[ $output == *"version: \"arg4\""* ]]
  [[ $output == *"url: \"arg5\""* ]] 
  [[ $output == *"path: \"arg6\""* ]]
  [[ $output == *"repository: \"arg7\""* ]]
}


@test "install_flux fails if the ini file variable is not configured" {
  unset config_file
  run install_flux
  [ "$status" -eq 1 ]
  [[ $output == *"Configuration file argument not defined"* ]]
}