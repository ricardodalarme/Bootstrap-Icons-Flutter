import fs from 'node:fs';
import { snakeCase } from 'change-case';
import path from 'path';
import { generateDartFile } from './generator';
import { parseIcons } from './parser';

const Options = {
  input: './icons/icons/',
  dartOutput: '../../lib/',
  fontOutput: '../../fonts/',
  fontName: 'BootstrapIcons',
  fontPackage: 'bootstrap_icons',
  height: 512,
  version: '1.13.1',
};

export default async function () {
  const { input, dartOutput, fontOutput, fontName, fontPackage, height } =
    Options;

  console.log('Generating font from SVGs');

  const { ttf, icons } = await parseIcons({
    input,
    fontName,
    height,
  });

  console.log('Generating TTF file');
  fs.writeFileSync(path.join(fontOutput, `${fontName}.ttf`), ttf);

  const releaseVersion = getReleaseVersion(input, dartOutput);

  console.log('Generating Dart file');
  const fileContent = generateDartFile({
    fontName,
    fontPackage,
    icons,
    version: releaseVersion,
  });

  fs.writeFileSync(
    path.join(dartOutput, `${snakeCase(fontName)}.dart`),
    fileContent,
  );
}

function getReleaseVersion(inputPath: string, dartOutputPath: string): string {
  const packageJsonPath = path.join(inputPath, '../package.json');
  if (fs.existsSync(packageJsonPath)) {
    try {
      const pkg = JSON.parse(fs.readFileSync(packageJsonPath, 'utf8'));
      if (pkg.version) {
        return pkg.version;
      }
    } catch (_) {}
  }

  const pubspecPath = path.resolve(dartOutputPath, '../pubspec.yaml');
  if (fs.existsSync(pubspecPath)) {
    try {
      const pubspec = fs.readFileSync(pubspecPath, 'utf8');
      const match = pubspec.match(/^version:\s*([0-9.]+)/m);
      if (match?.[1]) {
        return match[1];
      }
    } catch (_) {}
  }

  return Options.version;
}
