package utils

import (
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"path/filepath"
	"testing"
)

// LoadTestFile the content of test files
func LoadTestFile(name string) []byte {
	path := filepath.Join("testdata", name) // relative path
	bytes, err := ioutil.ReadFile(path)
	if err != nil {
		log.Fatal(err)
	}
	return bytes
}

// DeleteAllTestOutput Deletes all files from _outputfolder
func DeleteAllTestOutput() {
	dstPath := filepath.Join("testdata", "_output")

	files, err := ioutil.ReadDir(dstPath)
	if err != nil {
		log.Fatal(err)
	}

	for _, f := range files {
		if f.IsDir() {
			path := filepath.Join(dstPath, f.Name())
			if err = os.RemoveAll(path); err != nil {
				log.Fatalf("unable to delete test directory %s", err)
			}
		}

		fmt.Println(f.Name())
	}
}

// PrepareOutputFolder creates a folder for output the data of tests
func PrepareOutputFolder(t *testing.T) string {
	folderName := fmt.Sprintf("_output_%s", t.Name())
	dstPath := filepath.Join("testdata", folderName)

	if err := os.RemoveAll(dstPath); err != nil {
		log.Printf("Unable to delete test directory: %s", err)
	}

	err := os.MkdirAll(dstPath, 0777)
	if err != nil {
		log.Fatalf("Unable to create folder:%s", dstPath)
	}

	return dstPath

}

func DeleteOutputFolder(t *testing.T) {
	folderName := fmt.Sprintf("_output_%s", t.Name())
	dstPath := filepath.Join("testdata", folderName)

	if err := os.RemoveAll(dstPath); err != nil {
		log.Printf("Unable to delete test directory: %s", err)
	}
}
