import git from 'isomorphic-git';
import http from 'isomorphic-git/http/node';
import fs from 'fs';

async function cloneRepo(): Promise<void> {
  console.log('Cloning the repository');
  const dir = `./icons`;
  const url = `https://github.com/twbs/icons.git`;

  fs.mkdirSync(dir, { recursive: true });

  await git.clone({
    fs,
    http,
    dir,
    url,
  });

  console.log(`Repository cloned to ${dir}`);
}

export default cloneRepo;
