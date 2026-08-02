import 'dart:io';

import 'package:path/path.dart' as path;

import 'src/generator.dart';
import 'src/parser.dart';
import 'src/version.dart';

export 'src/generator.dart';
export 'src/models.dart';
export 'src/normalize_name.dart';
export 'src/parser.dart';
export 'src/version.dart';

Directory findRepositoryRoot() {
  var dir = Directory.current.absolute;
  while (dir.parent.path != dir.path) {
    final pubspec = File(path.join(dir.path, 'pubspec.yaml'));
    if (pubspec.existsSync()) {
      final content = pubspec.readAsStringSync();
      if (content.contains('name: bootstrap_icons')) {
        return dir;
      }
    }
    dir = dir.parent;
  }
  return Directory.current.absolute;
}

Future<void> runUpdateVersion({
  String? versionOverride,
  String repositoryUrl = 'https://github.com/twbs/icons.git',
  String fontName = 'BootstrapIcons',
  String fontPackage = 'bootstrap_icons',
}) async {
  final projectRoot = findRepositoryRoot();
  final iconsRepoDir = Directory(
      path.join(projectRoot.path, 'tools', 'update_version', 'icons'));
  final svgInputDir = Directory(path.join(iconsRepoDir.path, 'icons'));
  final outputFontFile =
      File(path.join(projectRoot.path, 'fonts', '$fontName.otf'));
  final outputDartFile =
      File(path.join(projectRoot.path, 'lib', 'bootstrap_icons.dart'));

  if (!svgInputDir.existsSync()) {
    print('Cloning icon repository from $repositoryUrl...');
    iconsRepoDir.createSync(recursive: true);
    final result = await Process.run('git', [
      'clone',
      '--depth',
      '1',
      repositoryUrl,
      iconsRepoDir.path,
    ]);

    if (result.exitCode != 0) {
      throw Exception('Failed to clone repository: ${result.stderr}');
    }
    print('Repository cloned to ${iconsRepoDir.path}');
  } else {
    print('Using existing SVGs in ${svgInputDir.path}');
  }

  final releaseVersion = resolveReleaseVersion(iconsRepoDir, versionOverride);
  print('Resolved release version: v$releaseVersion');

  print('Generating font file (${outputFontFile.path})...');
  outputFontFile.parent.createSync(recursive: true);
  final parseResult = await parseSvgIcons(
    inputDir: svgInputDir,
    outputFile: outputFontFile,
    fontName: fontName,
  );

  print('Generating Dart file (${outputDartFile.path})...');
  outputDartFile.parent.createSync(recursive: true);
  final dartCode = generateBootstrapIconsClass(
    fontName: fontName,
    fontPackage: fontPackage,
    icons: parseResult.icons,
    version: releaseVersion,
  );

  outputDartFile.writeAsStringSync(dartCode);
  print(
      'Successfully generated ${parseResult.icons.length} icons in ${outputDartFile.path}!');
}
