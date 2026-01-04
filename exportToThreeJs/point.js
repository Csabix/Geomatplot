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
 * @param {object|number|string} opts - Optional params (object preferred).
 *        opts.size?: number (default 10)
 *        opts.color?: number|string (default 0xff0000)
 *        opts.hidden?: boolean (default false; if true, mesh is not rendered)
 * @returns {THREE.Mesh} The created mesh.
 */
export function point(scene, x, y, opts = {}) {
  let size = 10;
  let color = 0xff0000;
  let hidden = false;

  if (!(typeof x == "number") || !(typeof y == "number"))
    throw new Error("x and y should be number for point");

  if (typeof opts === "number" || typeof opts === "string") {
    if (typeof opts === "number") size = opts;
    if (typeof opts === "string") color = opts;
    if (arguments.length >= 5) color = arguments[4];
  } else if (opts && typeof opts === "object") {
    size = opts.size ?? size;
    color = opts.color ?? color;
    hidden = !!opts.hidden;
  }

  const geometry = new THREE.CircleGeometry(size, 32);
  const material = new THREE.MeshBasicMaterial({ color });
  const point = new THREE.Mesh(geometry, material);
  point.position.set(x, y, 0);
  point.userData.isPoint = true;
  point.visible = !hidden;
  scene.add(point);
  addDraggableObject(point);
  return point;
}

/**
 * dPoint(scene, ...points, fn, opts?)
 *
 * opts:
 *   {
 *     dependencySystem?: DependencySystem   // default: globalDependencySystem
 *     size?: number                        // point size (default 8)
 *     color?: number|string                // point color (default 0x00ffff)
 *     hidden?: boolean                     // hide the point if true (default false)
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
  let hidden = false;

  const opts =
    tail.length >= 1 && tail[0] && typeof tail[0] === "object" ? tail[0] : {};
  if (opts.size !== undefined) size = opts.size;
  if (opts.color !== undefined) color = opts.color;
  hidden = !!opts.hidden;
  if (opts.dependencySystem instanceof DependencySystem) {
    depSystem = opts.dependencySystem;
  }

  const geom = new THREE.CircleGeometry(size, 32);
  const mat = new THREE.MeshBasicMaterial({ color });
  const mesh = new THREE.Mesh(geom, mat);
  mesh.userData.isPoint = false;
  mesh.userData.isDPoint = true;
  mesh.visible = !hidden;
  scene.add(mesh);

  const extractValue = (p) => {
    if (p && typeof p.__depValue !== "undefined") {
      return extractValue(p.__depValue);
    }
    if (p && typeof p.__depSource === "object" && p.__depSource !== null) {
      const v = p.__depSource.getValue?.();
      if (typeof v !== "undefined") return extractValue(v);
    }
    if (p && typeof p.getValue === "function") {
      return extractValue(p.getValue());
    }
    if (p && "value" in p) return extractValue(p.value);
    if (p && p.position && p.position.isVector3) {
      return { x: p.position.x, y: p.position.y };
    }
    if (p && (p.isVector2 || p.isVector3)) return p;
    if (Array.isArray(p)) return p;
    if (p && typeof p === "object" && "x" in p && "y" in p) return p;
    throw new Error("dPoint: unsupported point input.");
  };

  const toVec3ForPosition = (v) => {
    if (v && v.isVector3) return v;
    if (v && v.isVector2) return new THREE.Vector3(v.x, v.y, 0);
    if (Array.isArray(v))
      return new THREE.Vector3(v[0] ?? 0, v[1] ?? 0, v[2] ?? 0);
    if (v && typeof v === "object" && "x" in v && "y" in v)
      return new THREE.Vector3(v.x ?? 0, v.y ?? 0, v.z ?? 0);
    throw new Error(
      "dPoint callback must return a Vector2/Vector3, [x,y(,z)], or {x,y(,z)}."
    );
  };

  const callParams = () => pointObjs.map(extractValue);

  const rebuild = () => {
    let result;
    try {
      result = fn(...callParams());
    } catch (e) {
      console.warn("dPoint: callback failed:", e);
      return;
    }

    mesh.position.copy(toVec3ForPosition(result));
  };

  rebuild();

  for (const p of pointObjs) {
    const depSrc =
      p && typeof p.__depSource === "object" && p.__depSource !== null
        ? p.__depSource
        : p;

    if (
      depSrc &&
      (depSrc.isObject3D ||
        (depSrc.position && depSrc.position.isVector3) ||
        typeof depSrc.getValue === "function" ||
        "value" in depSrc)
    ) {
      depSystem.addDependency(depSrc, mesh, () => rebuild());
    }
  }

  return mesh;
}
