package helmreleasev1

import (
	"io/ioutil"
	"github.com/Azure/ato-toolkit/automation/aks/src/runtime/ci-tooling/internal/utils"
)

// GetHelmRelease Parses an Archetype in a yaml file
func GetHelmRelease(path string) *HelmRelease {

	dat, err := ioutil.ReadFile(path)
	utils.CheckErrorOrDie(err)

	marshaller := MapperYaml{}
	app, err := marshaller.Unmarshall(dat)
	utils.CheckErrorOrDie(err)

	return app
}

