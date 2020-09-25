package utils

import (
	"strings"
)

// GetNamespaceForApp returns the namespace for a c12 app
func GetNamespaceForApp(prefix, appName, deploymentGroup string) string {

	return strings.ToLower(prefix + "-" + appName + "-" + deploymentGroup)
}

// GetAdminNamespace returns the admin namespace of c12
func GetAdminNamespace(prefix string) string {
	return prefix + "-c12-system"
}
