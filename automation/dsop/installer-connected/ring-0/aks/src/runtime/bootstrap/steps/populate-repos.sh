#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=src/runtime/bootstrap/lib/tools.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib/tools.sh"

# shellcheck source=src/runtime/bootstrap/lib/logging.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib/logging.sh"

# shellcheck source=src/runtime/bootstrap/lib/ini_val.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib/ini_val.sh"

# shellcheck source=src/runtime/pipelines/application-management/scripts/clone-repos.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../../pipelines/application-management/scripts/clone-repos.sh"

function populate-repos() {

    info "Populating repositories"    
    _config_file="$1"
    
    _file_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    _builtin=("archetype-management" "cluster-management" "application-management" "cluster-state")
    _applications=("sample-app-nodejs")
    
    _org=$(ini_val "$_config_file" github.org)
    _prefix=$(ini_val "$_config_file" c12.prefix)
    _pat_username=$(ini_val "$_config_file" github.access-token-username)
    _pat_password=$(ini_val "$_config_file" github.access-token)
    
    aks_name=$(ini_val "$_config_file" c12:generated.aks_name)
    ci_acr_name=$(ini_val "$_config_file" c12:generated.ci_acr_name)
    
    _tempfile=$(mktemp -d)
    
    pushd "$_tempfile" || exit 2
    
    info "Cloning management repositories"
    for repo in "${_builtin[@]}"; do
        git clone "https://${_pat_username}:${_pat_password}@github.com/$_org/$_prefix-$repo.git"
    done    

    info "Seeding management repositories with workflows and dependencies"
    for managment_repo in "${_builtin[@]}"; do
        info "Feeding static data of from $managment_repo to $_prefix-$managment_repo"
        pushd "$_prefix-$managment_repo" || exit 2
        cp -R "$_file_root/../../pipelines/$managment_repo/." .
        if [ -d "./scripts" ]; then
            # add scripts to .c12 dir
            mkdir -p ".c12/scripts/"
            rsync -qa --progress --remove-source-files "scripts/." ".c12/scripts/"
            echo ".c12/*   @$_org/$_prefix-$managment_repo-owner" > ./CODEOWNERS        
        fi
        #Add prefex to codeowners file in Management repo.
        echo ".github/*   @$_org/$_prefix-$managment_repo-owner" > ./CODEOWNERS        
        popd || exit 2
    done    

    #Temporary workaround until we see how much templating is actually required.
    docker_registry_url=$(az acr show -n "${ci_acr_name}" -o json | jq -r '.loginServer' | tr -d '\n')
        
    pushd "$_prefix-application-management/.github/actions" || exit 2
    # this warning is about filenames with spaces or globbing issues, which in this case is impossible as we
    # are looking for an exact filename match that does not have any globbing issues or spaces,
    # shellcheck disable=SC2044
    for file in $(find ./ -name "action.yaml.tmpl")
    do
        docker_login_server="$docker_registry_url" envsubst < "$file" > "${file%.*}"
        rm "$file"
    done
    popd  || exit 2
        
    #Copy Terraform Components to Application Management repo.
    info "Adding terraform to application-management repository"
    mkdir -p "$_prefix-application-management/.c12/components"
    rsync -avr --exclude='**/.terraform/' --exclude='*.tfplan' "$_file_root/../../../components/." "$_prefix-application-management/.c12/components"

    # Copy Application Source pipline and Plus Repo contence to `application-management/components/c--solutions`
    mkdir -p "$_prefix-application-management/.c12/components/ci-solutions"
    rsync -avr --exclude='README.md' "$_file_root/../../pipelines/application-src/." "$_prefix-application-management/.c12/components/ci-solutions"
    mkdir -p "$_prefix-application-management/.c12/components/ci-solutions/.c12/scripts"
    rsync -qa --progress --remove-source-files "$_prefix-application-management/.c12/components/ci-solutions/scripts/." "$_prefix-application-management/.c12/components/ci-solutions/.c12/scripts/"

    info "Commiting management repositories"
    for managment_repo in "${_builtin[@]}"; 
    do
        pushd "$_prefix-$managment_repo" || exit 2
        git add -A
        git diff-index --quiet HEAD || git commit -a -m "C12 Bootstrap - Creation of workflows and actions"
        git push
        popd || exit 2
    done

    #Push sample archetype
    info "Feeding sample archetype"
    pushd "$_prefix-archetype-management" || exit 2
    cp -R "$_file_root/../../manifests/archetype-management/." .
    git add -A
    git diff-index --quiet HEAD || git commit -a -m "C12 Bootstrap - Add demo Archetype"
    git push
    popd || exit


    info "Onboarding sample apps"
    for app_repo in "${_applications[@]}"; do
        info "Creating demo app $app_repo definition, no versions"
        #Generate the app.yaml for this app, this will trigger the pipeline and the creation of all infrastructure required,
        app_version="null" \
        aks_name=$aks_name \
        envsubst < "$_file_root/../../manifests/application-management/$app_repo.yaml" > "$_prefix-application-management/$app_repo.yaml"
    done


    pushd "$_prefix-application-management" || exit 2
    git add -A
    git commit -m "C12 Bootstrap - On board demo appplications"
    git push 
    popd || exit    

    info "Waiting for management pipelines to run"
    
    arch_completion=$(wait_for_gitgub_workflow "${_pat_username}" "${_pat_password}" "${_org}" "$_prefix-archetype-management")
    app_completion=$(wait_for_gitgub_workflow "${_pat_username}" "${_pat_password}" "${_org}" "$_prefix-application-management")
    
    if [[ "$arch_completion" != "success" ]] || [[ "$app_completion" != "success" ]] 
    then
        error "Pipelines did not run successfully: archetype-management:$arch_completion application-management:$app_completion"
        exit 55
    fi
    
    info "Pipelines completed successfully, adding demo sources to the repositories"    

    for app_repo in "${_applications[@]}"; do
        info "Seeding  demo content for $app_repo"
        
        #Seed the contents for the -src repository with the source code to be compiled and deployed.        
        git clone "https://${_pat_username}:${_pat_password}@github.com/$_org/$_prefix-$app_repo-src.git"
        cd "$_prefix-$app_repo-src"        
        
        rsync -avr --exclude='.github/.' --exclude='.github/.' "$_file_root/../../manifests/sample-app-nodejs-src/." "."
        
        git add -A
        git diff-index --quiet HEAD || git commit -a -m "Initial code import"        
        git rev-parse v0.0.0 || git tag -a v0.0.0 -m "Initial commit"
        git push -u origin master --follow-tags --force
        
        app_version=$(git describe --long --tags)

        ini_val "$_config_file" c12:generated.app_version "$app_version"
        cd ..
        sleep 1
        #Wait until the app-src has completed, so the images are available.
        app_src_completion=$(wait_for_gitgub_workflow "${_pat_username}" "${_pat_password}" "${_org}" "$_prefix-$app_repo-src")

        if [[ "$app_src_completion" != "success" ]]
        then
            error "Pipelines did not run successfully: app-src:$app_src_completion"
            exit 55
        fi
        
        #Generate the app.yaml for this app with the version we just added
        app_version=$app_version \
        aks_name=$aks_name \
        envsubst < "$_file_root/../../manifests/application-management/$app_repo.yaml" > "$_prefix-application-management/$app_repo.yaml"
        
        # commit managment repo to trigger Pipeling and creat app repos
        cd "$_prefix-application-management/"
        git add -A
        git diff-index --quiet HEAD || git commit -a -m "C12 Bootstrap -- Update $app_repo, version $app_version"
        git push
        sleep 1
        cd ..
        
        # Pushing sample Source code to the newly created (from the Application Managment Pipeline) scr repo
        # Polls for the latest run of a workflow and waits until it
        app_completion=$(wait_for_gitgub_workflow "${_pat_username}" "${_pat_password}" "${_org}" "$_prefix-application-management")
    
        if [[ "$app_completion" != "success" ]] 
        then
            error "Pipelines did not run successfully: application-management:$app_completion"
            exit 55
        fi
    done
    
    popd || exit 2
    
}