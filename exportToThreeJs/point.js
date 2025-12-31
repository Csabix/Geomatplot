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

  // Legacy support: point(scene, x, y, size, color)
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
 *     componentParams?: boolean            // if true, force callback to get [x,y]; if false, force Vector2; if unset, auto-detect
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
  // paramMode: "plain" (arrays), "vector" (Vector2), null (auto-detect)
  let paramMode =
    opts.componentParams === true
      ? "plain"
      : opts.componentParams === false
      ? "vector"
      : null;

  const geom = new THREE.CircleGeometry(size, 32);
  const mat = new THREE.MeshBasicMaterial({ color });
  const mesh = new THREE.Mesh(geom, mat);
  mesh.userData.isPoint = false;
  mesh.userData.isDPoint = true;
  mesh.visible = !hidden;
  scene.add(mesh);

  const toVec2 = (p) => {
    if (p && typeof p.__depValue !== "undefined") {
      return toVec2(p.__depValue);
    }
    if (p && typeof p.__depSource === "object" && p.__depSource !== null) {
      const v = p.__depSource.getValue?.();
      return toVec2(v);
    }
    if (p && typeof p.getValue === "function") {
      return toVec2(p.getValue());
    }
    if (p && p.position && p.position.isVector3)
      return new THREE.Vector2(p.position.x, p.position.y);
    if (p && p.isVector2) return p.clone();
    if (p && p.isVector3) return new THREE.Vector2(p.x, p.y);
    if (Array.isArray(p)) return new THREE.Vector2(p[0] ?? 0, p[1] ?? 0);
    if (p && typeof p === "object" && "x" in p && "y" in p)
      return new THREE.Vector2(p.x ?? 0, p.y ?? 0);
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

  const toPlain = (p) => {
    const v = toVec2(p);
    return [v.x, v.y];
  };

  const callParams = (mode) =>
    mode === "plain" ? pointObjs.map(toPlain) : pointObjs.map(toVec2);

  const rebuild = () => {
    let result;
    if (paramMode === "plain") {
      result = fn(...callParams("plain"));
    } else if (paramMode === "vector") {
      result = fn(...callParams("vector"));
    } else {
      try {
        result = fn(...callParams("vector"));
        paramMode = "vector";
      } catch (eVec) {
        try {
          result = fn(...callParams("plain"));
          paramMode = "plain";
        } catch (ePlain) {
          console.warn(
            "dPoint: callback failed (vector and plain):",
            eVec,
            ePlain
          );
          return;
        }
      }
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
