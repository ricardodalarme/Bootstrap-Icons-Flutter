import 'package:update_version/update_version.dart';

void main(List<String> args) async {
  final versionOverride = args.isNotEmpty ? args.first : null;
  await runUpdateVersion(versionOverride: versionOverride);
}
