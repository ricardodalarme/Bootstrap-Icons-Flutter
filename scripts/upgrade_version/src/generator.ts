import { snakeCase } from 'change-case';
import type { GenerateDartFileOptions } from './types';

export function generateDartFile(options: GenerateDartFileOptions): string {
  const { fontName, fontPackage, icons, version } = options;

  let content = `library ${snakeCase(fontName)};\n`;
  content += `\nimport 'package:flutter/widgets.dart';\n`;
  content += `\n/// Identifiers for all official [Bootstrap Icons](https://icons.getbootstrap.com/).\n`;
  content += `///\n`;
  content += `/// Use this class to reference icons by name:\n`;
  content += `///\n`;
  content += `/// \`\`\`dart\n`;
  content += `/// Icon(BootstrapIcons.alarm)\n`;
  content += `/// \`\`\`\n`;
  content += `///\n`;
  content += `/// See also:\n`;
  content += `///  * [Bootstrap Icons Catalog](https://icons.getbootstrap.com/)\n`;
  content += `abstract class ${fontName} {\n`;
  content += `  ${fontName}._();\n\n`;

  icons.forEach(({ name, svgName, codepoint }) => {
    content += `  /// Bootstrap icon \`${name}\` (\`${svgName}.svg\`).\n`;
    content += `  ///\n`;
    content += `  /// ![$svgName](https://raw.githubusercontent.com/twbs/icons/v${version}/icons/${svgName}.svg)\n`;
    content += `  static const ${name} = IconData(0x${codepoint}, fontFamily: "${fontName}", fontPackage: "${fontPackage}");\n\n`;
  });
  content += '}\n';

  return content;
}
