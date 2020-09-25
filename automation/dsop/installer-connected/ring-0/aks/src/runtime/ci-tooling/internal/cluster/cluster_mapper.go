package cluster

import (
	"github.com/ghodss/yaml"
)

// Mapper mapper for the Archetype type
type Mapper interface {
	Marshall(app *Cluster) ([]byte, error)
	Unmarshall(data []byte) (*Cluster, error)
}

// MapperYaml YAML based implementation of the ApplictionMapper
type MapperYaml struct {
}

// Marshall marshalls an application into a YAML byte[]
func (mapper *MapperYaml) Marshall(app *Cluster) ([]byte, error) {

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
func (mapper *MapperYaml) Unmarshall(data []byte) (*Cluster, error) {

	obj := &Cluster{}

	err := yaml.Unmarshal(data, obj)
	if err != nil {
		return nil, err
	}

	return obj, nil
}

var mapper = MapperYaml{}
