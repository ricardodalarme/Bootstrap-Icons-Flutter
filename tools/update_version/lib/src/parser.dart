import 'dart:io';
import 'dart:typed_data';
import 'package:icon_font_generator/icon_font_generator.dart';
import 'package:path/path.dart' as path;

import 'models.dart';
import 'normalize_name.dart';

class ParseResult {
  final File fontFile;
  final List<IconItem> icons;

  ParseResult({
    required this.fontFile,
    required this.icons,
  });
}

Future<ParseResult> parseSvgIcons({
  required Directory inputDir,
  required File outputFile,
  required String fontName,
  bool normalize = true,
  bool ignoreShapes = true,
}) async {
  final svgFiles = inputDir
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.svg'))
      .toList();

  svgFiles.sort((a, b) => a.path.compareTo(b.path));

  final Map<String, String> svgMap = {};
  for (final file in svgFiles) {
    final name = path.basenameWithoutExtension(file.path);
    svgMap[name] = file.readAsStringSync();
  }

  final result = svgToOtf(
    svgMap: svgMap,
    fontName: fontName,
    normalize: normalize,
    ignoreShapes: ignoreShapes,
  );

  final bd = ByteData(result.font.size);
  result.font.encodeToBinary(bd);
  outputFile.writeAsBytesSync(bd.buffer.asUint8List());

  final List<IconItem> icons = [];

  for (final glyph in result.glyphList) {
    final svgName = glyph.metadata.name ?? 'unnamed';
    final charCode = glyph.metadata.charCode ?? 0;
    final hex = charCode.toRadixString(16);

    icons.add(IconItem(
      name: normalizeName(svgName),
      svgName: svgName,
      codepointHex: hex,
    ));
  }

  return ParseResult(
    fontFile: outputFile,
    icons: icons,
  );
}
