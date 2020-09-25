
Add-Type -TypeDefinition @"
public enum DeploymentType {
    DisconnectedLite = 1,
    DisconnectedStack = 2,
    Connected = 3,
    Disconnected = 4
}
"@