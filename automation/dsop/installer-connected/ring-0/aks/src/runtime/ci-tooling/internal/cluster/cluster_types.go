package cluster

// TODO: move this
// C12Resource make this a common structure after merging the packages.
type C12Resource struct {
	ApiVersion string                 `json:"apiVersion"`
	Kind       string                 `json:"kind"`
	Metadata   map[string]interface{} `json:"metadata"`
}

// Cluster the "CDR" for the cluster object
type Cluster struct {
	C12Resource `json:",inline"`
	Spec        ClusterSpecification `json:"spec"`
}

// ClusterSpecification the fields for the cluster specific fields
type ClusterSpecification struct {
	Location     string                  `json:"location"`
	RegistrySpec RegistrySpecification   `json:"registry"`
	KubeSpec     KubernetesSpecification `json:"kubernetes"`
}

// KubernetesSpecification fields for the kubernetes cluster
type KubernetesSpecification struct {
	URL string `json:"url"`
}

// RegistrySpecification  fields for the definition fo the repositories
type RegistrySpecification struct {
	DockerSpec DockerSpecification `json:"docker"`
	HelmSpec   HelmSpecification   `json:"helm"`
}

// DockerSpecification fields for docker registry associated with the cluster
type DockerSpecification struct {
	URL string `json:"url"`
}

// HelmSpecification fields for the helm chart registry associated with the cluster
type HelmSpecification struct {
	URL string `json:"url"`
}
