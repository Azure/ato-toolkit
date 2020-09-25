package helmreleasev1

import (
	"helm.sh/helm/v3/pkg/chartutil"
	v1 "k8s.io/api/core/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

// +genclient
// +k8s:deepcopy-gen:interfaces=k8s.io/apimachinery/pkg/runtime.Object

// FluxHelmRelease represents custom resource associated with a Helm Chart
type HelmRelease struct {
	metav1.TypeMeta   `json:",inline"`
	metav1.ObjectMeta `json:"metadata"`

	Spec HelmReleaseSpec `json:"spec"`
	//	Status HelmReleaseStatus `json:"status"`
}

// ValuesFromSource represents a source of values.
// Only one of its fields may be set.
type ValuesFromSource struct {
	// Selects a key of a ConfigMap.
	// +optional
	ConfigMapKeyRef *v1.ConfigMapKeySelector `json:"configMapKeyRef,omitempty"`
	// Selects a key of a Secret.
	// +optional
	SecretKeyRef *v1.SecretKeySelector `json:"secretKeyRef,omitempty"`
	// Selects an URL.
	// +optional
	ExternalSourceRef *ExternalSourceSelector `json:"externalSourceRef,omitempty"`
	// Selects a file from git source helm chart.
	// +optional
	ChartFileRef *ChartFileSelector `json:"chartFileRef,omitempty"`
}

type ChartFileSelector struct {
	Path string `json:"path"`
	// Do not fail if chart file could not be retrieved
	// +optional
	Optional *bool `json:"optional,omitempty"`
}

type ExternalSourceSelector struct {
	URL string `json:"url"`
	// Do not fail if external source could not be retrieved
	// +optional
	Optional *bool `json:"optional,omitempty"`
}

type ChartSource struct {
	// one of the following...
	// +optional
	*GitChartSource
	// +optional
	*RepoChartSource
}

type GitChartSource struct {
	GitURL string `json:"git"`
	Ref    string `json:"ref"`
	Path   string `json:"path"`
	// Do not run 'dep' update (assume requirements.yaml is already fulfilled)
	// +optional
	SkipDepUpdate bool `json:"skipDepUpdate,omitempty"`
}

type RepoChartSource struct {
	RepoURL string `json:"repository"`
	Name    string `json:"name"`
	Version string `json:"version"`
	// An authentication secret for accessing the chart repo
	// +optional
	ChartPullSecret *v1.LocalObjectReference `json:"chartPullSecret,omitempty"`
}

type Rollback struct {
	Enable       bool   `json:"enable,omitempty"`
	Force        bool   `json:"force,omitempty"`
	Recreate     bool   `json:"recreate,omitempty"`
	DisableHooks bool   `json:"disableHooks,omitempty"`
	Timeout      *int64 `json:"timeout,omitempty"`
	Wait         bool   `json:"wait,omitempty"`
}

// HelmReleaseSpec is the spec for a HelmRelease resource
type HelmReleaseSpec struct {
	ChartSource      `json:"chart"`
	ReleaseName      string                    `json:"releaseName,omitempty"`
	ValueFileSecrets []v1.LocalObjectReference `json:"valueFileSecrets,omitempty"`
	ValuesFrom       []ValuesFromSource        `json:"valuesFrom,omitempty"`
	HelmValues       `json:",inline"`
	// Override the target namespace, defaults to metadata.namespace
	// +optional
	TargetNamespace string `json:"targetNamespace,omitempty"`
	// Install or upgrade timeout in seconds
	// +optional
	Timeout *int64 `json:"timeout,omitempty"`
	// Reset values on helm upgrade
	// +optional
	ResetValues bool `json:"resetValues,omitempty"`
	// Force resource update through delete/recreate, allows recovery from a failed state
	// +optional
	ForceUpgrade bool `json:"forceUpgrade,omitempty"`
	// Enable rollback and configure options
	// +optional
	Rollback Rollback `json:"rollback,omitempty"`
}

type HelmReleaseStatus struct {
	// ReleaseName is the name as either supplied or generated.
	// +optional
	ReleaseName string `json:"releaseName"`

	// ReleaseStatus is the status as given by Helm for the release
	// managed by this resource.
	ReleaseStatus string `json:"releaseStatus"`

	// ObservedGeneration is the most recent generation observed by
	// the controller.
	ObservedGeneration int64 `json:"observedGeneration"`

	// ValuesChecksum holds the SHA256 checksum of the last applied
	// values.
	ValuesChecksum string `json:"valuesChecksum"`

	// Revision would define what Git hash or Chart version has currently
	// been deployed.
	// +optional
	Revision string `json:"revision,omitempty"`

	// Conditions contains observations of the resource's state, e.g.,
	// has the chart which it refers to been fetched.
	// +optional
	// +patchMergeKey=type
	// +patchStrategy=merge
	Conditions []HelmReleaseCondition `json:"conditions,omitempty" patchStrategy:"merge" patchMergeKey:"type"`
}

type HelmReleaseCondition struct {
	Type   HelmReleaseConditionType `json:"type"`
	Status v1.ConditionStatus       `json:"status"`
	// +optional
	LastUpdateTime metav1.Time `json:"lastUpdateTime,omitempty"`
	// +optional
	LastTransitionTime metav1.Time `json:"lastTransitionTime,omitempty"`
	// +optional
	Reason string `json:"reason,omitempty"`
	// +optional
	Message string `json:"message,omitempty"`
}

type HelmReleaseConditionType string

const (
	// ChartFetched means the chart to which the HelmRelease refers
	// has been fetched successfully
	HelmReleaseChartFetched HelmReleaseConditionType = "ChartFetched"
	// Released means the chart release, as specified in this
	// HelmRelease, has been processed by Helm.
	HelmReleaseReleased HelmReleaseConditionType = "Released"
	// RolledBack means the chart to which the HelmRelease refers
	// has been rolled back
	HelmReleaseRolledBack HelmReleaseConditionType = "RolledBack"
)

// FluxHelmValues embeds chartutil.Values so we can implement deepcopy on map[string]interface{}
// +k8s:deepcopy-gen=false
type HelmValues struct {
	chartutil.Values `json:"values,omitempty"`
}

// +k8s:deepcopy-gen:interfaces=k8s.io/apimachinery/pkg/runtime.Object

// HelmReleaseList is a list of FluxHelmRelease resources
type HelmReleaseList struct {
	metav1.TypeMeta `json:",inline"`
	metav1.ListMeta `json:"metadata"`

	Items []HelmRelease `json:"items"`
}
