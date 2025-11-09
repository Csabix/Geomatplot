import * as THREE from "three";
import { addDependency } from "./dependency.js";

/**
 * SEGMENT  draws a straight segment (A,B) or (A, A+v).
 *
 * Overloads:
 *   segment(scene, A, B, opts?)
 *     - A, B: point-like (mesh with .position, Vector3, [x,y,(z)], {x,y,(z)})
 *
 *   segment(scene, A, v, opts?)
 *     - A: point-like
 *     - v: vector-like (Vector3, [x,y,(z)], {x,y,(z)}, or object with getVector():Vector3)
 *
 * opts:
 *   - color?: number|string = 0x000000
 *   - linewidth?: number = 1
 *   - dashed?: boolean = false
 *
 * Returns:
 *   {
 *     line: THREE.Line,
 *     getEndpoints(): { A: THREE.Vector3, B: THREE.Vector3 },
 *     setColor(c): void,
 *     setLinewidth(w): void
 *   }
 */

function isMesh(o) {
  return !!(o && o.isObject3D && o.position && o.position.isVector3);
}
function isVec3(o) {
  return !!(o && o.isVector3);
}
function toVec3(o) {
  if (isMesh(o)) return o.position.clone();
  if (isVec3(o)) return o.clone();
  if (Array.isArray(o))
    return new THREE.Vector3(o[0] ?? 0, o[1] ?? 0, o[2] ?? 0);
  if (o && typeof o === "object" && "x" in o && "y" in o)
    return new THREE.Vector3(o.x ?? 0, o.y ?? 0, o.z ?? 0);
  throw new Error("Unsupported point/vector input.");
}
function isVectorProvider(o) {
  return !!(o && typeof o.getVector === "function");
}

export function segment(scene, A, B_or_v, opts = {}) {
  const color = opts.color ?? 0x000000;
  const linewidth = opts.linewidth ?? 1;
  const dashed = !!opts.dashed;

  const B_is_pointlike =
    isMesh(B_or_v) ||
    isVec3(B_or_v) ||
    Array.isArray(B_or_v) ||
    (B_or_v && typeof B_or_v === "object" && "x" in B_or_v && "y" in B_or_v);

  const mode = B_is_pointlike ? "point_point" : "point_vector";

  const material = dashed
    ? new THREE.LineDashedMaterial({
        color,
        linewidth,
        dashSize: 6,
        gapSize: 3,
      })
    : new THREE.LineBasicMaterial({ color, linewidth });

  const geometry = new THREE.BufferGeometry();
  const line = new THREE.Line(geometry, material);
  scene.add(line);

  function endpointsNow() {
    const a = toVec3(A);
    let b;
    if (mode === "point_point") {
      b = toVec3(B_or_v);
    } else {
      if (isVectorProvider(B_or_v)) {
        const v = B_or_v.getVector();
        const vv = isVec3(v) ? v : toVec3(v);
        b = a.clone().add(vv);
      } else {
        const v = toVec3(B_or_v);
        b = a.clone().add(v);
      }
    }

    a.z = 0;
    b.z = 0;
    return { a, b };
  }

  function rebuild() {
    const { a, b } = endpointsNow();
    const pts = [a, b];
    line.geometry.dispose();
    line.geometry = new THREE.BufferGeometry().setFromPoints(pts);
    if (line.material && line.material.isLineDashedMaterial) {
      line.computeLineDistances();
    }
  }

  rebuild();

  if (isMesh(A)) {
    addDependency(A, line, rebuild);
  }
  if (mode === "point_point") {
    if (isMesh(B_or_v)) addDependency(B_or_v, line, rebuild);
  } else {
    if (isVectorProvider(B_or_v)) {
      addDependency(B_or_v, line, rebuild);
    }
  }

  return {
    line,
    getEndpoints() {
      const { a, b } = endpointsNow();
      return { A: a.clone(), B: b.clone() };
    },
    setColor(c) {
      if (line.material) {
        line.material.color = new THREE.Color(c);
        line.material.needsUpdate = true;
      }
    },
    setLinewidth(w) {
      if (line.material) {
        line.material.linewidth = w;
        line.material.needsUpdate = true;
      }
    },
  };
}
