## Three.js Export

This folder is a static export of the Three.js viewer. Think of it as a compact, self-contained web app that you can serve locally without a build step.

### Quick start

```sh
npx serve .
```

### Development notes

- Keep dependencies minimal; prefer vanilla JS modules and static assets.
- Update assets and build outputs in-place so the static server can reload them.
- If you add new entry points, document them here and keep paths relative to this folder.

### Key files

- `index.html`: entry point; defines the import map for Three.js and loads modules.
- `initialization.js`: renderer, orthographic camera, scene, resize handling, and drag controls.
- `code.js`: main scene script; demo geometry and composition patterns.
- `dependency.js`: dependency graph and update propagation for derived geometry.
- `dragging.js`: wraps Three.js `DragControls` and triggers dependency updates.

### Dependency + dragging

- Dragging calls `updateDependencies` so dependent objects stay in sync.
- When adding new geometry, wire dependency updates wherever values are derived.

### Further development

- Images should accept additional input types such as curves and circles; for curves, expose their point sets so they can be used in image parameters.
- Unwrap `depValue` by default where dependent values are consumed. Example where it should work:
  ```ts
  const customVal2 = customValue([dAB], (d) => {
    return d / 2;
  });
  ```
- Separate Three.js-specific dependencies from core dependency logic so the system can be swapped to another rendering technology later.
