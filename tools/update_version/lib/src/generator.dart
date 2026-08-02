import 'models.dart';

const String _header = """
library bootstrap_icons;

import 'package:flutter/widgets.dart';

/// Identifiers for all official [Bootstrap Icons](https://icons.getbootstrap.com/).
///
/// Use this class to reference icons by name:
///
/// ```dart
/// Icon(BootstrapIcons.alarm)
/// ```
///
/// See also:
///  * [Bootstrap Icons Catalog](https://icons.getbootstrap.com/)
""";

String generateBootstrapIconsClass({
  required String fontName,
  required String fontPackage,
  required List<IconItem> icons,
  required String version,
}) {
  final buffer = StringBuffer(_header);

  buffer.writeln('abstract class $fontName {');
  buffer.writeln('  $fontName._();\n');

  for (final icon in icons) {
    buffer.writeln("""
  /// Bootstrap icon `${icon.name}` (`${icon.svgName}.svg`).
  ///
  /// ![${icon.svgName}](https://raw.githubusercontent.com/twbs/icons/v$version/icons/${icon.svgName}.svg)
  static const ${icon.name} = IconData(0x${icon.codepointHex}, fontFamily: "$fontName", fontPackage: "$fontPackage");
""");
  }

  buffer.writeln('}');
  return buffer.toString();
}
