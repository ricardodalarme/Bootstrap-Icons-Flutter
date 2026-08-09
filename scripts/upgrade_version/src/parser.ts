import { type Result, webfont } from 'webfont';
import type { Icon, ParseIconsOptions, ParseIconsResult } from './types';
import normalizeName from './utils/normalizeName';

type GlyphData = NonNullable<Result['glyphsData']>[number];

export async function parseIcons(
  options: ParseIconsOptions,
): Promise<ParseIconsResult> {
  const { input, fontName, height } = options;

  const { ttf, glyphsData } = await webfont({
    files: input,
    fontName,
    fontHeight: height,
    prependUnicode: true,
  });

  if (ttf === undefined) {
    throw new Error('No TTF found');
  }
  if (glyphsData === undefined) {
    throw new Error('No glyphs found');
  }

  const icons = iconsFromGlyphsData(glyphsData);

  return { ttf, icons };
}

function toHex(str: string): string {
  let result = '';
  for (let i = 0; i < str.length; i++) {
    result += str.charCodeAt(i).toString(16);
  }
  return result;
}

function iconsFromGlyphsData(data: GlyphData[]): Icon[] {
  const icons: Icon[] = [];
  data.forEach(({ metadata }) => {
    if (metadata === undefined || metadata.unicode === undefined) {
      return;
    }
    const { name, unicode } = metadata;
    const char = unicode[0];
    if (char === undefined) {
      return;
    }

    icons.push({
      name: normalizeName(name),
      svgName: name,
      codepoint: toHex(char),
    });
  });
  return icons;
}
