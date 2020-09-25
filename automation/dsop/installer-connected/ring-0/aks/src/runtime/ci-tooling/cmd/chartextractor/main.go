package main

import (
	"encoding/json"
	"errors"
	"os"

	"github.com/Azure/ato-toolkit/automation/aks/src/runtime/ci-tooling/internal/application"
	"github.com/Azure/ato-toolkit/automation/aks/src/runtime/ci-tooling/internal/cluster"
	"github.com/Azure/ato-toolkit/automation/aks/src/runtime/ci-tooling/internal/utils"
	"github.com/spf13/cobra"
)

const appFlagName = "appfolder"
const clusterFolderFlagName = "clusterfolder"
const appName = "chartextractor"

var rootCmd = &cobra.Command{
	Use:   appName,
	Short: "Calculates in which cluster each archetype should be installed",
	Long:  `chartextractor is a CLI that takes input applications folder and cluster folder according to c12 specs and ouputs which archetypes needs to be installed in which cluster`,
	Run:   run,
}

func main() {
	setupFlags()
	err := rootCmd.Execute()

	utils.CheckErrorOrDie(err)
}

func setupFlags() {
	rootCmd.Flags().StringP(appFlagName, "a", "", "The folder where the applications yamls definitions are")
	err := rootCmd.MarkFlagRequired(appFlagName)
	utils.CheckErrorOrDie(err)

	rootCmd.Flags().StringP(clusterFolderFlagName, "c", "", "The folder with the file definition of all clusters")
	err = rootCmd.MarkFlagRequired(clusterFolderFlagName)
	utils.CheckErrorOrDie(err)
}

func run(cmd *cobra.Command, args []string) {

	appPath := cmd.Flag(appFlagName).Value.String()
	clusterPath := cmd.Flag(clusterFolderFlagName).Value.String()

	reenderer := ChartExtractor{
		ApplicationFolderPath: appPath,
		ClusterFolderPath:     clusterPath,
	}

	result := reenderer.renderAll()
	err := json.NewEncoder(os.Stdout).Encode(result)
	utils.CheckErrorOrDie(err)
}

// ChartExtractor Settings for the runner.
type ChartExtractor struct {
	ApplicationFolderPath string
	ClusterFolderPath     string
}

func (render *ChartExtractor) renderAll() map[string][]string {

	utils.EnsurePathIsADir(render.ApplicationFolderPath)
	utils.EnsurePathIsADir(render.ClusterFolderPath)

	err, apps := application.GetAllAppsInfolder(render.ApplicationFolderPath)
	err, clusters := cluster.GetAllClustersInfolder(render.ClusterFolderPath)
	utils.CheckErrorOrDie(err)

	archetypeToClusters := map[string]map[string]bool{}
	// Loop over all the apps, to find all archetypes
	for _, app := range apps {
		archetype := app.Spec.Archetype.Name
		var clustersForArchetype map[string]bool

		// recover the map for the given archetype or create a new one if does not exist.
		if val, exists := archetypeToClusters[archetype]; !exists {
			newMap := map[string]bool{}
			archetypeToClusters[archetype] = newMap
			clustersForArchetype = newMap
		} else {
			clustersForArchetype = val
		}

		// loop over all the deployment groups of the app to find all the clusters
		for _, deploymentGroup := range app.Spec.DeploymentGroups {

			for _, clust := range deploymentGroup.Clusters {
				// Find the cluster definition of the cluster that we are going to return.
				_, ok := clusters[clust.Name]
				if !ok {
					utils.CheckErrorOrDie(errors.New("Can't find information of cluster: " + clust.Name))
				}
				clustersForArchetype[clust.Name] = true
			}
		}
	}

	result := map[string][]string{}
	for archetype, b := range archetypeToClusters {
		clusters := []string{}

		for clusterStr := range b {
			clusters = append(clusters, clusterStr)
		}
		result[archetype] = clusters
	}

	return result
}
