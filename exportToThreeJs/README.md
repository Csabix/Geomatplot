This folder hosts the static export for the Three.js-based viewer. Treat it as a small, self-contained web app and keep it easy to serve locally for development.

Development workflow:
- Serve this directory with Node when working on the viewer: `npx serve .`
- Keep dependencies minimal; prefer vanilla JS modules and static assets.
- Update assets and build outputs in-place so the static server can reload them.
- If you add new entry points, document them here and keep paths relative to this folder.

Key files and systems:
- `index.html` is the entry point; it defines the import map for Three.js and loads the modules.
- `initialization.js` sets up the renderer, orthographic camera, scene, and resize handling, then wires in the drag controls.
- `code.js` is the main scene script; it builds demo geometry and shows how to compose primitives.
- `dependency.js` provides the dependency system (graph + updates) used to recompute dependent geometry when inputs change.
- `dragging.js` wraps Three.js `DragControls` and triggers dependency updates while objects are moved.

Dependency and dragging notes:
- When a draggable object moves, `dragging.js` calls `updateDependencies` so dependent objects stay in sync.
- If you add new geometry types, register dependencies where values are derived from other objects.
