package application

import (
	"github.com/ghodss/yaml"
)

// Mapper mapper for the Application type
type Mapper interface {
	Marshall(app *ApplicationConfig) ([]byte, error)
	Unmarshall(data []byte) (*ApplicationConfig, error)
}

// ApplictionMapperYaml YAML based implementation of the ApplictionMapper
type MapperYaml struct {
}

// Marshall marshalls an applycation into a YAML byte[]
func (mapper *MapperYaml) Marshall(app *ApplicationConfig) ([]byte, error) {

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
func (mapper *MapperYaml) Unmarshall(data []byte) (*ApplicationConfig, error) {

	obj := &ApplicationConfig{}

	err := yaml.Unmarshal(data, obj)
	if err != nil {
		return nil, err
	}

	return obj, nil
}
