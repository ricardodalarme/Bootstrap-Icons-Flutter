import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

/// Extracts the codepoints of every generated icon constant in
/// `lib/bootstrap_icons.dart`.
Set<int> _dartCodepoints() {
  final content = File('lib/bootstrap_icons.dart').readAsStringSync();
  final pattern = RegExp(r'IconData\(\s*0x([0-9A-Fa-f]+)');
  return pattern
      .allMatches(content)
      .map((match) => int.parse(match.group(1)!, radix: 16))
      .toSet();
}

/// Parses the `cmap` table of `fonts/BootstrapIcons.ttf` and returns the set
/// of codepoints covered by its format 4 and format 12 subtables.
Set<int> _fontCodepoints() {
  final bytes = File('fonts/BootstrapIcons.ttf').readAsBytesSync();
  final data = ByteData.sublistView(bytes);

  final numTables = data.getUint16(4);
  int? cmapOffset;
  for (var i = 0; i < numTables; i++) {
    final recordOffset = 12 + i * 16;
    final tag = String.fromCharCodes(
      bytes.sublist(recordOffset, recordOffset + 4),
    );
    if (tag == 'cmap') {
      cmapOffset = data.getUint32(recordOffset + 8);
      break;
    }
  }
  if (cmapOffset == null) {
    throw StateError('cmap table not found in fonts/BootstrapIcons.ttf');
  }

  final numSubtables = data.getUint16(cmapOffset + 2);
  final coverage = <int>{};
  for (var i = 0; i < numSubtables; i++) {
    final recordOffset = cmapOffset + 4 + i * 8;
    final subtableOffset = cmapOffset + data.getUint32(recordOffset + 4);
    final format = data.getUint16(subtableOffset);

    if (format == 4) {
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
    } else if (format == 12) {
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
  }
  return coverage;
}

void main() {
  test('every generated icon codepoint exists in the bundled font', () {
    final dartCodepoints = _dartCodepoints();
    final fontCodepoints = _fontCodepoints();

    // Guards against a regeneration that silently produces an empty or
    // truncated icon class.
    expect(dartCodepoints.length, greaterThan(1000));

    final missingFromFont = dartCodepoints.difference(fontCodepoints);
    expect(
      missingFromFont,
      isEmpty,
      reason:
          'Icon codepoints not covered by the fonts/BootstrapIcons.ttf cmap '
          '(these icons would render as tofu): '
          '${missingFromFont.map((cp) => '0x${cp.toRadixString(16)}')}',
    );
  });
}
