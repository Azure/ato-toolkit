package archetype

// TODO: make this a common structure after merging the packages.
type C12Resource struct {
	ApiVersion string                 `yaml:"apiVersion"`
	Kind       string                 `yaml:"kind"`
	Metadata   map[string]interface{} `yaml:"metadata"`
}

type Archetype struct {
	C12Resource `yaml:",inline"`
	Spec        ArchetypeSpecification `yaml:"spec"`
}

type ArchetypeSpecification struct {
	Versions []string `yaml:"versions"`
}
