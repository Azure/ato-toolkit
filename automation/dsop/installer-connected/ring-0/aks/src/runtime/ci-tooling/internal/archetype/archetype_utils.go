package archetype

import (
	"io/ioutil"

	"github.com/Azure/ato-toolkit/automation/aks/src/runtime/ci-tooling/internal/utils"
)

// GetArchetype Parses an Archetype in a yaml file
func GetArchetype(path string) *Archetype {

	dat, err := ioutil.ReadFile(path)
	utils.CheckErrorOrDie(err)

	marshaller := MapperYaml{}
	app, err := marshaller.Unmarshall(dat)
	utils.CheckErrorOrDie(err)

	return app
}
