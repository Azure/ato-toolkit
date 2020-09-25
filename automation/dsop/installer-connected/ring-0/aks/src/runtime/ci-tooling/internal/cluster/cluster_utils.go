package cluster

import (
	"io/ioutil"
	"path/filepath"

	"github.com/Azure/ato-toolkit/automation/aks/src/runtime/ci-tooling/internal/utils"
)

// GetAllClustersInfolder Reads all yaml files in a folder and returns a map
// using the cluster name as key of the map and the cluster read as a the associated value
func GetAllClustersInfolder(path string) (error, map[string]Cluster) {

	res := map[string]Cluster{}
	files, err := ioutil.ReadDir(path)

	if err != nil {
		return err, nil
	}

	for _, file := range files {
		filePath := filepath.Join(path, file.Name())
		if utils.FileExists(filePath) {
			if utils.FileIsYaml(filePath) {
				dat, err := ioutil.ReadFile(filePath)
				utils.CheckErrorOrDie(err)

				marshaller := MapperYaml{}
				cluster, err := marshaller.Unmarshall(dat)
				utils.CheckErrorOrDie(err)
				clusterName := cluster.Metadata["name"].(string)
				res[clusterName] = *cluster
			}
		}
	}

	return nil, res
}
