import { snakeCase } from 'change-case';
import dartKeywords from './dartKeywords';

function normalizeName(value: string): string {
  let name = snakeCase(value);

  if (dartKeywords.includes(name)) {
    name = `${name}_`;
  }
  if (name.charAt(0) >= '0' && name.charAt(0) <= '9') {
    return `$${name}`;
  }
  return name;
}

export default normalizeName;
