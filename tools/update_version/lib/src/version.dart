import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;

String resolveReleaseVersion(Directory iconsRepoDir,
    [String? versionOverride]) {
  if (versionOverride != null && versionOverride.isNotEmpty) {
    return versionOverride;
  }

  final pkgJsonFile = File(path.join(iconsRepoDir.path, 'package.json'));
  if (!pkgJsonFile.existsSync()) {
    throw StateError(
      'Could not find package.json in icons repository at ${pkgJsonFile.path}',
    );
  }

  final data = jsonDecode(pkgJsonFile.readAsStringSync());
  if (data is Map &&
      data['version'] is String &&
      (data['version'] as String).isNotEmpty) {
    return data['version'] as String;
  }

  throw StateError('Could not find valid version field in ${pkgJsonFile.path}');
}
