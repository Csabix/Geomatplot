## Examples from `code.js`

- `point(scene, x, y, opts?)` — adds a draggable point mesh to the scene (`opts.size`, `opts.color`, `opts.hidden`).
- `dPoint(scene, ...sources, fn, opts?)` — creates a dependent point whose position is computed from source points/values (`opts.size`, `opts.color`, `opts.hidden`, `opts.dependencySystem`; `componentParams` auto-detected, override via opts).
- `createUniformCurve | createCentripetalCurve | createChordalCurve | createCustomCurve` — build curves from point sequences or a custom parametric callback.
- `circle(scene, center, radiusOrPointB, pointC?, opts?)` — draws a circle defined by center + radius or by three points.
- `distance(a, b, callback?)` — scalar value for distance between objects/points (optionally transformed via callback).
- `segment(scene, ...points, opts?)` — draws one or more connected line segments.
- `pointSequence(scene, ...pointsOrSources, opts?)` — renders a sequence of points (optionally derived from dependencies).
- `polygon(scene, ...sources, opts?)` — filled polygon built from point inputs or sequences.
- `text(scene, anchor, ...sources, formatter?, opts?)` — billboard text anchored to a point/value, auto-updated via dependencies (`opts.hidden` hides the sprite).
- `customValue(inputs, callback, opts?)` — computed value driven by arbitrary inputs; integrates with dependency updates.
- `createFunctionImage2D(scene, { callback or shader, inputs, corner0/1, resolution, previewScale, filtering, z })` — renders a heatmap/image plane from a CPU callback or a GPU fragment shader; auto-updates on dependency moves with low-res preview while dragging.
- `addImagePlane(scene, url, opts?)` — loads an image as a textured plane; supports custom material/shader.

## Usage samples

```js
// A draggable point at (10, 10) with custom size/color
point(scene, 10, 10, { size: 12, color: "orange" });
```

```js
// A dependent midpoint of two points (custom size/color via opts)
dPoint(scene, pointA, pointB, (a, b) => a.clone().add(b).multiplyScalar(0.5), {
  size: 10,
  color: "cyan",
});
```

```js
// Uniform curve through three control points
createUniformCurve(scene, [pointA, pointB, pointC]);
```

```js
// Circle through three points
circle(scene, pointA, pointB, pointC);
```

```js
// Numeric distance between two points
const dAB = distance(pointA, pointB);
console.log(dAB.getValue());
```

```js
// Simple red segment between two points
segment(scene, pointA, pointB, { color: "red" });
```

```js
// Filled triangle with semi-transparent face
polygon(scene, [pointA, pointB, pointC], { faceAlpha: 0.2 });
```

```js
// Billboard text anchored to a point
text(scene, pointA, "Label", { color: 0x00ff00 });
```

```js
// Custom value: distance between two points
const distVal = customValue([pointA, pointB], (a, b) => a.distanceTo(b));
distVal.onChange((v) => console.log("dist =", v));
```

```js
// GPU-based image: fragment shader receives uInputs (point positions) and uInputCount
createFunctionImage2D(scene, {
  inputs: [pointA, pointB, pointC], // injected into uInputs
  corner0: [-100, -100], // lower-left domain
  corner1: [100, 100], // upper-right domain
  resolution: 256, // target resolution
  previewScale: 0.3, // lower res while dragging
  filtering: "bilinear", // texture sampling
  shader: myFragmentShaderString, // or use callback: (x, y, ...inputs) => number
});
```
