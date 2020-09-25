package main

import (
	"errors"
	"io/ioutil"
	"log"
	"os"
	"path/filepath"
	"fmt"

	"github.com/Azure/ato-toolkit/automation/aks/src/runtime/ci-tooling/internal/application"
	"github.com/Azure/ato-toolkit/automation/aks/src/runtime/ci-tooling/internal/cluster"
	"github.com/Azure/ato-toolkit/automation/aks/src/runtime/ci-tooling/internal/helmreleasev1"
	"github.com/Azure/ato-toolkit/automation/aks/src/runtime/ci-tooling/internal/utils"
	"github.com/ghodss/yaml"
	"github.com/spf13/cobra"
	"helm.sh/helm/v3/pkg/chartutil"
	rbac "k8s.io/api/rbac/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

const appName = "apprendering"

const appFlagName = "app"
const dstFlagName = "destination"
const clusterFolderFlagName = "clusterfolder"
const prefixFlagName = "prefix"
const githubOrganizationFlagName = "organization"

var roles = map[string]string{
	"break-glass": "fakegroupidforbreakgrassofapp",
	"read-only":   "fakegroupidforread-onlysofapp",
	"sre":         "fakegroupidforserofapp",
}

var rootCmd = &cobra.Command{
	Use:   appName,
	Short: "Generates HelmReleases based on application definitions",
	Long:  `apprendering is a CLI that takes input applications written in YAML or JSON and generates HelmReleases K8s CRDs`,
	Run:   run,
}

func main() {
	setupFlags()
	err := rootCmd.Execute()

	utils.CheckErrorOrDie(err)
}

func setupFlags() {
	rootCmd.Flags().StringP(appFlagName, "a", "", "The definition of the application file in yaml format")
	err := rootCmd.MarkFlagRequired(appFlagName)
	utils.CheckErrorOrDie(err)

	rootCmd.Flags().StringP(dstFlagName, "d", "", "The destination path where the files will be created")
	err = rootCmd.MarkFlagRequired(dstFlagName)
	utils.CheckErrorOrDie(err)

	rootCmd.Flags().StringP(clusterFolderFlagName, "c", "", "The folder with the file definition of all clusters")
	err = rootCmd.MarkFlagRequired(clusterFolderFlagName)
	utils.CheckErrorOrDie(err)

	rootCmd.Flags().StringP(prefixFlagName, "p", "", "The prefix for this c12 installation")
	err = rootCmd.MarkFlagRequired(prefixFlagName)
	utils.CheckErrorOrDie(err)

	rootCmd.Flags().StringP(githubOrganizationFlagName, "o", "", "The github organization, used to generate the URLs of the git repository URL")
	err = rootCmd.MarkFlagRequired(githubOrganizationFlagName)
	utils.CheckErrorOrDie(err)

}

func run(cmd *cobra.Command, args []string) {

	appPath := cmd.Flag(appFlagName).Value.String()
	dstPath := cmd.Flag(dstFlagName).Value.String()
	clusterPath := cmd.Flag(clusterFolderFlagName).Value.String()
	prefix := cmd.Flag(prefixFlagName).Value.String()
	githubOrganization := cmd.Flag(githubOrganizationFlagName).Value.String()

	reenderer := AppYamlRenderer{
		ApplicationYamlPath: appPath,
		OutputPath:          dstPath,
		ClusterFolderPath:   clusterPath,
		InstallationPrefix:  prefix,
		GithubOrganization:  githubOrganization,

	}

	reenderer.renderAll()
}

// AppYamlRenderer Settings for the runner.
type AppYamlRenderer struct {
	ApplicationYamlPath string
	OutputPath          string
	ClusterFolderPath   string
	InstallationPrefix  string
	GithubOrganization  string
}

func (render *AppYamlRenderer) renderAll() error {

	utils.EnsurePathIsADir(render.OutputPath)
	utils.EnsurePathIsADir(render.ClusterFolderPath)

	app := application.GetAppFromFile(render.ApplicationYamlPath)
	err, clusters := cluster.GetAllClustersInfolder(render.ClusterFolderPath)
	utils.CheckErrorOrDie(err)

	dstpath := render.OutputPath

	appLevelParams := app.Spec.Parameters
	appName := app.Metadata["name"].(string)

	for _, deploymentGroup := range app.Spec.DeploymentGroups {
		deployMentGroupParams := deploymentGroup.Parameters

		if deploymentGroup.Application.Version != "" {
			// Combine the parametes of the Application with the ones from the deployment
			cascadedParams := utils.MergeMaps(appLevelParams, deployMentGroupParams)

			for _, clust := range deploymentGroup.Clusters {
				// Find the cluster definition of the cluster that we are prepairing the HelmRelease for.
				clusterDefinition, ok := clusters[clust.Name]
				if !ok {
					return errors.New("Can't find information of cluster: " + clust.Name)
				}

				// Combine the maps for the deployment group with the ones for this cluster
				clusterParams := utils.MergeMaps(cascadedParams, clust.Parameters)
				clusterDir := filepath.Join(dstpath, clust.Name)
				if err := os.Mkdir(clusterDir, 0777); !os.IsExist(err) {
					utils.CheckErrorOrDie(err)
				}
				filename := appName + "-" + deploymentGroup.Name + "-" + clust.Name + "-app-helmrelease.yaml"
				pathForAppInClus := filepath.Join(clusterDir, filename)
				rendered := render.renderOneFromStructure(app, &deploymentGroup, clusterDefinition, clusterParams)
				err := ioutil.WriteFile(pathForAppInClus, rendered, 0644)
				utils.CheckErrorOrDie(err)

				for role, groupId := range roles {
					namespace := utils.GetNamespaceForApp(render.InstallationPrefix, appName, deploymentGroup.Name)
					filename := appName + "-" + deploymentGroup.Name + "-" + role + "-role-binding.yaml"
					pathForAppInClus := filepath.Join(clusterDir, filename)
					rendered, err := renderRoleBinding(role, groupId, namespace)
					utils.CheckErrorOrDie(err)
					err = ioutil.WriteFile(pathForAppInClus, rendered, 0644)
					utils.CheckErrorOrDie(err)
				}
			}
		} else {
			log.Printf("Skpping application in deployment group %s version was null", deploymentGroup.Name)
		}
	}
	return nil
}

func renderRoleBinding(roleName string, group string, namespace string) ([]byte, error) {

	binding := rbac.RoleBinding{
		metav1.TypeMeta{
			APIVersion: "rbac.authorization.k8s.io/v1",
			Kind:       "RoleBinding",
		},
		metav1.ObjectMeta{
			Namespace: namespace,
			Name:      roleName + "-" + namespace,
		},
		[]rbac.Subject{
			{
				Kind:     "Group",
				APIGroup: "rbac.authorization.k8s.io",
				Name:     group,
			},
		},
		rbac.RoleRef{
			APIGroup: "rbac.authorization.k8s.io",
			Kind:     "ClusterRole",
			Name:     roleName,
		},
	}

	return yaml.Marshal(binding)
}

func (render *AppYamlRenderer) renderOneFromStructure(app *application.ApplicationConfig, lfc *application.DeploymentGroupSpecification, cl cluster.Cluster, values map[string]interface{}) []byte {

	appName := app.Metadata["name"].(string)
	prefix := render.InstallationPrefix
	localName := utils.GetNamespaceForApp(prefix, appName, lfc.Name)
	releaseName := localName + "-app-release"
	namespace := localName

	timeout := int64(300)
	vals := chartutil.Values(values)
	archetypeVersion := app.Spec.Archetype.Version
	repoURL := cl.Spec.RegistrySpec.HelmSpec.URL
	dockerRegistryURL := cl.Spec.RegistrySpec.DockerSpec.URL
	org := render.GithubOrganization
	
	repositoryName := fmt.Sprintf("%s/%s/%s-%s-src",dockerRegistryURL,org,prefix,appName)

	vals["image"] = map[string]interface{} {
		"repository": repositoryName,
		"version": lfc.Application.Version,
	}

	if lfc.Archetype.Version != "" {
		archetypeVersion = lfc.Archetype.Version
	}

	hr := helmreleasev1.HelmRelease{
		TypeMeta: metav1.TypeMeta{
			Kind:       "HelmRelease",
			APIVersion: "helm.fluxcd.io/v1",
		},
		ObjectMeta: metav1.ObjectMeta{
			Name:      releaseName,
			Namespace: namespace,
		},
		Spec: helmreleasev1.HelmReleaseSpec{
			ReleaseName:     releaseName,
			TargetNamespace: namespace,
			Timeout:         &timeout,
			ResetValues:     false,
			ForceUpgrade:    false,
			ChartSource: helmreleasev1.ChartSource{
				RepoChartSource: &helmreleasev1.RepoChartSource{
					Name:    app.Spec.Archetype.Name,
					Version: archetypeVersion,
					RepoURL: repoURL,
				},
			},
			HelmValues: helmreleasev1.HelmValues{Values: vals},
		},
	}
	buf, err := yaml.Marshal(hr)
	utils.CheckErrorOrDie(err)

	return buf
}
