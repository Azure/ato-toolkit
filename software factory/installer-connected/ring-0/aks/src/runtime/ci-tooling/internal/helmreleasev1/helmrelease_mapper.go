package helmreleasev1

import (
	"github.com/ghodss/yaml"
)

// Mapper mapper for the Archetype type
type Mapper interface {
	Marshall(app *HelmRelease) ([]byte, error)
	Unmarshall(data []byte) (*HelmRelease, error)
}

// MapperYaml YAML based implementation of the Mapper
type MapperYaml struct {
}

// Marshall marshalls an HelmRelease into a YAML byte[]
func (mapper *MapperYaml) Marshall(app *HelmRelease) ([]byte, error) {

	if app == nil {
		return nil, nil
	}

	buff, err := yaml.Marshal(app)

	if err != nil {
		return nil, err
	}

	return buff, nil
}

// Unmarshall reads a byte[] providing an application
func (mapper *MapperYaml) Unmarshall(data []byte) (*HelmRelease, error) {

	obj := &HelmRelease{}

	err := yaml.Unmarshal(data, obj)
	if err != nil {
		return nil, err
	}

	return obj, nil
}

var mapper = MapperYaml{}
