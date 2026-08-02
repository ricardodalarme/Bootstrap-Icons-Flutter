import 'package:recase/recase.dart';
import 'dart_keywords.dart';

String normalizeName(String svgName) {
  var name = ReCase(svgName).snakeCase;

  if (dartKeywords.contains(name)) {
    name = '${name}_';
  }
  if (name.isNotEmpty && name.codeUnitAt(0) >= 48 && name.codeUnitAt(0) <= 57) {
    return '\$$name';
  }
  return name;
}
