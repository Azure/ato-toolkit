package main

import (
	"fmt"
	"os"
	"path/filepath"
	"testing"

	"github.com/Azure/ato-toolkit/automation/aks/src/runtime/ci-tooling/internal/helmreleasev1"
	"github.com/Azure/ato-toolkit/automation/aks/src/runtime/ci-tooling/internal/utils"
)

func TestMain(m *testing.M) {
	utils.DeleteAllTestOutput()
	// call flag.Parse() here if TestMain uses flags
	os.Exit(m.Run())
}

type expectedApps struct {
	deploymentGroup string
	appName         string
	clusterName     string
	expected        bool
}

func TestSingle2e2Testing(t *testing.T) {

	dstPath := utils.PrepareOutputFolder(t)
	defer utils.DeleteOutputFolder(t)

	appPath := filepath.Join("testdata", "app-test.yaml")
	clustersPath := filepath.Join("testdata", "cluster_folder")

	reender := AppYamlRenderer{
		ApplicationYamlPath: appPath,
		OutputPath:          dstPath,
		ClusterFolderPath:   clustersPath,
		InstallationPrefix:  "testprefix",
	}

	renderErr := reender.renderAll()
	if renderErr != nil {
		t.Fatalf("Rendering the Helm release failed %s", renderErr)
	}

	expected := []expectedApps{
		{
			deploymentGroup: "dev",
			appName:         "testapp",
			clusterName:     "contoso-northeurope-0001",
			expected:        true,
		},
		{
			deploymentGroup: "production",
			appName:         "testapp",
			clusterName:     "contoso-northeurope-0002",
			expected:        true,
		},
		{
			deploymentGroup: "production",
			appName:         "testapp",
			clusterName:     "contoso-westus-0003",
			expected:        true,
		},
	}
	assertRenderedHelmRelease(t, dstPath, expected)
	assertRenderedRoleBindings(t, dstPath, expected)

}

func TestImageNameAndVersionAreGenerated(t *testing.T) {
	dstPath := utils.PrepareOutputFolder(t)
	defer utils.DeleteOutputFolder(t)

	appPath := filepath.Join("testdata", "app-test.yaml")
	clustersPath := filepath.Join("testdata", "cluster_folder")

	reender := AppYamlRenderer{
		ApplicationYamlPath: appPath,
		OutputPath:          dstPath,
		ClusterFolderPath:   clustersPath,
		InstallationPrefix:  "testprefix",
		GithubOrganization:	 "gotest",
	}

	renderErr := reender.renderAll()
	if renderErr != nil {
		t.Fatalf("Rendering the Helm release failed %s", renderErr)
	}

	expectedFileName := fmt.Sprintf("%s-%s-%s-app-helmrelease.yaml", "testapp", "dev","contoso-northeurope-0001")
	expectedFile := filepath.Join(dstPath, "contoso-northeurope-0001", expectedFileName)

	release := helmreleasev1.GetHelmRelease(expectedFile)
	imageSpec := release.Spec.Values["image"].(map[string]interface{})
	repo:= imageSpec["repository"]
	version:= imageSpec["version"]
	repoExpected := "contosonortheurope0001.azurecr.io/gotest/testprefix-testapp-src"
	versionExpected := "9.0.1-0-30d454a2"

	
	if  repo != repoExpected {
		t.Errorf("Repository value:%s expected %s", repo, repoExpected)
		t.Fail()
	}
	if  version != versionExpected {
		t.Errorf("Version value:%s expected %s", version, versionExpected)
		t.Fail()
	}
}


func TestNullAppDoesNotRender(t *testing.T) {

	dstPath := utils.PrepareOutputFolder(t)
	defer utils.DeleteOutputFolder(t)
	appPath := filepath.Join("testdata", "app-test-without-version.yaml")
	clustersPath := filepath.Join("testdata", "cluster_folder")

	reender := AppYamlRenderer{
		ApplicationYamlPath: appPath,
		OutputPath:          dstPath,
		ClusterFolderPath:   clustersPath,
		InstallationPrefix:  "testprefix",
		GithubOrganization:	 "gotest",
	}

	renderErr := reender.renderAll()
	if renderErr != nil {
		t.Fatalf("Rendering the Helm release failed %s", renderErr)
	}

	expected := []expectedApps{
		{
			deploymentGroup: "dev",
			appName:         "testapp",
			clusterName:     "contoso-northeurope-0001",
			expected:        false,
		},
		{
			deploymentGroup: "production",
			appName:         "testapp",
			clusterName:     "contoso-northeurope-0002",
			expected:        false,
		},
		{
			deploymentGroup: "production",
			appName:         "testapp",
			clusterName:     "contoso-westus-0003",
			expected:        false,
		},
	}

	assertRenderedHelmRelease(t, dstPath, expected)
	assertRenderedRoleBindings(t, dstPath, expected)

}

func TestComplexDictionaryIsRendered(t *testing.T) {

	dstPath := utils.PrepareOutputFolder(t)
	defer utils.DeleteOutputFolder(t)
	appPath := filepath.Join("testdata", "app-test-complex-dict.yaml")
	clustersPath := filepath.Join("testdata", "cluster_folder")

	reender := AppYamlRenderer{
		ApplicationYamlPath: appPath,
		OutputPath:          dstPath,
		ClusterFolderPath:   clustersPath,
		InstallationPrefix:  "testprefix",
		GithubOrganization:	 "gotest",
	}

	renderErr := reender.renderAll()
	if renderErr != nil {
		t.Errorf("Rendering the Helm release failed %s", renderErr)
		t.Fail()
	}

	expected := []expectedApps{
		{
			deploymentGroup: "dev",
			appName:         "testapp",
			clusterName:     "contoso-northeurope-0001",
			expected:        true,
		},
		{
			deploymentGroup: "production",
			appName:         "testapp",
			clusterName:     "contoso-northeurope-0002",
			expected:        true,
		},
		{
			deploymentGroup: "production",
			appName:         "testapp",
			clusterName:     "contoso-westus-0003",
			expected:        true,
		},
	}
	assertRenderedHelmRelease(t, dstPath, expected)
	assertRenderedRoleBindings(t, dstPath, expected)
}

func assertRenderedHelmRelease(t *testing.T, dstPath string, expected []expectedApps) {

	for _, ex := range expected {
		expectedFileName := fmt.Sprintf("%s-%s-%s-app-helmrelease.yaml", ex.appName, ex.deploymentGroup, ex.clusterName)
		expectedFile := filepath.Join(dstPath, ex.clusterName, expectedFileName)

		file_found := true
		if _, err := os.Stat(expectedFile); err != nil {
			file_found = false
		}

		if file_found != ex.expected {
			t.Errorf("Helm Release %s expected:%t found:%t", expectedFile, ex.expected, file_found)
		}

		if ex.expected {
			generated := helmreleasev1.GetHelmRelease(expectedFile)
			if generated.Kind != "HelmRelease" {
				t.Error("The field of Kind in the helm release is not HelmRelease (and it should be)")
			}
		}
	}
}

func assertRenderedRoleBindings(t *testing.T, dstPath string, expected []expectedApps) {

	for _, ex := range expected {
		for role, _ := range roles {

			expectedFileName := fmt.Sprintf("%s-%s-%s-role-binding.yaml", ex.appName, ex.deploymentGroup, role)
			expectedFile := filepath.Join(dstPath, ex.clusterName, expectedFileName)

			file_found := true
			if _, err := os.Stat(expectedFile); err != nil {
				file_found = false
			}

			if file_found != ex.expected {
				t.Errorf("RoleBinding:%s expected:%t found:%t", expectedFile, ex.expected, file_found)
			}
		}
	}
}
