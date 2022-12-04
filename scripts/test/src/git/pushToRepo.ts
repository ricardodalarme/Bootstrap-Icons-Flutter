import type { GitAuth } from 'isomorphic-git';
import git from 'isomorphic-git';
import http from 'isomorphic-git/http/node';
import { createFsFromVolume, Volume } from 'memfs';

async function pushToRepo(
  githubOrganization: string,
  githubRepository: string,
  message: string,
  repoContent: Record<string, string>,
): Promise<void> {
  const dir = `/`;
  const defaultBranch = `main`;
  const volume = Volume.fromJSON(repoContent, dir);
  const fs = createFsFromVolume(volume);
  const filepath = Object.keys(repoContent);

  await git.add({ fs, dir, filepath });

  const author = {
    name: `ricardodalarme`,
  };

  await git.commit({ fs, dir, message, author });

  const onAuth = (): GitAuth => ({
    username: 'ricardodalarme',
    password: 'token',
  });
  const url = `https://github.com/${githubOrganization}/${githubRepository}.git`;

  await git.push({
    fs,
    http,
    dir,
    url,
    remoteRef: defaultBranch,
    onAuth,
  });
}

export default pushToRepo;
