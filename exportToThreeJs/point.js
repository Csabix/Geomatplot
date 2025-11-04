import * as THREE from "three";
import { addDraggableObject } from "./dragging.js";
import { addDependency, updateDependencies } from "./dependency.js";

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

export function dPoint(scene, a, b, fn, size = 8, color = 0x00ffff) {
  const geom = new THREE.CircleGeometry(size, 32);
  const mat = new THREE.MeshBasicMaterial({ color });
  const mesh = new THREE.Mesh(geom, mat);
  mesh.userData.isPoint = true;
  scene.add(mesh);

  const pos = fn(a.position, b.position);
  mesh.position.copy(pos);

  const rebuild = () => {
    const p = fn(a.position, b.position);
    mesh.position.copy(p);
  };

  addDependency(a, mesh, rebuild);
  addDependency(b, mesh, rebuild);
  updateDependencies(a);

  return mesh;
}
