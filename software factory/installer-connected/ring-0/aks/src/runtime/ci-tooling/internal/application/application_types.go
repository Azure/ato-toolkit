package application

import (
	"helm.sh/helm/v3/pkg/chartutil"
)

type C12Resource struct {
	ApiVersion string                 `json:"apiVersion"`
	Kind       string                 `json:"kind"`
	Metadata   map[string]interface{} `json:"metadata"`
}

// ApplicationConfig defines the structure
type ApplicationConfig struct {
	C12Resource `json:",inline"`
	Spec        ApplicationConfigSpecification `json:"spec"`
}

// ApplicationConfigSpecification
type ApplicationConfigSpecification struct {
	Archetype        ApplicationArchetypeMetadata   `json:"archetype"`
	Parameters       chartutil.Values               `json:"parameters"`
	DeploymentGroups []DeploymentGroupSpecification `json:"deployment-groups"`
}

// ApplicationArchetypeMetadata Metadata for the archetype used by this application
type ApplicationArchetypeMetadata struct {
	Name    string `yaml:"name"`
	Version string `yaml:"version"`
}

// DeploymentGroupSpecification Parameters for the different stages of the application
type DeploymentGroupSpecification struct {
	Name        string                          `json:"name"`
	Archetype   ApplicationArchetypeMetadata    `json:"archetype"`
	Parameters  chartutil.Values                `json:"parameters"`
	Application DeploymentGroupAppSpecification `json:"application"`
	Clusters    []ApplicationGroupClusterSpec   `json:"clusters"`
}

type DeploymentGroupAppSpecification struct {
	Version string `json:"version"`
}

// ApplicationLifeCyleArchetypeClusterMetadata
type ApplicationGroupClusterSpec struct {
	Name       string           `json:"name"`
	Parameters chartutil.Values `json:"parameters"`
}
