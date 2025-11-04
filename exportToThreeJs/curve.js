import * as THREE from "three";
import { addDependency } from "./dependency.js";

function toVec3(p) {
  // Mesh/Object3D with position
  if (p && p.position && p.position.isVector3) return p.position.clone();
  // Already a Vector3
  if (p && p.isVector3) return p.clone();
  // [x,y,z]
  if (Array.isArray(p))
    return new THREE.Vector3(p[0] ?? 0, p[1] ?? 0, p[2] ?? 0);
  // {x,y,z}
  if (p && typeof p === "object" && "x" in p && "y" in p)
    return new THREE.Vector3(p.x ?? 0, p.y ?? 0, p.z ?? 0);

  throw new Error(
    "Point must be Mesh/Object3D with .position, Vector3, [x,y,z], or {x,y,z}."
  );
}

function extractMeshes(inputOrArray) {
  const arr = Array.isArray(inputOrArray) ? inputOrArray : [inputOrArray];
  return arr.filter((o) => o && o.position && o.position.isVector3);
}

function rebuildLineGeometry(line, pts, type, tension) {
  const vecs = (Array.isArray(pts) ? pts : [pts]).map((p) =>
    p && p.position && p.position.isVector3 ? p.position.clone() : toVec3(p)
  );
  const clean = vecs.length === 2 ? withControlIfTwo(vecs) : vecs;
  const curve = new THREE.CatmullRomCurve3(clean, false, type, tension);
  line.geometry.setFromPoints(curve.getPoints(200));
  line.geometry.attributes.position.needsUpdate = true;
  line.geometry.computeBoundingSphere?.();
}

function normalizePoints(pointsLike) {
  return pointsLike.map(toVec3);
}

// If only two points are provided, synthesize a middle control point to make a visible curve.
function withControlIfTwo(points) {
  if (points.length !== 2) return points;
  const [a, b] = points;
  const mid = a.clone().add(b).multiplyScalar(0.5);
  const lift = b.clone().sub(a).length() / 4;
  const control = mid.clone().add(new THREE.Vector3(0, lift, 0));
  return [a, control, b];
}

/**
 * Creates and returns a Catmull–Rom curve (THREE.Line) and adds it to the given scene.
 *
 * ### Overloads
 * 1. `makeCurve(scene, p1, p2, tension, type, color)`
 *    - Connects two points (adds a lifted midpoint automatically for curvature)
 * 2. `makeCurve(scene, pointsArray, tension, type, color)`
 *    - Connects any number (≥2) of points directly
 *
 * ### Supported point types
 * - `THREE.Mesh` / `THREE.Object3D` (uses `.position`)
 * - `THREE.Vector3`
 * - `[x, y, z]`
 * - `{ x, y, z }`
 *
 * @param {THREE.Scene} scene
 *   The scene to add the resulting curve line to.
 *
 * @param {THREE.Mesh|THREE.Object3D|THREE.Vector3|Array|Object|Array.<THREE.Mesh|THREE.Object3D|THREE.Vector3|Array|Object>} arg1
 *   Either:
 *   - The first point (in two-point form), or
 *   - An array of points (in N-point form)
 *
 * @param {THREE.Mesh|THREE.Object3D|THREE.Vector3|Array|Object|number} [arg2]
 *   In two-point form: the second point.
 *   In N-point form: optional numeric tension value.
 *
 * @param {number} [arg3]
 *   In two-point form: the optional numeric tension value (defaults to 0.5).
 *   Ignored in N-point form.
 *
 * @param {'catmullrom'|'centripetal'|'chordal'} type
 *   The Catmull–Rom curve type.
 *
 * @param {number|string} [color=0xff0000]
 *   The color of the line, as a hex number or CSS-style string.
 *
 * @returns {THREE.Line}
 *   The created THREE.Line mesh already added to the scene.
 *
 * @throws {Error}
 *   If fewer than two points are provided or an unsupported point format is used.
 *
 * @example
 * // Two-point usage
 * const p1 = point(scene, 0, 0);
 * const p2 = point(scene, 200, 200);
 * makeCurve(scene, p1, p2, 0.6, 'catmullrom', 0xff0000);
 *
 * // Multi-point usage
 * const p3 = point(scene, 400, 50);
 * makeCurve(scene, [p1, p2, p3], 0.5, 'centripetal', 0x00ff00);
 */
function makeCurve(scene, arg1, arg2, arg3, type, color) {
  let points, tension;
  let meshSources = [];

  if (Array.isArray(arg1)) {
    // Overload: (scene, pointsArray, tension?)
    points = normalizePoints(arg1);
    tension = typeof arg2 === "number" ? arg2 : 0.5;
    meshSources = extractMeshes(arg1);
  } else {
    // Overload: (scene, p1, p2, tension?)
    const p1 = toVec3(arg1);
    const p2 = toVec3(arg2);
    points = withControlIfTwo([p1, p2]);
    tension = typeof arg3 === "number" ? arg3 : 0.5;
    meshSources = extractMeshes([arg1, arg2]);
  }

  if (points.length < 2) throw new Error("At least two points are required.");

  const geometry = new THREE.BufferGeometry();
  const material = new THREE.LineBasicMaterial({ color });
  const line = new THREE.Line(geometry, material);
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

/** Creates a Uniform Catmull–Rom curve */
export function createUniformCurve(scene, a, b, c, color = "red") {
  return makeCurve(scene, a, b, c, "catmullrom", color);
}

/** Creates a Centripetal Catmull–Rom curve */
export function createCentripetalCurve(scene, a, b, c, color = "red") {
  return makeCurve(scene, a, b, c, "centripetal", color);
}

/** Creates a Chordal Catmull–Rom curve */
export function createChordalCurve(scene, a, b, c, color = "red") {
  return makeCurve(scene, a, b, c, "chordal", color);
}
