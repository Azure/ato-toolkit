package application

import (
	"github.com/Azure/ato-toolkit/automation/aks/src/runtime/ci-tooling/internal/utils"
	"github.com/google/go-cmp/cmp"
	"os"
	"testing"
)

const testDataFileName = "app-test.yaml"

var data = []byte(utils.LoadTestFile(testDataFileName))

var brokenYaml = []byte(`
==33,¬
`)

func TestMain(m *testing.M) {
	// call flag.Parse() here if TestMain uses flags
	os.Exit(m.Run())
}

var mockApp = ApplicationConfig{
	C12Resource: C12Resource{
		ApiVersion: "c12.microsoft.com/v1",
		Kind:       "ApplicationConfig",
		Metadata: map[string]interface{}{
			"name": "testapp",
		},
	},
	Spec: ApplicationConfigSpecification{
		Archetype: ApplicationArchetypeMetadata{
			Name:    "simple-webservice",
			Version: "1.0.0",
		},
		Parameters: map[string]interface{}{"internal-port": float64(8080)},
		DeploymentGroups: []DeploymentGroupSpecification{
			{
				Name:        "dev",
				Application: DeploymentGroupAppSpecification{Version: "9.0.1-0-30d454a2"},
				Archetype:   ApplicationArchetypeMetadata{Version: "1.1.0"},
				Parameters:  map[string]interface{}{"replicas": float64(2), "ingress-hostname": "ahost.yourdomain.tld"},
				Clusters: []ApplicationGroupClusterSpec{
					{
						Name:       "contoso-northeurope-0001",
						Parameters: map[string]interface{}{"replicas": float64(2)},
					},
				},
			},
			{
				Name:        "production",
				Application: DeploymentGroupAppSpecification{},
				Parameters:  map[string]interface{}{"replicas": float64(20), "ingress-hostname": "testapp-host.yourdomain.tld"},
				Clusters: []ApplicationGroupClusterSpec{
					{
						Name:       "contoso-northeurope-0002",
						Parameters: map[string]interface{}{"replicas": float64(10)},
					},
					{
						Name:       "contoso-westus-0003",
						Parameters: map[string]interface{}{"replicas": float64(5)},
					},
				},
			},
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

func TestCanMarsharll(t *testing.T) {

	_, err := marshaller.Marshall(&mockApp)

	if err != nil {
		t.Error("Application marshaller was not able to marsharll")
	}
}

func CompareOrFail(x, y interface{}, t *testing.T) {

	if !cmp.Equal(x, y) {
		t.Errorf("parsed object and the result object were not the same: %s", cmp.Diff(x, y))
	}
}
