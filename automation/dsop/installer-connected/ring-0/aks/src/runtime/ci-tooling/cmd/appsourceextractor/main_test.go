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

func TestSingle2e2Testing(t *testing.T) {

	appPath := filepath.Join("testdata", "app_folder")

	reender := SourceExtractor{
		ApplicationFolderPath: appPath,
	}

	result := reender.renderAll()

	if len(result) != 2 {
		t.Fatalf("The number of apps expected was:%d got:%d", 2, len(result))
	}
}
