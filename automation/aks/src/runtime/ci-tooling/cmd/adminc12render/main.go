package main

import (
	"errors"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"path/filepath"

	"helm.sh/helm/v3/pkg/chartutil"

	"github.com/Azure/ato-toolkit/automation/aks/src/runtime/ci-tooling/internal/application"
	"github.com/Azure/ato-toolkit/automation/aks/src/runtime/ci-tooling/internal/cluster"
	"github.com/Azure/ato-toolkit/automation/aks/src/runtime/ci-tooling/internal/helmreleasev1"
	"github.com/Azure/ato-toolkit/automation/aks/src/runtime/ci-tooling/internal/utils"
	"github.com/ghodss/yaml"
	"github.com/spf13/cobra"
	v1 "k8s.io/api/core/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

const appName = "adminc12render"

const appFlagName = "app"
const dstFlagName = "destination"
const clusterFolderFlagName = "clusterfolder"
const prefixFlagName = "prefix"
const githubOrganizationFlagName = "organization"
const sshKeysFlagName = "ssh-key"

var rootCmd = &cobra.Command{
	Use:   appName,
	Short: "Generates HelmReleases and Namespace manifests for c12-admin based on application definitions",
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

	rootCmd.Flags().StringP(sshKeysFlagName, "s", "", "The file with the json map with the ssh keys to add to flux secrets")
	err = rootCmd.MarkFlagRequired(sshKeysFlagName)
	utils.CheckErrorOrDie(err)

}

func run(cmd *cobra.Command, args []string) {

	appPath := cmd.Flag(appFlagName).Value.String()
	dstPath := cmd.Flag(dstFlagName).Value.String()
	clusterPath := cmd.Flag(clusterFolderFlagName).Value.String()
	prefix := cmd.Flag(prefixFlagName).Value.String()
	githubOrganization := cmd.Flag(githubOrganizationFlagName).Value.String()
	sshKey := cmd.Flag(sshKeysFlagName).Value.String()

	reenderer := AppYamlRenderer{
		ApplicationYamlPath: appPath,
		OutputPath:          dstPath,
		ClusterFolderPath:   clusterPath,
		InstallationPrefix:  prefix,
		GithubOrganization:  githubOrganization,
		SshKey:              sshKey,
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
	SshKey              string

	appConfig  *application.ApplicationConfig
	clusterMap map[string]cluster.Cluster
}

type fluxHelmReleaseSettings struct {
	ChartName    string
	ChartVersion string
	Image        string
	ImageTag     string
}

var hardcodedFluxSettings = fluxHelmReleaseSettings{
	ChartName:    "flux",
	ChartVersion: "1.3.0",
	Image:        "fluxcd/flux",
	ImageTag:     "1.19.0",
}

func (render *AppYamlRenderer) loadAllYamls() error {

	utils.EnsurePathIsADir(render.OutputPath)
	utils.EnsurePathIsADir(render.ClusterFolderPath)

	render.appConfig = application.GetAppFromFile(render.ApplicationYamlPath)
	err, clusters := cluster.GetAllClustersInfolder(render.ClusterFolderPath)
	render.clusterMap = clusters

	return err
}

func (render *AppYamlRenderer) renderAll() error {

	err := render.loadAllYamls()
	utils.CheckErrorOrDie(err)

	dstpath := render.OutputPath

	app := render.appConfig
	appLevelParams := render.appConfig.Spec.Parameters
	appName := render.appConfig.Metadata["name"].(string)
	clusters := render.clusterMap

	//Go over all deployment groups
	for _, deploymentGroup := range app.Spec.DeploymentGroups {
		deployMentGroupParams := deploymentGroup.Parameters

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

			appInClusterPrefix := utils.GetNamespaceForApp(render.InstallationPrefix, appName, deploymentGroup.Name)

			//Render the helm release for ssh key for flux
			filename := appInClusterPrefix + "-flux-ssh-key-secret.yaml"
			pathForAppInClus := filepath.Join(clusterDir, filename)
			rendered, err := render.renderSshSecret(app, &deploymentGroup, clusterDefinition)
			utils.CheckErrorOrDie(err)
			err = ioutil.WriteFile(pathForAppInClus, rendered, 0644)
			utils.CheckErrorOrDie(err)

			//Render the helm release for flux
			filename = appInClusterPrefix + "-flux-helm-release.yaml"
			pathForAppInClus = filepath.Join(clusterDir, filename)
			rendered = render.renderFluxHelmRelease(app, &deploymentGroup, clusterDefinition, clusterParams)
			err = ioutil.WriteFile(pathForAppInClus, rendered, 0644)
			utils.CheckErrorOrDie(err)

			//Render the namespaceManifest
			filename = appInClusterPrefix + "-namespace.yaml"
			pathForAppInClus = filepath.Join(clusterDir, filename)
			rendered, err = renderNamespaceObject(appInClusterPrefix)
			err = ioutil.WriteFile(pathForAppInClus, rendered, 0644)
			utils.CheckErrorOrDie(err)
		}
	}
	return nil
}

func renderNamespaceObject(namespace string) ([]byte, error) {
	nsobj := v1.Namespace{}
	nsobj.APIVersion = "v1"
	nsobj.Kind = "Namespace"
	nsobj.ObjectMeta.SetName(namespace)

	buff, err := yaml.Marshal(nsobj)
	if err != nil {
		log.Fatal()
		return nil, err
	}

	return buff, nil
}

func (render *AppYamlRenderer) renderSshSecret(app *application.ApplicationConfig, dp *application.DeploymentGroupSpecification, cl cluster.Cluster) ([]byte, error) {
	secret := v1.Secret{}
	secret.APIVersion = "v1"
	secret.Kind = "Secret"
	appName := app.Metadata["name"].(string)
	namespace := utils.GetNamespaceForApp(render.InstallationPrefix, appName, dp.Name)
	secret.ObjectMeta.SetName("flux-ssh")
	secret.ObjectMeta.SetNamespace(namespace)

	secret.Data = map[string][]byte{
		"identity": []byte(render.SshKey),
	}

	buff, err := yaml.Marshal(secret)
	if err != nil {
		log.Fatal()
		return nil, err
	}

	return buff, nil

}

func (render *AppYamlRenderer) renderFluxHelmRelease(app *application.ApplicationConfig, dp *application.DeploymentGroupSpecification, cl cluster.Cluster, values map[string]interface{}) []byte {

	c12AdminNamespace := utils.GetAdminNamespace(render.InstallationPrefix)

	appName := app.Metadata["name"].(string)
	clusName := cl.Metadata["name"].(string)

	localName := utils.GetNamespaceForApp(render.InstallationPrefix, appName, dp.Name)
	releaseName := localName + "-flux-release"
	namespace := localName

	timeout := int64(300)
	repoChartURL := cl.Spec.RegistrySpec.HelmSpec.URL

	gitRepoURL := fmt.Sprintf("git@github.com:%s/%s-%s-state.git", render.GithubOrganization, render.InstallationPrefix, appName)
	gitRepoFolder := clusName

	hr := helmreleasev1.HelmRelease{
		TypeMeta: metav1.TypeMeta{
			Kind:       "HelmRelease",
			APIVersion: "helm.fluxcd.io/v1",
		},
		ObjectMeta: metav1.ObjectMeta{
			Name:      releaseName,
			Namespace: c12AdminNamespace,
		},
		Spec: helmreleasev1.HelmReleaseSpec{
			ReleaseName:     releaseName,
			TargetNamespace: namespace,
			Timeout:         &timeout,
			ResetValues:     false,
			ForceUpgrade:    false,
			ChartSource: helmreleasev1.ChartSource{
				RepoChartSource: &helmreleasev1.RepoChartSource{
					Name:    hardcodedFluxSettings.ChartName,
					Version: hardcodedFluxSettings.ChartVersion,
					RepoURL: repoChartURL,
				},
			},
			HelmValues: getValuesForHelmRelease(gitRepoURL, gitRepoFolder, cl.Spec.RegistrySpec.DockerSpec.URL),
		},
	}

	buf, err := yaml.Marshal(hr)
	utils.CheckErrorOrDie(err)

	return buf
}

func getValuesForHelmRelease(gitURL string, gitPath string, dockerLoginServer string) helmreleasev1.HelmValues {
	values := map[string]interface{}{
		"image": map[string]interface{}{
			"repository": fmt.Sprintf("%s/%s", dockerLoginServer, hardcodedFluxSettings.Image),
			"tag":        hardcodedFluxSettings.ImageTag,
		},
		"git": map[string]interface{}{
			"url":          gitURL,
			"path":         gitPath,
			"pollInterval": "30s",
			"readonly":     true,
			"secretName":   "flux-ssh",
		},
		"nodeSelector": map[string]interface{}{
			"beta.kubernetes.io/os": "linux",
		},
		"memcached": map[string]interface{}{
			"enabled": false,
		},
		"helmOperator": map[string]interface{}{
			"create": false,
		},
		"clusterRole": map[string]interface{}{
			"create": true,
		},
		"registry": map[string]interface{}{
			"disableScanning": true,
			"acr": map[string]interface{}{
				"enabled": true,
			},
		},
		"resources": map[string]interface{}{
			"limits": map[string]interface{}{
				"memory": "1Gi",
				"cpu":    "1",
			},
		},
	}

	vals := chartutil.Values(values)
	return helmreleasev1.HelmValues{Values: vals}
}
