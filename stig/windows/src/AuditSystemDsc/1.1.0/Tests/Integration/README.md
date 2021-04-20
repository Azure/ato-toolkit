# Integration tests

For it to be easier to write integration tests for a resource that depends on
other resources, this will list the run order of the integration tests that keep
their configuration on the AppVeyor build worker.

If an integration test should use one or more of these previous integration test
configurations then the run order for the new integration tests should be set to
a higher run order number than the highest run order of the dependent integration
tests.

## AuditSetting

**Run order:** 1

**Depends on:** None

This integration tests will not leave any resources on the build worker.
