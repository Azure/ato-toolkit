package archetype

import (
	"os"
	"testing"

	"github.com/Azure/ato-toolkit/automation/aks/src/runtime/ci-tooling/internal/utils"
	"github.com/google/go-cmp/cmp"
)

const testDataFileName = "archetype-test.yaml"

var data = []byte(utils.LoadTestFile(testDataFileName))

var brokenYaml = []byte(`
==33,¬
`)

func TestMain(m *testing.M) {
	// call flag.Parse() here if TestMain uses flags
	os.Exit(m.Run())
}

var mockApp = Archetype{
	C12Resource: C12Resource{
		ApiVersion: "c12.microsoft.com/v1",
		Kind:       "ArchetypeConfig",
		Metadata:   map[string]interface{}{"name": "simple-webservice"},
	},
	Spec: ArchetypeSpecification{
		Versions: []string{
			"1.0.0",
			"1.1.0",
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
