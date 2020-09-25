package main

import (
	"encoding/json"
	"os"

	"github.com/Azure/ato-toolkit/automation/aks/src/runtime/ci-tooling/internal/application"
	"github.com/Azure/ato-toolkit/automation/aks/src/runtime/ci-tooling/internal/utils"
	"github.com/spf13/cobra"
)

const appFlagName = "appfolder"
const appName = "appsourceextractor"

var rootCmd = &cobra.Command{
	Use:   appName,
	Short: "Gets the names of all different applications defined in a folder",
	Long:  `appsourceextractor Gets the names of all different applications defined in a folder`,
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
}

func run(cmd *cobra.Command, args []string) {

	appPath := cmd.Flag(appFlagName).Value.String()

	reenderer := SourceExtractor{
		ApplicationFolderPath: appPath,
	}

	result := reenderer.renderAll()
	err := json.NewEncoder(os.Stdout).Encode(result)
	utils.CheckErrorOrDie(err)
}

// SourceExtractor Settings for the runner.
type SourceExtractor struct {
	ApplicationFolderPath string
}

func (render *SourceExtractor) renderAll() []string {

	utils.EnsurePathIsADir(render.ApplicationFolderPath)

	err, apps := application.GetAllAppsInfolder(render.ApplicationFolderPath)
	utils.CheckErrorOrDie(err)

	result := []string{}
	for _, app := range apps {
		result = append(result, app.Metadata["name"].(string))
	}

	return result
}
