import webfont from 'webfont';
import path from 'path';
import fs from 'fs';

import { snakeCase } from 'change-case';
import normalizeName from './utils/normalizeName';
import { GlyphData } from 'webfont/dist/src/types';

const Options = {
  input: './icons/icons/',
  dartOutput: '../../lib/',
  fontOutput: '../../fonts/',
  fontName: 'BootstrapIcons',
  height: 512,
};

type Icon = {
  name: string;
  codepoint: string;
};

export default async function () {
  const { input, dartOutput, fontOutput, fontName, height } = Options;

  console.log('Generating font from SVGs');

  const { ttf, glyphsData } = await webfont({
    files: input,
    fontName: fontName,
    fontHeight: height,
    prependUnicode: true,
  });

  if (ttf === undefined) {
    throw new Error('No TTF found');
  }
  if (glyphsData === undefined) {
    throw new Error('No glyphs found');
  }

  console.log('Generating TTF file');
  fs.writeFileSync(path.join(fontOutput, fontName + '.ttf'), ttf);

  console.log('Generating Dart file');
  const icons = iconsFromGlyphsData(glyphsData);
  const fileContent = generateFileContent(fontName, icons);

  fs.writeFileSync(
    path.join(dartOutput, snakeCase(fontName) + '.dart'),
    fileContent,
  );
}
function toHex(str: string) {
  var result = '';
  for (var i = 0; i < str.length; i++) {
    result += str.charCodeAt(i).toString(16);
  }
  return result;
}
function iconsFromGlyphsData(data: GlyphData[]): Icon[] {
  var icons: Icon[] = [];
  data.forEach(({ metadata }) => {
    if (metadata === undefined || metadata.unicode === undefined) {
      return;
    }
    const { name, unicode } = metadata;

    icons.push({
      name: normalizeName(name),
      codepoint: toHex(unicode[0]),
    });
  });
  return icons;
}

function generateFileContent(fontName: string, icons: Icon[]) {
  let content = `library ${snakeCase(fontName)};\n`;
  content += `\nimport 'package:flutter/widgets.dart';\n`;
  content += `
class _${fontName}IconData extends IconData {
  const _${fontName}IconData(int codePoint)
      : super(codePoint, fontFamily: "${fontName}");
}
`;
  content += `\nabstract class ${fontName} {\n`;
  content += `  ${fontName}._();\n\n`;

  icons.forEach(({ name, codepoint }) => {
    content += `  static const ${name} = _${fontName}IconData(0x${codepoint});\n`;
  });
  content += '}\n';

  return content;
}
