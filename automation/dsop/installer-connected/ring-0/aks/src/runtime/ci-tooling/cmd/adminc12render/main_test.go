package main

import (
	"fmt"
	"os"
	"path/filepath"
	"testing"

	"github.com/Azure/ato-toolkit/automation/aks/src/runtime/ci-tooling/internal/helmreleasev1"
	"github.com/Azure/ato-toolkit/automation/aks/src/runtime/ci-tooling/internal/utils"
)

var testprefix = "testprefix"
var testgithuborg = "testorg"
var dummySshKey = `cat id_rsa
-----BEGIN OPENSSH PRIVATE KEY-----
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
-----END OPENSSH PRIVATE KEY-----`

func TestMain(m *testing.M) {

	utils.DeleteAllTestOutput()
	// call flag.Parse() here if TestMain uses flags
	os.Exit(m.Run())
}

type expectedApps struct {
	deploymentGroup string
	appName         string
	clusterName     string
}

func TestSingle2e2Testing(t *testing.T) {

	dstPath := filepath.Join("testdata", "_output")
	appPath := filepath.Join("testdata", "app-test.yaml")
	clustersPath := filepath.Join("testdata", "cluster_folder")

	reender := AppYamlRenderer{
		ApplicationYamlPath: appPath,
		OutputPath:          dstPath,
		ClusterFolderPath:   clustersPath,
		InstallationPrefix:  testprefix,
		GithubOrganization:  testgithuborg,
		SshKey:				 dummySshKey,
	}

	renderErr := reender.renderAll()
	if renderErr != nil {
		t.Fatalf("Rendering the Helm release failed %s", renderErr)
	}

	expected := []expectedApps{
		{
			deploymentGroup: "dev",
			appName:         "testapp",
			clusterName:     "testprefix-testcluster-0001",
		},
	}
	assertRenderedFile(t, dstPath, testprefix, expected)

}

func assertRenderedFile(t *testing.T, dstPath string, prefix string, expected []expectedApps) {

	for _, ex := range expected {
		expectedFileNameHelm := fmt.Sprintf("%s-%s-%s-flux-helm-release.yaml", testprefix, ex.appName, ex.deploymentGroup)
		expectedFilePathHelm := filepath.Join(dstPath, ex.clusterName, expectedFileNameHelm)

		if _, err := os.Stat(expectedFilePathHelm); err != nil {
			t.Errorf("File was not generated %s", expectedFilePathHelm)
		}

		generated := helmreleasev1.GetHelmRelease(expectedFilePathHelm)

		if generated.Kind != "HelmRelease" {
			t.Error("The field of Kind in the helm release is not HelmRelease (and it should be)")
		}

		expectedFileNameNamespace := fmt.Sprintf("%s-%s-%s-namespace.yaml", testprefix, ex.appName, ex.deploymentGroup)
		expectedFilePathNamespace := filepath.Join(dstPath, ex.clusterName, expectedFileNameNamespace)

		if _, err := os.Stat(expectedFilePathNamespace); err != nil {
			t.Errorf("File was not generated %s", expectedFilePathNamespace)
		}

		expectedFluxSshKey := fmt.Sprintf("%s-%s-%s-flux-ssh-key-secret.yaml", testprefix, ex.appName, ex.deploymentGroup)
		expectedFluxSshKeyPath := filepath.Join(dstPath, ex.clusterName, expectedFluxSshKey)

		if _, err := os.Stat(expectedFluxSshKeyPath); err != nil {
			t.Errorf("File was not generated %s", expectedFluxSshKeyPath)
		}
	}
}

func TestCanGenerateNamespace(t *testing.T) {
	_, err := renderNamespaceObject("test")

	if err != nil {
		t.Fatalf("File was not generated")
	}
}
