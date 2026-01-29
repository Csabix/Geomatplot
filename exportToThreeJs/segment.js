import * as THREE from "three";
import { addDependency } from "./dependency.js";

/**
 * SEGMENT  draws straight segments.
 *
 * Overloads:
 *   1) segment(scene, A, B, opts?)
 *      - A, B: point-like (mesh with .position, Vector2/Vector3, [x,y,(z)], {x,y,(z)})
 *      → single segment A–B
 *
 *   2) segment(scene, A, v, opts?)
 *      - A: point-like
 *      - v: vector-like (Vector2/Vector3, [x,y,(z)], {x,y,(z)}, or object with getVector():Vector3)
 *      → single segment A–(A+v)
 *
 *   3) segment(scene, P1, P2, ..., Pn, opts?)   (n >= 2)
 *      - all Pi: point-like
 *      → polyline P1–P2–...–Pn
 *
 * opts:
 *   - color?: number|string = 0x000000
 *   - linewidth?: number = 1
 *   - dashed?: boolean = false
 *   - hidden?: boolean = false
 *
 * Returns:
 *   {
 *     line: THREE.Line,
 *     getEndpoints(): { A: THREE.Vector2, B: THREE.Vector2 },
 *     getPoints(): THREE.Vector2[],
 *     setColor(c): void,
 *     setLinewidth(w): void
 *   }
 */

function isMesh(o) {
  return !!(o && o.isObject3D && o.position && o.position.isVector3);
}
function isVec2(o) {
  return !!(o && o.isVector2);
}
function isVec3(o) {
  return !!(o && o.isVector3);
}
function isPointLike(o) {
  return (
    isMesh(o) ||
    isVec2(o) ||
    isVec3(o) ||
    Array.isArray(o) ||
    (o && typeof o === "object" && "x" in o && "y" in o)
  );
}
function toVec2(o) {
  if (isMesh(o)) return new THREE.Vector2(o.position.x, o.position.y);
  if (isVec2(o)) return o.clone();
  if (isVec3(o)) return new THREE.Vector2(o.x, o.y);
  if (Array.isArray(o)) return new THREE.Vector2(o[0] ?? 0, o[1] ?? 0);
  if (o && typeof o === "object" && "x" in o && "y" in o)
    return new THREE.Vector2(o.x ?? 0, o.y ?? 0);
  throw new Error("Unsupported point/vector input.");
}
function isVectorProvider(o) {
  return !!(o && typeof o.getVector === "function");
}
function isPlainOpts(o) {
  return (
    !!o &&
    typeof o === "object" &&
    !Array.isArray(o) &&
    !isMesh(o) &&
    !isVec2(o) &&
    !isVec3(o) &&
    !("x" in o && "y" in o) &&
    !isVectorProvider(o)
  );
}

export function segment(scene, ...args) {
  if (!scene || !scene.isScene) {
    throw new Error("segment: first argument must be a THREE.Scene");
  }

  if (args.length < 2) {
    throw new Error("segment: expected at least 2 arguments after scene.");
  }

  // Extract opts if last arg is a plain object
  let opts = {};
  if (isPlainOpts(args[args.length - 1])) {
    opts = args.pop();
  }

  const inputs = args; // P1, P2, ..., Pn  OR (A, B_or_v)

  if (inputs.length < 2) {
    throw new Error("segment: need at least two points/vectors.");
  }

  const color = opts.color ?? 0x000000;
  const linewidth = opts.linewidth ?? 1;
  const dashed = !!opts.dashed;
  const hidden = !!opts.hidden;

  let mode = "polyline"; // default: multi-point
  let A = inputs[0];
  let B_or_v = inputs[1];

  // If exactly 2 inputs, we keep old point_point / point_vector mode behaviour
  if (inputs.length === 2) {
    const B_is_pointlike = isPointLike(B_or_v);
    mode = B_is_pointlike ? "point_point" : "point_vector";
  }

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
  line.visible = !hidden;
  scene.add(line);

  function pointsNow() {
    if (mode === "polyline") {
      // Any number of point-like inputs P1..Pn
      const pts = inputs.map((p) => {
        return toVec2(p);
      });
      return pts;
    }

    // point_point / point_vector legacy behaviour
    const a = toVec2(A);
    let b;
    if (mode === "point_point") {
      b = toVec2(B_or_v);
    } else {
      if (isVectorProvider(B_or_v)) {
        const v = B_or_v.getVector();
        const vv = isVec2(v) ? v : toVec2(v);
        b = a.clone().add(vv);
      } else {
        const v = toVec2(B_or_v);
        b = a.clone().add(v);
      }
    }
    return [a, b];
  }

  function rebuild() {
    const pts = pointsNow();
    line.geometry.dispose();
    const pts3 = pts.map((v) => new THREE.Vector3(v.x, v.y, 0));
    line.geometry = new THREE.BufferGeometry().setFromPoints(pts3);
    if (line.material && line.material.isLineDashedMaterial) {
      line.computeLineDistances();
    }
  }

  rebuild();

  // Dependencies: whenever an input mesh or vector provider changes, rebuild
  const addDepsForInput = (inp) => {
    if (isMesh(inp)) {
      addDependency(inp, line, () => rebuild());
    } else if (isVectorProvider(inp)) {
      addDependency(inp, line, () => rebuild());
    }
  };

  if (mode === "polyline") {
    for (const p of inputs) addDepsForInput(p);
  } else {
    addDepsForInput(A);
    if (mode === "point_point" || isVectorProvider(B_or_v)) {
      addDepsForInput(B_or_v);
    }
  }

  return {
    line,
    getEndpoints() {
      const pts = pointsNow();
      if (pts.length === 0) {
        return {
          A: new THREE.Vector2(),
          B: new THREE.Vector2(),
        };
      }
      return {
        A: pts[0].clone(),
        B: pts[pts.length - 1].clone(),
      };
    },
    getPoints() {
      return pointsNow().map((v) => v.clone());
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
