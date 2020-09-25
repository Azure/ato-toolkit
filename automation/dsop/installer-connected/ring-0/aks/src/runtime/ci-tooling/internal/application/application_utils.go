package application

import (
	"io/ioutil"
	"path/filepath"

	"github.com/Azure/ato-toolkit/automation/aks/src/runtime/ci-tooling/internal/utils"
)

// GetAppFromFile reads a file with an application defined in Yaml and returns a
// Pointer to it.
func GetAppFromFile(path string) *ApplicationConfig {

	dat, err := ioutil.ReadFile(path)
	utils.CheckErrorOrDie(err)

	marshaller := MapperYaml{}
	app, err := marshaller.Unmarshall(dat)
	utils.CheckErrorOrDie(err)

	return app
}

// GetAllAppsInfolder Reads all yaml files in a folder and returns a map
// using the App name as key of the map and the Application read as a the associated value
func GetAllAppsInfolder(path string) (error, map[string]ApplicationConfig) {

	res := map[string]ApplicationConfig{}
	files, err := ioutil.ReadDir(path)

	if err != nil {
		return err, nil
	}

	for _, file := range files {
		filePath := filepath.Join(path, file.Name())

		if utils.FileExists(filePath) {
			if utils.FileIsYaml(filePath) {
				dat, err := ioutil.ReadFile(filePath)
				utils.CheckErrorOrDie(err)

				marshaller := MapperYaml{}
				app, err := marshaller.Unmarshall(dat)
				utils.CheckErrorOrDie(err)
				clusterName := app.Metadata["name"].(string)
				res[clusterName] = *app
			}
		}
	}

	return nil, res
}
