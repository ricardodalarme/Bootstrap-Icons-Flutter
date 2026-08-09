export type Icon = {
  name: string;
  svgName: string;
  codepoint: string;
};

export type ParseIconsOptions = {
  input: string;
  fontName: string;
  height: number;
};

export type ParseIconsResult = {
  ttf: Buffer;
  icons: Icon[];
};

export type GenerateDartFileOptions = {
  fontName: string;
  fontPackage: string;
  icons: Icon[];
  version: string;
};
