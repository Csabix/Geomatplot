import * as THREE from "three";
import { addDependency } from "./dependency.js";

function toVec2(p) {
  // Mesh/Object3D with position
  if (p && p.position && p.position.isVector3)
    return new THREE.Vector2(p.position.x, p.position.y);
  // Already a Vector2/Vector3
  if (p && p.isVector2) return p.clone();
  if (p && p.isVector3) return new THREE.Vector2(p.x, p.y);
  // [x,y(,z)]
  if (Array.isArray(p)) return new THREE.Vector2(p[0] ?? 0, p[1] ?? 0);
  // {x,y(,z)}
  if (p && typeof p === "object" && "x" in p && "y" in p)
    return new THREE.Vector2(p.x ?? 0, p.y ?? 0);

  throw new Error(
    "Point must be Mesh/Object3D with .position, Vector2/Vector3, [x,y(,z)], or {x,y(,z)}."
  );
}

function extractMeshes(inputOrArray) {
  const arr = Array.isArray(inputOrArray) ? inputOrArray : [inputOrArray];
  return arr.filter((o) => o && o.position && o.position.isVector3);
}

function normalizePoints(pointsLike) {
  return pointsLike.map(toVec2);
}

// If only two points are provided, synthesize a middle control point to make a visible curve.
function withControlIfTwo(points) {
  if (points.length !== 2) return points;
  const [a, b] = points;
  const mid = a.clone().add(b).multiplyScalar(0.5);
  const lift = b.clone().sub(a).length() / 4;
  const control = mid.clone().add(new THREE.Vector2(0, lift));
  return [a, control, b];
}

function rebuildLineGeometry(line, pts, type, tension) {
  const vecs = (Array.isArray(pts) ? pts : [pts]).map((p) => toVec2(p));
  const clean = vecs.length === 2 ? withControlIfTwo(vecs) : vecs;
  const clean3 = clean.map((v) => new THREE.Vector3(v.x, v.y, 0));
  const curve = new THREE.CatmullRomCurve3(clean3, false, type, tension);
  line.geometry.setFromPoints(curve.getPoints(200));
  line.geometry.attributes.position.needsUpdate = true;
  line.geometry.computeBoundingSphere?.();
}

/**
 * Creates and returns a Catmullâ€“Rom curve (THREE.Line) and adds it to the given scene.
 *
 * ### Overloads
 * 1. `makeCurve(scene, p1, p2, tension, type, color)`
 *    - Connects two points (adds a lifted midpoint automatically for curvature)
 * 2. `makeCurve(scene, pointsArray, tension, type, color)`
 *    - Connects any number (â‰Ą2) of points directly
 */
function makeCurve(scene, arg1, arg2, arg3, type, color = 0xff0000, hidden = false) {
  let points, tension;
  let meshSources = [];

  if (Array.isArray(arg1)) {
    // Overload: (scene, pointsArray, tension?)
    points = normalizePoints(arg1);
    tension = typeof arg2 === "number" ? arg2 : 0.5;
    meshSources = extractMeshes(arg1);
  } else {
    // Overload: (scene, p1, p2, tension?)
    const p1 = toVec2(arg1);
    const p2 = toVec2(arg2);
    points = withControlIfTwo([p1, p2]);
    tension = typeof arg3 === "number" ? arg3 : 0.5;
    meshSources = extractMeshes([arg1, arg2]);
  }

  if (points.length < 2) throw new Error("At least two points are required.");

  const geometry = new THREE.BufferGeometry();
  const material = new THREE.LineBasicMaterial({ color });
  const line = new THREE.Line(geometry, material);
  line.visible = !hidden;
  scene.add(line);

  rebuildLineGeometry(
    line,
    Array.isArray(arg1) ? arg1 : [arg1, arg2],
    type,
    tension
  );

  for (const src of meshSources) {
    addDependency(src, line, () => {
      rebuildLineGeometry(
        line,
        Array.isArray(arg1) ? arg1 : [arg1, arg2],
        type,
        tension
      );
    });
  }

  return line;
}

/** Creates a Uniform Catmull2?"Rom curve */
export function createUniformCurve(scene, ...args) {
  const { points, tension, color, hidden } = parseCurveArgs(args);
  return makeCurve(scene, points, tension, undefined, "catmullrom", color, hidden);
}

/** Creates a Centripetal Catmull2?"Rom curve */
export function createCentripetalCurve(scene, ...args) {
  const { points, tension, color, hidden } = parseCurveArgs(args);
  return makeCurve(scene, points, tension, undefined, "centripetal", color, hidden);
}

/** Creates a Chordal Catmull2?"Rom curve */
export function createChordalCurve(scene, ...args) {
  const { points, tension, color, hidden } = parseCurveArgs(args);
  return makeCurve(scene, points, tension, undefined, "chordal", color, hidden);
}

/**
 * createCustomCurve(scene, ...sources, callback, opts?)
 *
 * General parametric / dependent curve, similar to Geomatplot's dcurve.
 *
 * - You can pass **any number of sources** (points, scalars, etc.).
 * - The callback is invoked as:
 *       callback(t, ...values) -> pointLike
 *   where:
 *     - t â [0,1] is the curve parameter,
 *     - values are derived from your sources:
 *         * for points:   their position (THREE.Vector2)
 *         * for scalars:  src.getValue() or src.value if present
 *         * otherwise:    the source object itself
 *     - pointLike is anything `toVec3` understands (Vector3, [x,y], {x,y}, meshâ€¦).
 *
 * opts:
 *   {
 *     segments?: number      // number of samples along t, default 200
 *     color?:    number|string // line color, default 0x000000
 *     lineWidth?: number     // LineBasicMaterial linewidth, default 1
 *     hidden?:   boolean     // if true, curve is created but not visible
 *   }
 *
 * Returns:
 *   THREE.Line  (already added to scene)
 *
 * Examples
 * --------
 *
 * // Pure sine curve (no sources)
 * createCustomCurve(
 *   scene,
 *   (t) => {
 *     const x = t * 400 - 200;
 *     const y = Math.sin(t * Math.PI * 4) * 50;
 *     return [x, y];
 *   },
 *   { color: 0x3366ff, segments: 400 }
 * );
 *
 * // Curve that depends on two points A,B (e.g. an arc between them)
 * createCustomCurve(
 *   scene,
 *   A,
 *   B,
 *   (t, aPos, bPos) => {
 *     const mid = aPos.clone().add(bPos).multiplyScalar(0.5);
 *     const dir = bPos.clone().sub(aPos);
 *     const x = THREE.MathUtils.lerp(aPos.x, bPos.x, t);
 *     const y = THREE.MathUtils.lerp(aPos.y, bPos.y, t) +
 *               Math.sin(t * Math.PI) * dir.length() * 0.25;
 *     return new THREE.Vector2(x, y);
 *   },
 *   { color: 0xdd5522 }
 * );
 */
export function createCustomCurve(scene, ...args) {
  if (!scene || !scene.isScene) {
    throw new Error("createCustomCurve: first argument must be a THREE.Scene");
  }

  if (args.length === 0) {
    throw new Error("createCustomCurve: missing callback.");
  }

  // ---- parse opts (last plain-object arg) ----
  let opts = {};
  if (
    args.length &&
    isPlainObject(args[args.length - 1]) &&
    typeof args[args.length - 1] !== "function"
  ) {
    opts = args.pop();
  }

  // ---- find callback ----
  const fnIndex = args.findIndex((a) => typeof a === "function");
  if (fnIndex === -1) {
    throw new Error("createCustomCurve: a callback function is required.");
  }

  const sources = args.slice(0, fnIndex);
  const callback = args[fnIndex];

  const segments = opts.segments ?? 200;
  const color = opts.color ?? 0x000000;
  const lineWidth = opts.lineWidth ?? 1;
  const hidden = !!opts.hidden;

  // ---- line setup ----
  const geometry = new THREE.BufferGeometry();
  const material = new THREE.LineBasicMaterial({ color, linewidth: lineWidth });
  const line = new THREE.Line(geometry, material);
  line.visible = !hidden;
  scene.add(line);

  // ---- helpers to extract values from sources ----
  const extractValue = (src) => {
    if (src == null) return src;
    if (typeof src.getValue === "function") return src.getValue();
    if ("value" in src) return src.value;
    if (src.position && src.position.isVector3)
      return new THREE.Vector2(src.position.x, src.position.y);
    if (src.isVector2) return src;
    if (src.isVector3) return new THREE.Vector2(src.x, src.y);
    // Allow passing raw coordinates like [x,y] or {x,y,z}
    if (Array.isArray(src)) return toVec2(src);
    if (typeof src === "object" && ("x" in src || "y" in src || "z" in src))
      return toVec2(src);
    return src;
  };

  const rebuild = () => {
    const pts = [];
    for (let i = 0; i < segments; i++) {
      const t = segments === 1 ? 0 : i / (segments - 1);
      const values = sources.map(extractValue);
      const res = callback(t, ...values);
      const v = toVec2(res);
      pts.push(v);
    }
    const pts3 = pts.map((v) => new THREE.Vector3(v.x, v.y, 0));
    line.geometry.setFromPoints(pts3);
    line.geometry.attributes.position.needsUpdate = true;
    line.geometry.computeBoundingSphere?.();
  };

  // initial build
  rebuild();

  // ---- attach dependencies ----
  const attachDep = (src) => {
    if (!src) return;
    // Simple rule: if it looks like an object that can change, wire it
    if (
      src.isObject3D ||
      (src.position && src.position.isVector3) ||
      typeof src.getValue === "function" ||
      "value" in src
    ) {
      addDependency(src, line, () => rebuild());
    }
  };

  sources.forEach(attachDep);

  return line;
}

/* ---------------- small helper ---------------- */

function isPlainObject(o) {
  return (
    !!o &&
    typeof o === "object" &&
    !o.isObject3D &&
    !o.isVector2 &&
    !o.isVector3 &&
    !Array.isArray(o)
  );
}

function isCurveOptions(o) {
  if (!isPlainObject(o)) return false;
  const hasStyle = "color" in o || "tension" in o || "hidden" in o;
  const looksLikePoint = "x" in o || "y" in o || "z" in o;
  return hasStyle && !looksLikePoint;
}

function parseCurveArgs(args) {
  const arr = [...args];
  let opts = {};
  if (arr.length && isCurveOptions(arr[arr.length - 1])) {
    opts = arr.pop();
  }

  let tension =
    typeof opts.tension === "number" ? opts.tension : undefined;
  if (tension === undefined && arr.length) {
    const maybeTension = arr[arr.length - 1];
    if (typeof maybeTension === "number") {
      tension = arr.pop();
    }
  }

  const color = opts.color ?? "red";
  const hidden = !!opts.hidden;

  const points =
    arr.length === 1 && Array.isArray(arr[0]) ? arr[0] : arr;

  return { points, tension, color, hidden };
}
