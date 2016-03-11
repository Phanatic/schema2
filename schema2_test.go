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
	userApiClient := hce.NewUserApi()

	user := hce.User{nil, "neilotoole@apache.org", "Neil O'Toole", nil}
	user, _ = userApiClient.CreateUser(user)
	defer userApiClient.DeleteUser(user.UserId)
	log.Println(user)
	user, _ = userApiClient.GetUser(user.UserId)
	log.Println(user)


	user.Email = "neil.otoole@hpe.com"
	user, _ = userApiClient.UpdateUser(user.UserId, user)
	log.Println(user)

	users, _ := userApiClient.GetUsers()
	log.Println(users)


	// Do some VCS stuff
	vcsApiClient := hce.NewVcsApi()

	// Unfortunately, the swagger-codegen Go generator does not currently produce enum types ("GITHUB")
	vcs := hce.Vcs{nil, "GITHUB", "https://hce.github.com", "https://github.com","GitHub.com"}
	vcs, _ = vcsApiClient.AddVcs(vcs)
	defer vcsApiClient.RemoveVcs(vcs.VcsId)
	log.Println(vcs)

	vcs, _ = vcsApiClient.GetVcs(vcs.VcsId)
	log.Println(vcs)

	vcses, _ := vcsApiClient.GetVcses()
	log.Println(vcses)


	userVcsCredential, _ := generateCredential()
	defer cleanupCredential(userVcsCredential)
	vcsAccount := hce.VcsAccount{nil, vcs.VcsId, user.UserId, "githubuserid12345", userVcsCredential}

	vcsAccount, _ = vcsApiClient.AddVcsAccount(vcsAccount)
	defer vcsApiClient.RemoveVcsAccount(vcsAccount.VcsAccountId)
	log.Println(vcsAccount)

	// Get all GitHub VCS accounts
	vcsAccounts, _ := vcsApiClient.FindVcsAccount(vcs.VcsId, nil, nil)
	log.Println(vcsAccounts)

	// Find our HCE user's GitHub account
	vcsAccounts, _ = vcsApiClient.FindVcsAccount(vcs.VcsId, user.UserId, nil)

	// Find our HCE user, given a GitHub user id
	vcsAccounts, _ = vcsApiClient.FindVcsAccount(vcs.VcsId, nil, "githubuserid12345")


	// Do our container stuff
	containerApiClient := hce.NewContainerApi()

	containerRegistryCredential, _ := generateCredential()
	defer cleanupCredential(containerRegistryCredential)

	registry := hce.ContainerRegistry{nil, "DOCKER", "DockerHub", "https://hub.docker.com", containerRegistryCredential.CredentialId}
	registry, _ = containerApiClient.AddContainerRegistry(registry)
	defer containerApiClient.RemoveContainerRegistry(registry.RegistryId)
	log.Println(registry)
	registry, _ = containerApiClient.GetContainerRegistry(registry.RegistryId)
	log.Println(registry)
	registries, _ := containerApiClient.GetContainerRegistries()
	log.Println(registries)


	image := hce.ContainerImage{nil, "DOCKER", registry.RegistryId, "java", "openjdk-8-jdk", "OpenJDK 8"}
	image, _ = containerApiClient.AddContainerImage(image)
	log.Println(image)
	defer containerApiClient.RemoveContainerImage(image.ImageId)

	image, _ = containerApiClient.GetContainerImage(image.ImageId)
	log.Println(image)
	images, _ := containerApiClient.GetContainerImages()
	log.Println(images)


	buildContainer := hce.BuildContainer{image.ImageId, "Java"}
	buildContainer, _ = containerApiClient.AddBuildContainer(buildContainer)
	defer containerApiClient.RemoveBuildContainer(buildContainer.BuildContainerId)

	buildContainer, _ = containerApiClient.GetBuildContainer(buildContainer.BuildContainerId)
	log.Println(buildContainer)
	buildContainers, _ := containerApiClient.GetBuildContainers()
	log.Println(buildContainers)


	// Set up a repo
	repoApiClient := hce.NewRepoApi()

	webhookCredential, _ := generateCredential()
	defer cleanupCredential(webhookCredential)


	ghRepo := hce.GitHubRepo{nil, "12345", "neilotoole", "ssh:/xyz", "neilotoole/hce-cli", "https://localhost:3001/auth/github", "12345", 1, "6weadsfal32", "https://github.com/...", webhookCredential.CredentialId}

	ghRepo, _ = repoApiClient.AddRepo(ghRepo)
	defer repoApiClient.RemoveRepo(ghRepo.RepoId)

	ghRepo, _ = repoApiClient.GetRepo(ghRepo.RepoId)
	log.Println(ghRepo)
	repos, _ := repoApiClient.GetRepos()
	log.Println(repos)


	// Create a project
	projectApiClient := hce.NewProjectApi()

	repoCredential, _ := generateCredential()
	defer cleanupCredential(repoCredential)

	project := hce.Project{nil, "My First Project", ghRepo.RepoId, repoCredential.CredentialId, nil}
	project, _ = projectApiClient.CreateProject(project)
	log.Println(project)
	defer projectApiClient.DeleteProject(project.ProjectId)

	project, _ = projectApiClient.GetProject(project.ProjectId)
	log.Println(project)


	// Get all projects
	projects, _ := projectApiClient.GetProjects(nil, nil)

	projectApiClient.AddMember(project.ProjectId, user.UserId)
	defer projectApiClient.RemoveMember(project.ProjectId, user.UserId)
	// Get projects that this user is a member of
	projects, _ = projectApiClient.GetProjects(user.UserId, nil)
	log.Println(projects)
	members, _ := projectApiClient.GetProjectMembers(project.ProjectId)
	log.Println(members)


	projectApiClient.AddOwner(project.ProjectId, user.UserId)
	defer projectApiClient.RemoveOwner(project.ProjectId, user.UserId)
	owners, _ := projectApiClient.GetProjectOwners(project.ProjectId)
	log.Println(owners)


	// Environments!

	environmentClientApi := hce.NewEnvironmentApi()

	environmentCredential, _ := generateCredential()
	defer cleanupCredential(environmentCredential)


	environment := hce.CloudFoundryEnvironment{nil, "https://cf1.example.com", "CloudFoundryEnvironment", "HPCloud", user.UserId, environmentCredential.CredentialId, "This is a really swell env", "My First Environment", "my space" }

	environment, _ = environmentClienthce.AddEnvironment(environment)
	defer environmentClienthce.RemoveEnvironment(environment.EnvironmentId)
	log.Println(environment)

	environment, _ = environmentClienthce.GetEnvironment(environment.EnvironmentId)
	log.Println(environment)

	// Get all envs
	environments, _ := environmentClienthce.GetEnvironments(nil)
	log.Println(environments)

	// Get envs that a user has access to
	environments, _ = environmentClienthce.GetEnvironments(user.UserId)
	log.Println(environments)

	environment.Label = "My updated environment"
	environment, _ = environmentClienthce.UpdateEnvironment(environment.EnvironmentId, environment)
	log.Println(environment)


	// FIXME: Need to decide the relationship between Project and Environments... is it 1:1, or 1:N ?
	// if 1:1, then env is a field on Project
	// if not, then need to map the two... but does that mean that every deployment of a Project
	// will always be deployed to multiple targets?


	// Let's get building!
	buildApiClient := hce.NewBuildApi()

	// Let's get the trigger so we can start a build
	buildTrigger := hce.ManualBuildTrigger{"753be09...02bdd767819cc8", "http://avatarurl", "neilotoole", nil, nil, "ManualBuildTrigger", "I started a build!", user.UserId, project.ProjectId}

	buildTrigger, _ = buildApiClient.TriggerBuild(buildTrigger)
	log.Println(buildTrigger)

	buildTrigger, _ = buildApiClient.GetBuildTrigger(buildTrigger.TriggerId)

	buildTrigger = hce.PullRequestBuildTrigger{"http://compareUlr", "webhookId_1234", "http://avatarurl", "neilotoole", nil, "http://commitUrl",nil, "PullRequestBuildTrigger", "commitSha234234jasdf0", "Trigger from GitHub PR 666", "gh_pr_id_12345"}
	buildTrigger = buildApiClient.TriggerBuild(buildTrigger)





	// Adding the build trigger will have kicked off a build
	builds, _ := buildApiClient.GetBuilds(project.ProjectId)
	log.Println(builds)

	build, _ := buildApiClient.GetBuild(builds[0].BuildId)
	defer buildApiClient.DeleteBuild(build.BuildId)
	log.Println(build)


	// Concourse calls back to here
	buildEvent := hce.BuildEvent{nil, build.BuildId, "concourse.test", "PENDING", "Some message", nil, nil, nil}
	buildApiClient.BuildEventOccurred(buildEvent)

	buildEvent = hce.BuildEvent{nil, build.BuildId, "concourse.test", "SUCCESS", "Some message", nil, nil, nil}
	buildApiClient.BuildEventOccurred(buildEvent)

	deploymentApiClient := hce.NewDeploymentApi()
	// Concourse calls back to here
	deployment := hce.Deployment{nil, project.ProjectId, build.BuildId, environment.EnvironmentId, "myapplicationid", "http://mydeployedapp.example.com", nil}
	deployment, _ = deploymentApiClient.DeploymentOccurred(deployment)

	// Back to client calling the api
	deployments, _ := deploymentApiClient.GetDeployments(project.ProjectId, nil)

	// Or get by build
	deployments, _ = deploymentApiClient.GetDeployments(nil, build.BuildId)
	log.Println("Deployment Browse URL:" + deployments[0].BrowseUrl)

	log.Println(build.Result) // should be SUCCESS


	// FIXME: need to add example usage for PostDeployActions, and Artifacts

}




// This function always generates a USERNAME_PASSWORD credential... in the real
// world our test cases would be generating different types of credential.
func generateCredential() (hce.Credential, error){
	securityApiClient := hce.NewSecurityApi()
	credential := hce.Credential{nil, "USERNAME_PASSWORD", "myusername", "mypassword", "Neil's DockerHub username/password", nil}
	credential, err := securityApiClient.StoreCredential(credential)
	log.Println(credential)
	return credential, err
}

func cleanupCredential(credential hce.Credential) {
	securityApiClient := hce.NewSecurityApi()
	securityApiClient.ForgetCredential(credential)
}
