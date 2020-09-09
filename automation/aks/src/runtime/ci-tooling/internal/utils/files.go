package utils

import (
	"errors"
	"log"
	"os"
	"path/filepath"
)

// EnsurePathIsADir Returns the os.FileInfo for the directory or exists printing the error
func EnsurePathIsADir(path string) os.FileInfo {

	if dir, err := os.Stat(path); err != nil {
		CheckErrorOrDie(err)
	} else if !dir.IsDir() {
		CheckErrorOrDie(errors.New("the provided path \"" + path + "\" is not a directory"))
	} else {
		return dir
	}

	return nil
}

// FileExists checks if a file exists and is not a directory before we
func FileExists(filename string) bool {
	info, err := os.Stat(filename)
	if os.IsNotExist(err) {
		log.Printf("Debug: file doesn't exists %v", err)
		return false
	}
	return !info.IsDir()
}

// FileIsYaml checks if a file is yml or yaml
func FileIsYaml(filename string) bool {
	extension := filepath.Ext(filename)
	exts := []string{".yml", ".yaml"}
	for _, s := range exts {
		if s == extension {
			return true
		}
	}
	log.Printf("Debug: file not yaml %v", extension)
	return false
}
