import { defineConfig } from 'tsup';

export default defineConfig({
  entry: ['src/index.ts'],
  format: ['esm'],
  dts: true,
  clean: true,
  // React is provided by the host (claude.ai/design serves it from _vendor/),
  // so bundling a second copy here would give us two Reacts and a hook error.
  external: ['react', 'react-dom', 'react/jsx-runtime'],
  target: 'es2020',
});
