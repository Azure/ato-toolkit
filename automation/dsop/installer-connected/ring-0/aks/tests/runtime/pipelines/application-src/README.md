# Testing Application development pipeline

## Unit tests

- Shell unit tests are currently tested through [BATS](https://github.com/bats-core/bats-core); to Aint in demonstrating the major Functionality of our features main cases.

## Code Code Linting

- Shell scripts are tested through [ShellCheck](https://github.com/koalaman/shellcheck).
- Terraform Configuration Code if tested through [Config-Lint](https://github.com/stelligent/config-lint).
  >_NOTE:_ [Config-Lint](https://github.com/stelligent/config-lint) can also set custom rules for K8S and YAML, and possibly our own Yaml configs in the future.

## CI Pipeline

- Dev Testing pipeline tests all the above checks in an automated pipeline here, which is trigged with every git `push` upstream.
