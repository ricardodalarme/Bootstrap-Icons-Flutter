import cloneRepo from './git/cloneRepo';
import svg2flutter from './svg2flutter';

async function main() {
  await cloneRepo();
  await svg2flutter();
}

main().catch((e) => console.log(e));
