package cluster

import (
	"os"
	"testing"

	"github.com/Azure/ato-toolkit/automation/aks/src/runtime/ci-tooling/internal/utils"
	"github.com/google/go-cmp/cmp"
)

const testDataFileName = "cluster-northeurope-0001.yaml"

var data = []byte(utils.LoadTestFile(testDataFileName))

var brokenYaml = []byte(`
==33,¬
`)

func TestMain(m *testing.M) {
	// call flag.Parse() here if TestMain uses flags
	os.Exit(m.Run())
}

var mockApp = Cluster{
	C12Resource: C12Resource{
		ApiVersion: "c12.microsoft.com/v1",
		Kind:       "ClusterConfig",
		Metadata:   map[string]interface{}{"name": "contoso-northeurope-0001"},
	},
	Spec: ClusterSpecification{
		Location: "northeurope",
		RegistrySpec: RegistrySpecification{
			DockerSpec: DockerSpecification{
				URL: "contosoaksacr.azurecr.io",
			},
			HelmSpec: HelmSpecification{
				URL: "https://contosoaksacr.azurecr.io/helm/v1/repo",
			},
		},
		KubeSpec: KubernetesSpecification{
			URL: "https://kubeapi-n-eu-0001.k8s.az.com",
		},
	},
}

var marshaller = &MapperYaml{}

func TestCanUnMarsharll(t *testing.T) {

	_, err := marshaller.Unmarshall(data)

	if err != nil {
		t.Error(err)
		t.FailNow()
	}
}

func TestUnmarshallReturnsErrorOnBrokenYaml(t *testing.T) {

	_, err := marshaller.Unmarshall(brokenYaml)

	if err == nil {
		t.Error("Unmarshall did not returned error with broken yaml")
	}
}

func TestUnmarshallDeepCorrectly(t *testing.T) {

	obj, _ := marshaller.Unmarshall(data)
	actual := &mockApp

	if obj == &mockApp {
		t.Error("The parsed object and the result object were not the same")
	}

	CompareOrFail(obj, actual, t)
}

func CompareOrFail(x, y interface{}, t *testing.T) {

	if !cmp.Equal(x, y) {
		t.Errorf("parsed object and the result object were not the same: %s", cmp.Diff(x, y))
	}
}
