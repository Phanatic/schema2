package main


import (
	"fmt"
	"log"
	"time"
	"github.com/hpcloud/hce-cli/api"
)


func main() {


	fmt.Println( "hce-cli-two: " + time.Now().String())


}



func all_test() {

	// Do some user stuff
	userApiClient := api.NewUserApi()

	user := api.User{nil, "neilotoole@apache.org", "Neil O'Toole", nil}
	user, _ = userApiClient.CreateUser(user)
	defer userApiClient.DeleteUser(user.UserId)
	log.Println(user)
	user, _ = userApiClient.GetUser(user.UserId)
	log.Println(user)

	user, _ = userApiClient.GetUserByGithubId("123456")
	log.Println(user)

	user.Email = "neil.otoole@hpe.com"
	user, _ = userApiClient.UpdateUser(user.UserId, user)
	log.Println(user)

	users, _ := userApiClient.GetUsers()
	log.Println(users)


	// Do some VCS stuff
	vcsApiClient := api.NewVcsApi()

	// Unfortunately, the swagger-codegen Go generator does not currently produce enum types ("GITHUB")
	vcs := api.Vcs{nil, "GITHUB", "https://api.github.com", "https://github.com","GitHub.com"}
	vcs, _ = vcsApiClient.RegisterVcs(vcs)
	defer vcsApiClient.UnregisterVcs(vcs.VcsId)
	log.Println(vcs)

	vcs, _ = vcsApiClient.GetVcs(vcs.VcsId)
	log.Println(vcs)

	vcses, _ := vcsApiClient.GetVcses()
	log.Println(vcses)


	userVcsCredential, _ := generateCredential()
	defer cleanupCredential(userVcsCredential)
	vcsAccount := api.VcsAccount{nil, vcs.VcsId, user.UserId, "githubuserid12345", userVcsCredential}

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
	containerApiClient := api.NewContainerApi()

	containerRegistryCredential, _ := generateCredential()
	defer cleanupCredential(containerRegistryCredential)

	registry := api.ContainerRegistry{nil, "DOCKER", "DockerHub", "https://hub.docker.com", containerRegistryCredential.CredentialId}
	registry, _ = containerApiClient.AddContainerRegistry(registry)
	defer containerApiClient.RemoveContainerRegistry(registry.RegistryId)
	log.Println(registry)
	registry, _ = containerApiClient.GetContainerRegistry(registry.RegistryId)
	log.Println(registry)
	registries, _ := containerApiClient.GetContainerRegistries()
	log.Println(registries)


	image := api.ContainerImage{nil, "DOCKER", registry.RegistryId, "java", "openjdk-8-jdk", "OpenJDK 8"}
	image, _ = containerApiClient.AddContainerImage(image)
	log.Println(image)
	defer containerApiClient.RemoveContainerImage(image.ImageId)

	image, _ = containerApiClient.GetContainerImage(image.ImageId)
	log.Println(image)
	images, _ := containerApiClient.GetContainerImages()
	log.Println(images)


	buildContainer := api.BuildContainer{image.ImageId, "Java"}
	buildContainer, _ = containerApiClient.AddBuildContainer(buildContainer)
	defer containerApiClient.RemoveBuildContainer(buildContainer.BuildContainerId)

	buildContainer, _ = containerApiClient.GetBuildContainer(buildContainer.BuildContainerId)
	log.Println(buildContainer)
	buildContainers, _ := containerApiClient.GetBuildContainers()
	log.Println(buildContainers)


	// Set up a repo
	repoApiClient := api.NewRepoApi()

	webhookCredential, _ := generateCredential()
	defer cleanupCredential(webhookCredential)


	ghRepo := api.GitHubRepo{nil, "12345", "neilotoole", "ssh:/xyz", "neilotoole/hce-cli", "https://localhost:3001/auth/github", "12345", 1, "6weadsfal32", "https://github.com/...", webhookCredential.CredentialId}

	ghRepo, _ = repoApiClient.AddRepo(ghRepo)
	defer repoApiClient.RemoveRepo(ghRepo.RepoId)

	ghRepo, _ = repoApiClient.GetRepo(ghRepo.RepoId)
	log.Println(ghRepo)
	repos, _ := repoApiClient.GetRepos()
	log.Println(repos)


	// Create a project
	projectApiClient := api.NewProjectApi()

	repoCredential, _ := generateCredential()
	defer cleanupCredential(repoCredential)

	project := api.Project{nil, "My First Project", ghRepo.RepoId, repoCredential.CredentialId, nil}
	project, _ = projectApiClient.CreateProject(project)
	defer projectApiClient.DeleteProject(project.ProjectId)

	project, _ = projectApiClient.GetProject(project.ProjectId)



	projectApiClient.AddMember(project.ProjectId, user.UserId)
	defer projectApiClient.RemoveMember(project.ProjectId, user.UserId)
	projects, _ := projectApiClient.GetProjectsForUser(user.UserId)
	log.Println(projects)
	members, _ := projectApiClient.GetProjectMembers(project.ProjectId)
	log.Println(members)


	projectApiClient.AddOwner(project.ProjectId, user.UserId)
	defer projectApiClient.RemoveOwner(project.ProjectId, user.UserId)
	owners, _ := projectApiClient.GetProjectOwners(project.ProjectId)
	log.Println(owners)

}




// This function always generates a USERNAME_PASSWORD credential... in the real
// world our test cases would be generating different types of credential.
func generateCredential() (api.Credential, error){
	securityApiClient := api.NewSecurityApi()
	credential := api.Credential{nil, "USERNAME_PASSWORD", "myusername", "mypassword", "Neil's DockerHub username/password", nil}
	credential, err := securityApiClient.StoreCredential(credential)
	log.Println(credential)
	return credential, err
}

func cleanupCredential(credential api.Credential) {
	securityApiClient := api.NewSecurityApi()
	securityApiClient.ForgetCredential(credential)
}
