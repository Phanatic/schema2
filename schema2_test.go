package main


import (
	"fmt"
	"log"
	"time"
	"github.com/hpcloud/hce-cli/hce"
)


func main() {


	fmt.Println( "hce-cli-two: " + time.Now().String())


}



func all_test() {

	// Do some user stuff
	userApi := hce.NewUserApi()

	user := hce.User{nil, "neilotoole@apache.org", "Neil O'Toole", nil}
	user, _ = userApi.CreateUser(user)
	defer userApi.DeleteUser(user.UserId)
	log.Println(user)
	user, _ = userApi.GetUser(user.UserId)
	log.Println(user)


	user.Email = "neil.otoole@hpe.com"
	user, _ = userApi.UpdateUser(user.UserId, user)


	log.Println(user)

	users, _ := userApi.GetUsers()
	log.Println(users)


	// Do some VCS stuff
	vcsApi := hce.NewVcsApi()

	// Unfortunately, the swagger-codegen Go generator does not currently produce enum types ("GITHUB")
	vcs := hce.Vcs{nil, "GITHUB", "https://hce.github.com", "https://github.com","GitHub.com"}
	vcs, _ = vcsApi.AddVcs(vcs)
	defer vcsApi.RemoveVcs(vcs.VcsId)
	log.Println(vcs)

	vcs, _ = vcsApi.GetVcs(vcs.VcsId)
	log.Println(vcs)

	vcses, _ := vcsApi.GetVcses()
	log.Println(vcses)


	userVcsCredential, _ := generateCredential()
	defer cleanupCredential(userVcsCredential)
	vcsAccount := hce.VcsAccount{nil, vcs.VcsId, user.UserId, "githubuserid12345", userVcsCredential}

	vcsAccount, _ = vcsApi.AddVcsAccount(vcsAccount)
	defer vcsApi.RemoveVcsAccount(vcsAccount.VcsAccountId)
	log.Println(vcsAccount)

	// Get all GitHub VCS accounts
	vcsAccounts, _ := vcsApi.FindVcsAccount(vcs.VcsId, nil, nil)
	log.Println(vcsAccounts)

	// Find our HCE user's GitHub account
	vcsAccounts, _ = vcsApi.FindVcsAccount(vcs.VcsId, user.UserId, nil)

	// Find our HCE user, given a GitHub user id
	vcsAccounts, _ = vcsApi.FindVcsAccount(vcs.VcsId, nil, "githubuserid12345")


	// Do our container stuff
	containerApi := hce.NewContainerApi()

	containerRegistryCredential, _ := generateCredential()
	defer cleanupCredential(containerRegistryCredential)

	registry := hce.ContainerRegistry{nil, "DOCKER", "DockerHub", "https://hub.docker.com", containerRegistryCredential.CredentialId}
	registry, _ = containerApi.AddContainerRegistry(registry)
	defer containerApi.RemoveContainerRegistry(registry.RegistryId)
	log.Println(registry)
	registry, _ = containerApi.GetContainerRegistry(registry.RegistryId)
	log.Println(registry)
	registries, _ := containerApi.GetContainerRegistries()
	log.Println(registries)


	image := hce.ContainerImage{nil, "DOCKER", registry.RegistryId, "java", "openjdk-8-jdk", "OpenJDK 8"}
	image, _ = containerApi.AddContainerImage(image)
	log.Println(image)
	defer containerApi.RemoveContainerImage(image.ImageId)

	image, _ = containerApi.GetContainerImage(image.ImageId)
	log.Println(image)
	images, _ := containerApi.GetContainerImages()
	log.Println(images)


	buildContainer := hce.BuildContainer{image.ImageId, "Java"}
	buildContainer, _ = containerApi.AddBuildContainer(buildContainer)
	defer containerApi.RemoveBuildContainer(buildContainer.BuildContainerId)

	buildContainer, _ = containerApi.GetBuildContainer(buildContainer.BuildContainerId)
	log.Println(buildContainer)
	buildContainers, _ := containerApi.GetBuildContainers()
	log.Println(buildContainers)




	webhookCredential, _ := generateCredential()
	defer cleanupCredential(webhookCredential)


	ghRepo := hce.GitHubRepo{nil, "12345", "neilotoole", "ssh:/xyz", "neilotoole/hce-cli", "https://localhost:3001/auth/github", "12345", 1, "6weadsfal32", "https://github.com/...", webhookCredential.CredentialId}

	ghRepo, _ = vcsApi.AddRepo(ghRepo)
	defer vcsApi.RemoveRepo(ghRepo.RepoId)

	ghRepo, _ = vcsApi.GetRepo(ghRepo.RepoId)
	log.Println(ghRepo)
	repos, _ := vcsApi.GetRepos()
	log.Println(repos)


	// Create a project
	projectApi := hce.NewProjectApi()

	repoCredential, _ := generateCredential()
	defer cleanupCredential(repoCredential)

	project := hce.Project{nil, "My First Project", ghRepo.RepoId, repoCredential.CredentialId, nil}
	project, _ = projectApi.CreateProject(project)
	log.Println(project)
	defer projectApi.DeleteProject(project.ProjectId)

	project, _ = projectApi.GetProject(project.ProjectId)
	log.Println(project)


	// Get all projects
	projects, _ := projectApi.GetProjects(nil, nil)

	projectApi.AddMember(project.ProjectId, user.UserId)
	defer projectApi.RemoveMember(project.ProjectId, user.UserId)
	// Get projects that this user is a member of
	projects, _ = projectApi.GetProjects(user.UserId, nil)
	log.Println(projects)
	members, _ := projectApi.GetProjectMembers(project.ProjectId)
	log.Println(members)


	projectApi.AddOwner(project.ProjectId, user.UserId)
	defer projectApi.RemoveOwner(project.ProjectId, user.UserId)
	owners, _ := projectApi.GetProjectOwners(project.ProjectId)
	log.Println(owners)


	// Add a post-deploy task...
	stormrunnerCredential, _ := generateCredential()
	stormrunnerConfig := `params:
  - endpoint_url: https://stormrunner.example.com/sr
  - username: {{CREDENTIAL_KEY}}
  - password: {{CREDENTIAL_VALUE}}`

	stormrunnerTask := hce.PipelineTask{nil, "com.hpe.stormrunner.test", project.ProjectId, "POST_DEPLOY", stormrunnerConfig, stormrunnerCredential}
	stormrunnerTask, _ = projectApi.AddPipelineTask(stormrunnerTask)
	log.Println(stormrunnerTask)


	// Deployment targets (Environments)!

	deploymentApi := hce.NewDeploymentApi()

	targetCredential, _ := generateCredential()
	defer cleanupCredential(targetCredential)


	deploymentTarget := hce.CloudFoundryDeploymentTarget{nil, "https://cf1.example.com", "CloudFoundryDeploymentTarget", "HPCloud", user.UserId, targetCredential.CredentialId, "This is a really swell env", "My First Environment", "my space" }

	deploymentTarget, _ = deploymentApi.AddDeploymentTarget(deploymentTarget)
	defer deploymentApi.RemoveDeploymentTarget(deploymentTarget.TargetId)
	log.Println(deploymentTarget)

	deploymentTarget, _ = deploymentApi.GetDeploymentTarget(deploymentTarget.TargetId)
	log.Println(deploymentTarget)

	// Get all envs
	deploymentTargets, _ := deploymentApi.GetDeploymentTargets(nil)
	log.Println(deploymentTargets)

	// Get envs that a user has access to
	deploymentTargets, _ = deploymentApi.GetDeploymentTargets(user.UserId)
	log.Println(deploymentTargets)

	deploymentTarget.Label = "My updated environment"
	deploymentTarget, _ = deploymentApi.UpdateTarget(deploymentTarget.TargetId, deploymentTarget)
	log.Println(deploymentTarget)


	// FIXME: Need to decide the relationship between Project and Environments... is it 1:1, or 1:N ?
	// if 1:1, then env is a field on Project
	// if not, then need to map the two... but does that mean that every deployment of a Project
	// will always be deployed to multiple targets?


	// Let's get building!
	buildApi := hce.NewBuildApi()

	// Let's get the trigger so we can start a build
	pipelineTrigger := hce.ManualPipelineTrigger{"753be09...02bdd767819cc8", "http://avatarurl", "neilotoole", nil, nil, "ManualBuildTrigger", "I started a build!", user.UserId, project.ProjectId}

	pipelineTrigger, _ = buildApi.TriggerPipelineBuild(pipelineTrigger)
	log.Println(pipelineTrigger)

	pipelineTrigger, _ = buildApi.GetPipelineTrigger(pipelineTrigger.TriggerId)

	pipelineTrigger = hce.PullRequestPipelineTrigger{"http://compareUrl", "webhookId_1234", "http://avatarurl", "neilotoole", nil, "http://commitUrl",nil, "PullRequestBuildTrigger", "commitSha234234jasdf0", "Trigger from GitHub PR 666", "gh_pr_id_12345"}
	pipelineTrigger = buildApi.TriggerPipelineBuild(pipelineTrigger)





	// Adding the build trigger will have kicked off a build
	builds, _ := buildApi.GetBuilds(project.ProjectId)
	log.Println(builds)

	build, _ := buildApi.GetBuild(builds[0].BuildId)
	defer buildApi.DeleteBuild(build.BuildId)
	log.Println(build)


	// Concourse calls back to here
	pipelineEvent := hce.PipelineEvent{nil, build.BuildId, "concourse.test", "PENDING", "Some message", nil, nil, nil}
	buildApi.PipelineEventOccurred(pipelineEvent)

	pipelineEvent = hce.PipelineEvent{nil, build.BuildId, "concourse.test", "SUCCESS", "Some message", nil, nil, nil}
	buildApi.PipelineEventOccurred(pipelineEvent)

	deploymentApi = hce.NewDeploymentApi()
	// Concourse calls back to here
	deployment := hce.Deployment{nil, project.ProjectId, build.BuildId, deploymentTarget.TargetId, "myapplicationid", "http://mydeployedapp.example.com", nil}
	deployment, _ = deploymentApi.DeploymentOccurred(deployment)

	// Back to client calling the api
	deployments, _ := deploymentApi.GetDeployments(project.ProjectId, nil)

	// Or get by build
	deployments, _ = deploymentApi.GetDeployments(nil, build.BuildId)
	log.Println("Deployment Browse URL:" + deployments[0].BrowseUrl)

	log.Println(build.Result) // should be SUCCESS


	// FIXME: need to add example usage for PostDeployActions, and Artifacts

}




// This function always generates a USERNAME_PASSWORD credential... in the real
// world our test cases would be generating different types of credential.
func generateCredential() (hce.Credential, error){
	securityApi := hce.NewSecurityApi()
	credential := hce.Credential{nil, "USERNAME_PASSWORD", "myusername", "mypassword", "Neil's DockerHub username/password", nil}
	credential, err := securityApi.StoreCredential(credential)
	log.Println(credential)
	return credential, err
}

func cleanupCredential(credential hce.Credential) {
	securityApiClient := hce.NewSecurityApi()
	securityApiClient.ForgetCredential(credential)
}
