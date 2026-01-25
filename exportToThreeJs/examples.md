## Usage examples of the functions

### Point

It creates a moveable point in the given coordinates.

#### Usage example

```ts
const point_1 = point(scene, 50, 50);
const point_2 = point(scene, -50, -100, { hidden: true });
```

#### Optional params:

```ts
{
  hidden: boolean,
  color: string,
  size: number
}
```

### dPoint

It creates a dependent point. If a dependency is updated, this point is updated automatically. A function should be given, to calculate the coordinates of the dPoint. It accepts multiple types of parameters.

#### Usage example

```ts
dPoint(
  scene,
  point_1,
  [10, 10],
  ([px, py], [dx, dy]) => {
    return [px + dx, py + dy];
  },
  { hidden: false, color: "green" },
);
```

#### Optional params:

```ts
{
  hidden: boolean,
  color: string,
  size: number
}
```

### Curve

It creates a curve through the given points. It also supports a custom parametric curve that updates with dependencies.

#### Usage example

```ts
const curve_1 = createUniformCurve(
  scene,
  [point_1, point_2, [10, 10], point_4],
  { hidden: true, color: "green", tension: 0.5 },
);

const curve_2 = createCustomCurve(
  scene,
  point_1,
  [10, 10],
  (t, aPos, bPos) => {
    const x = THREE.MathUtils.lerp(aPos.x, bPos.x, t);
    const y =
      THREE.MathUtils.lerp(aPos.y, bPos.y, t) + Math.sin(t * Math.PI * 3) * 40;
    return new THREE.Vector2(x, y);
  },
  { color: 0xdd5522, segments: 300, hidden: true },
);
```

#### Optional params (createUniformCurve / createCentripetalCurve / createChordalCurve):

```ts
{
  hidden: boolean,
  color: string,
  tension: number
}
```

#### Optional params (createCustomCurve):

```ts
{
  hidden: boolean,
  color: number | string,
  lineWidth: number,
  segments: number
}
```

### Circle

It creates a circle from a center and radius, from a center and one or more points on the circle.

#### Usage example

```ts
const circle_1 = circle(scene, point_1, point_2, point_3, {
  color: 0x0066ff,
  hidden: true,
});

const circle_2 = circle(scene, point_1, point_2);
const circle_3 = circle(scene, [300, -150], 120);
```

#### Optional params:

```ts
{
  hidden: boolean,
  color: number,
  segments: number,
  centerSize: number,
  centerColor: number
}
```

### Scalar

It creates a dependent scalar value (dScalar) based on the given calculation.

#### Usage example

```ts
const d_ab = dScalar(point_2, [10, 10], (a, b) => {
  return a.x + b[0];
});
```

Which than can be used in other objects as a parameter:

```ts
const circ1 = circle(scene, point_1, dAB, {
  color: 0x0066ff,
  hidden: true,
});
```

### Custom Value

It creates a dependent custom value from arbitrary inputs.

#### Usage example

```ts
const custom_val = customValue([d_ab], (d) => {
  return d / 2;
});
```

#### Optional params:

```ts
{
  dependencySystem: DependencySystem;
}
```

### Distance

It creates a scalar representing the distance between two points.

#### Usage example

```ts
const d_a_b = distance(point_1, point_2);
```

### Segment

It creates a straight segment between two points, a segment from a point and vector, or a polyline from multiple points.

#### Usage example

```ts
const s1 = segment(scene, point_1, point_2, {
  color: 0x333333,
  linewidth: 2,
  hidden: true,
});

const s2 = segment(scene, point_1, point_2, point_3, point_4);
const s3 = segment(scene, point_1, [80, -40]);
```

#### Optional params:

```ts
{
  hidden: boolean,
  color: number | string,
  linewidth: number,
  dashed: boolean
}
```

### Polygon

It creates a polygon from a list of points, arrays, sequences, or another polygon.

#### Usage example

```ts
const poly_1 = polygon(scene, [point_1, [0, 0], point_4, [30, 10]], {
  color: 0x0088ff,
  faceAlpha: 0.2,
  hidden: true,
});

const poly_2 = polygon(scene, point_1, point_2, point_3, {
  color: 0xdd5522,
  faceAlpha: 0.15,
  hidden: true,
});
```

#### Optional params:

```ts
{
  hidden: boolean,
  visible: boolean,
  color: number | string,
  lineWidth: number,
  faceAlpha: number
}
```

### Point Sequence

It creates a point sequence from any mix of:

- point-like inputs (mesh with .position, Vector2/Vector3, [x,y], {x,y})
- another point sequence
- polygon
- line (THREE.Line)

With multiple points it also accepts a mapping function as well.

#### Usage example

```ts
const seq_1 = pointSequence(scene, point_1, point_2, point_3, {
  color: 0x3366ff,
  markerSize: 2,
  hidden: true,
});

const seq_2 = pointSequence(scene, point_1, point_2, point_3, (a, b, c) => {
  return [a, b, c].map(([x, y]) => [x, -y]);
});

const curve_seq = pointSequence(scene, curve_1, {
  color: 0x22aa22,
  markerSize: 1.5,
  hidden: true,
});
```

#### Optional params:

```ts
{
  hidden: boolean,
  visible: boolean,
  color: number | string,
  markerSize: number,
  sizeAttenuation: boolean
}
```

### Text

It creates a text label at a position, either with a constant string or a callback-driven value.

#### Usage example

```ts
const label_1 = text(scene, point_1, "point_1", {
  color: 0x0000ff,
  fontSize: 200,
  offset: { x: 10, y: 10 },
  hidden: true,
});

const label_2 = text(scene, point_1, [d_ab], (B) => B.toFixed(2));
```

#### Optional params:

```ts
{
  hidden: boolean,
  color: number | string,
  fontSize: number,
  fontFamily: string,
  offset: { x: number, y: number }
}
```

### Image

It creates an image plane from a texture file or a function-based 2D image. When using a shader, the image is rendered on the GPU.

#### Usage example

```ts
const img_1 = addImagePlane(scene, "../examples/triangle.png", {
  width: 200,
  position: { x: -100, y: -250, z: 0 },
});

const img_2 = createFunctionImage2D(scene, {
  callback: (x, y) => Math.sin(x * 0.01) * Math.cos(y * 0.01),
  corner0: [-150, -50],
  corner1: [200, 250],
  resolution: 256,
  colormap: "jet",
  z: -0.01,
});

const seq = pointSequence(scene, point_1, point_2, point_3, {
  hidden: true,
});

const shader = `
  varying vec2 vWorld;
  void main() {
    float minD = 1e9;
    for (int i = 0; i < u_seqCount; i++) {
      vec2 p = u_seq[i].xy;
      float d = distance(vWorld, p);
      if (d < minD) minD = d;
    }
    float t = clamp(minD / 200.0, 0.0, 1.0);
    gl_FragColor = vec4(vec3(1.0 - t, 0.3, t), 0.9);
  }
`;

const img_3 = createFunctionImage2D(scene, {
  inputs: { seq },
  corner0: [-150, -50],
  corner1: [200, 250],
  filtering: "bilinear",
  z: -1,
  shader,
});
```

In the shader example above, `inputs: { seq }` auto-generates uniforms. You can use `u_seq` as a `vec3[]` array, and `u_seqCount` as the number of points; each element comes from the point sequence. The built-in `vWorld` varying provides the world-space position for each pixel on the image plane.

If you want to refer to inputs by name in the shader, pass an object map, e.g. `inputs: { first_point: point_1 }`. This creates uniforms like `u_first_point` (and `u_first_pointCount` for arrays); the key is sanitized to `[A-Za-z0-9_]` and prefixed with `u_`.

#### Optional params (addImagePlane):

```ts
{
  width: number,
  height: number,
  position: { x: number, y: number, z: number },
  hidden: boolean,
  onLoad: (mesh, texture) => void,
  shader: { vertexShader: string, fragmentShader: string, uniforms?: object },
  materialFactory: (texture) => THREE.Material
}
```

#### Optional params (createFunctionImage2D):

```ts
{
  callback: (x, y, ...inputs) => number | [r, g, b],
  inputs: any[] | object,
  corner0: [number, number],
  corner1: [number, number],
  resolution: number,
  colormap: "jet" | "grayscale",
  valueRange: [number, number],
  z: number,
  previewResolution: number,
  previewScale: number,
  previewDebounceMs: number,
  filtering: "linear" | "bilinear" | "nearest",
  shader: string | { vertexShader?: string, fragmentShader?: string, uniforms?: object },
  shaderInputCapacity: number,
  hidden: boolean
}
```

### Experimental Features

#### Local dependency system

You can isolate updates from the global dependency system by creating a local one and passing it into an object. This lets you decide when to recompute the image.

```ts
const localDeps = createDependencySystem();

const img_local = createFunctionImage2D(scene, {
  callback: (x, y, p) => Math.hypot(x - p.x, y - p.y),
  inputs: [point_1],
  corner0: [-150, -50],
  corner1: [200, 250],
  resolution: 256,
  dependencySystem: localDeps,
});
```
