declare function pushToRepo(githubOrganization: string, githubRepository: string, message: string, repoContent: Record<string, string>): Promise<void>;
export default pushToRepo;
