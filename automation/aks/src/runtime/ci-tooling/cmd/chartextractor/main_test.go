package main

import (
	"os"
	"path/filepath"
	"testing"
)

func TestMain(m *testing.M) {

	// call flag.Parse() here if TestMain uses flags
	os.Exit(m.Run())
}

type expectedApps struct {
	deploymentGroup string
	appName         string
	clusterName     string
}

func TestSingle2e2Testing(t *testing.T) {

	appPath := filepath.Join("testdata", "app_folder")
	clustersPath := filepath.Join("testdata", "cluster_folder")

	reender := ChartExtractor{
		ApplicationFolderPath: appPath,
		ClusterFolderPath:     clustersPath,
	}

	result := reender.renderAll()

	simpleCLusters := result["simple-webservice"]
	if len(simpleCLusters) != 3 {
		t.Fatalf("the number of clusters for the archetype was not correct expected:%d actual:%d ", 3, len(simpleCLusters))
	}

	complexCLusters := result["complex-webservice"]
	if len(complexCLusters) != 2 {
		t.Fatalf("the number of clusters for the archetype was not correct expected:%d actual:%d ", 2, len(complexCLusters))
	}
	t.Log(result)
}
