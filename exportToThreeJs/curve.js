import * as THREE from "three";

/**
 * Creates and returns a CatmullRom curve mesh
 * @param {THREE.Scene} scene - The scene to add the point to.
 * @param {THREE.Vector3} p1 - Start point
 * @param {THREE.Vector3} p2 - End point
 * @param {string} type - 'uniform' | 'centripetal' | 'chordal'
 * @param {number | string} color - Color of the curve, default is red
 * @param {number} [tension=0.5] - Optional tension parameter
 */
function makeCurve(scene, p1, p2, type, tension = 0.5, color = "red") {
  // Extract positions from the point meshes
  const v1 = p1.position.clone();
  const v2 = p2.position.clone();

  // Compute a mid control point for a nice curve
  const mid = v1.clone().add(v2).multiplyScalar(0.5);
  const lift = v2.clone().sub(v1).length() / 4;
  const control = mid.clone().add(new THREE.Vector3(0, lift, 0));

  // Create curve
  const curve = new THREE.CatmullRomCurve3(
    [v1, control, v2],
    false,
    type,
    tension
  );

  // Create geometry & material
  const geometry = new THREE.BufferGeometry().setFromPoints(
    curve.getPoints(200)
  );
  const material = new THREE.LineBasicMaterial({ color });
  const line = new THREE.Line(geometry, material);

  scene.add(line);
  return line;
}

/** Creates a Uniform Catmull–Rom curve */
export function createUniformCurve(
  scene,
  p1,
  p2,
  tension = 0.5,
  color = "red"
) {
  return makeCurve(scene, p1, p2, "catmullrom", tension, color);
}

/** Creates a Centripetal Catmull–Rom curve */
export function createCentripetalCurve(
  scene,
  p1,
  p2,
  tension = 0.5,
  color = "red"
) {
  return makeCurve(scene, p1, p2, "centripetal", tension, color);
}

/** Creates a Chordal Catmull–Rom curve */
export function createChordalCurve(
  scene,
  p1,
  p2,
  tension = 0.5,
  color = "red"
) {
  return makeCurve(scene, p1, p2, "chordal", tension, color);
}
