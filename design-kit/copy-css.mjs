// Concatenate tokens + component styles into one dist/kit.css.
//
// One file rather than an @import chain on purpose: the design-sync converter
// checks that every @import in the styles.css closure resolves on disk, and a
// chain that resolves here but not after copying is a silent unstyled bundle.
// Concatenation has no such failure mode.
import { readFileSync, writeFileSync, mkdirSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const here = dirname(fileURLToPath(import.meta.url));
const parts = ['src/tokens.css', 'src/components.css'].map((p) =>
  readFileSync(join(here, p), 'utf8'),
);

mkdirSync(join(here, 'dist'), { recursive: true });
writeFileSync(join(here, 'dist/kit.css'), parts.join('\n\n'), 'utf8');
console.log('wrote dist/kit.css');
