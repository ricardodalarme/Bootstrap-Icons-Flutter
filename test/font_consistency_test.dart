import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

const String _iconsFilePath = 'lib/bootstrap_icons.dart';
const String _fontFilePath = 'fonts/BootstrapIcons.ttf';

/// Tag identifier for the `cmap` table in TrueType fonts ('cmap' = 0x636D6170).
const int _kCmapTag = 0x636D6170;

/// Parses `lib/bootstrap_icons.dart` to extract all icon codepoints.
Set<int> _parseDartCodepoints() {
  final content = File(_iconsFilePath).readAsStringSync();
  final pattern = RegExp(r'IconData\(\s*0x([0-9A-Fa-f]+)');
  return pattern
      .allMatches(content)
      .map((match) => int.parse(match.group(1)!, radix: 16))
      .toSet();
}

/// Parses `fonts/BootstrapIcons.ttf` `cmap` table and returns all supported codepoints.
Set<int> _parseFontCodepoints() {
  final bytes = File(_fontFilePath).readAsBytesSync();
  final data = ByteData.sublistView(bytes);

  // Offset Subtable: numTables is uint16 at offset 4
  final numTables = data.getUint16(4);
  int? cmapOffset;

  // Table Directory starts at offset 12; each entry is 16 bytes (tag, checksum, offset, length)
  for (var i = 0; i < numTables; i++) {
    final entryOffset = 12 + i * 16;
    if (data.getUint32(entryOffset) == _kCmapTag) {
      cmapOffset = data.getUint32(entryOffset + 8);
      break;
    }
  }

  if (cmapOffset == null) {
    throw StateError('cmap table not found in $_fontFilePath');
  }

  // cmap Header: numSubtables is uint16 at cmapOffset + 2
  final numSubtables = data.getUint16(cmapOffset + 2);
  final coverage = <int>{};

  // Encoding Records start at cmapOffset + 4; each record is 8 bytes (platformID, encodingID, subtableOffset)
  for (var i = 0; i < numSubtables; i++) {
    final recordOffset = cmapOffset + 4 + i * 8;
    final subtableOffset = cmapOffset + data.getUint32(recordOffset + 4);
    final format = data.getUint16(subtableOffset);

    if (format == 4) {
      _parseCmapFormat4(data, subtableOffset, coverage);
    } else if (format == 12) {
      _parseCmapFormat12(data, subtableOffset, coverage);
    }
  }

  return coverage;
}

/// Parses format 4 cmap subtable (segment mapping to delta values).
void _parseCmapFormat4(ByteData data, int subtableOffset, Set<int> coverage) {
  final segCountX2 = data.getUint16(subtableOffset + 6);
  final segCount = segCountX2 ~/ 2;
  final endCodeOffset = subtableOffset + 14;
  final startCodeOffset = endCodeOffset + segCountX2 + 2;

  for (var seg = 0; seg < segCount; seg++) {
    final endCode = data.getUint16(endCodeOffset + seg * 2);
    final startCode = data.getUint16(startCodeOffset + seg * 2);
    if (startCode == 0xFFFF && endCode == 0xFFFF) continue;

    for (var cp = startCode; cp <= endCode; cp++) {
      coverage.add(cp);
    }
  }
}

/// Parses format 12 cmap subtable (segmented coverage).
void _parseCmapFormat12(ByteData data, int subtableOffset, Set<int> coverage) {
  final nGroups = data.getUint32(subtableOffset + 12);
  for (var g = 0; g < nGroups; g++) {
    final groupOffset = subtableOffset + 16 + g * 12;
    final startCharCode = data.getUint32(groupOffset);
    final endCharCode = data.getUint32(groupOffset + 4);

    for (var cp = startCharCode; cp <= endCharCode; cp++) {
      coverage.add(cp);
    }
  }
}

void main() {
  test('every generated icon codepoint exists in the bundled font', () {
    final dartCodepoints = _parseDartCodepoints();
    final fontCodepoints = _parseFontCodepoints();

    // Guards against a regeneration that silently produces an empty or
    // truncated icon class.
    expect(dartCodepoints.length, greaterThan(1000));

    final missingFromFont = dartCodepoints.difference(fontCodepoints);
    expect(
      missingFromFont,
      isEmpty,
      reason: 'Icon codepoints missing from fonts/BootstrapIcons.ttf cmap '
          '(these icons would render as tofu): '
          '${missingFromFont.map((cp) => '0x${cp.toRadixString(16)}')}',
    );
  });
}
