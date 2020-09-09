
#!/usr/bin/env bats

setup() {
   source src/runtime/cluster-on-boarding/scripts/import_helm_chart_to_acr.sh
   source tests/runtime/logging_setup.sh
}

@test "import_chart missing args fail" {
  run import_chart_acr
  [ "$status" -eq 1 ]
  [[ $output == *"Missing input parameters"* ]] 
}
