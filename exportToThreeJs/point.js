import * as THREE from "three";

/**
 * Creates a point (small sphere or cube) and adds it to the given scene.
 * @param {THREE.Scene} scene - The scene to add the point to.
 * @param {number} x - X position.
 * @param {number} y - Y position.
 * @param {number} z - Z position (optional, default 0).
 * @param {number} size - Point size (optional, default 10).
 * @param {number} color - Color in hex (optional, default 0xff0000).
 * @returns {THREE.Mesh} The created mesh.
 */
export function point(scene, x, y, z = 0, size = 10, color = 0xff0000) {
  const geometry = new THREE.SphereGeometry(size, 16, 16);
  const material = new THREE.MeshBasicMaterial({ color });
  const point = new THREE.Mesh(geometry, material);
  point.position.set(x, y, z);
  scene.add(point);
  return point;
}
