import * as THREE from "three";
import { addDraggableObject } from "./dragging.js";
import {
  addDependency,
  updateDependencies,
  globalDependencySystem,
  DependencySystem,
} from "./dependency.js";

/**
 * Creates a point (small sphere or cube) and adds it to the given scene.
 * @param {THREE.Scene} scene - The scene to add the point to.
 * @param {number} x - X position.
 * @param {number} y - Y position.
 * @param {number} size - Point size (optional, default 10).
 * @param {number} color - Color in hex (optional, default 0xff0000).
 * @returns {THREE.Mesh} The created mesh.
 */
export function point(scene, x, y, size = 10, color = 0xff0000) {
  const geometry = new THREE.CircleGeometry(size, 32);
  const material = new THREE.MeshBasicMaterial({ color });
  const point = new THREE.Mesh(geometry, material);
  point.position.set(x, y, 0);
  point.userData.isPoint = true;
  scene.add(point);
  addDraggableObject(point);
  return point;
}

/**
 * dPoint(scene, ...points, fn, size?, color?, opts?)
 *
 * opts:
 *   {
 *     dependencySystem?: DependencySystem   // default: globalDependencySystem
 *   }
 */
export function dPoint(scene, ...args) {
  if (!scene || !scene.isScene) {
    throw new Error("dPoint: first argument must be a THREE.Scene");
  }

  const fnIndex = args.findIndex((a) => typeof a === "function");
  if (fnIndex === -1) {
    throw new Error("dPoint: a callback function is required.");
  }

  const pointObjs = args.slice(0, fnIndex);
  const fn = args[fnIndex];
  let tail = args.slice(fnIndex + 1);

  let size = 8;
  let color = 0x00ffff;
  let depSystem = globalDependencySystem;

  if (tail.length >= 1 && typeof tail[0] === "number") {
    size = tail[0];
    tail = tail.slice(1);
  }
  if (
    tail.length >= 1 &&
    (typeof tail[0] === "number" || typeof tail[0] === "string")
  ) {
    color = tail[0];
    tail = tail.slice(1);
  }
  if (tail.length >= 1 && tail[0] && typeof tail[0] === "object") {
    const opts = tail[0];
    if (opts.dependencySystem instanceof DependencySystem) {
      depSystem = opts.dependencySystem;
    }
  }

  const geom = new THREE.CircleGeometry(size, 32);
  const mat = new THREE.MeshBasicMaterial({ color });
  const mesh = new THREE.Mesh(geom, mat);
  mesh.userData.isPoint = false;
  mesh.userData.isDPoint = true;
  scene.add(mesh);

  const toPos = (p) => {
    if (p && p.position && p.position.isVector3) return p.position;
    if (p && p.isVector3) return p;
    if (Array.isArray(p))
      return new THREE.Vector3(p[0] ?? 0, p[1] ?? 0, p[2] ?? 0);
    if (p && typeof p === "object" && "x" in p && "y" in p)
      return new THREE.Vector3(p.x ?? 0, p.y ?? 0, p.z ?? 0);
    throw new Error("dPoint: unsupported point input.");
  };

  const rebuild = () => {
    const posList = pointObjs.map(toPos);
    const result = fn(...posList);
    if (!result || !result.isVector3) {
      throw new Error("dPoint callback must return a THREE.Vector3.");
    }
    mesh.position.copy(result);
  };

  rebuild();

  for (const p of pointObjs) {
    if (p && p.position && p.position.isVector3) {
      depSystem.addDependency(p, mesh, () => rebuild());
    }
  }

  return mesh;
}
