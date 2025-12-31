import * as THREE from "three";
import { addDependency } from "./dependency.js";

/**
 * PointSequence(scene, ...inputs [, callback] [, opts])
 *
 * Inputs (any mix, any count ≥ 0):
 *  - Point-like:  THREE.Mesh/Object3D (uses .position), THREE.Vector2/Vector3, [x,y,(z)], {x,y,(z)}
 *  - PointSequence: another object returned by this function
 *  - Polygon/Line: THREE.Line (its geometry positions are used)
 *
 * Optional callback at the end:
 *    (A,B,...) -> [ [x,y], [x,y], ... ]
 *  - Receives the *values* of inputs:
 *      * point-like → [x,y]
 *      * point-sequence → [[x,y], ...]
 *      * line/polygon → [[x,y], ...]
 *  - Must return an Nx2 array of coordinates.
 *
 * Optional opts object (last param if provided, after callback or inputs):
 *  {
 *    color?: number|string,      // default 'black'
 *    markerSize?: number,         // default 2 (matlab scaled ~ 32px)
 *    visible?: boolean,           // default true
 *    hidden?: boolean,            // default false (alias for visible=false)
 *    sizeAttenuation?: boolean    // default false (pixel-sized points)
 *  }
 *
 * Returns:
 *  {
 *    group: THREE.Group,                // added to scene
 *    points: THREE.Points,              // marker point cloud
 *    getArray(): Array<[number,number]>,// current [x,y] list
 *    setColor(c): void,
 *    setMarkerSize(s): void,
 *    setVisible(v): void,
 *    isPointSequence: true
 *  }
 */

export function pointSequence(...args) {
  if (args.length < 1)
    throw new Error("PointSequence: first arg must be scene.");
  const scene = args[0];
  if (!scene || !scene.isScene)
    throw new Error("PointSequence: first arg must be a THREE.Scene.");

  let callback = null;
  let opts = {};
  let inps = args.slice(1);

  if (
    inps.length &&
    typeof inps[inps.length - 1] === "object" &&
    !isFunc(inps[inps.length - 1]) &&
    !isThreeObj(inps[inps.length - 1]) &&
    !inps[inps.length - 1].isVector2 &&
    !inps[inps.length - 1].isVector3
  ) {
    opts = inps.pop();
  }
  if (inps.length && isFunc(inps[inps.length - 1])) {
    callback = inps.pop();
  }

  const color = opts.color ?? 0x000000;
  const markerSize = opts.markerSize ?? 2;
  const visible = opts.hidden ? false : opts.visible ?? true;
  const sizeAttenuation = opts.sizeAttenuation ?? false;

  const group = new THREE.Group();
  const geom = new THREE.BufferGeometry();
  const mat = new THREE.PointsMaterial({
    color: new THREE.Color(color),
    size: 8 * markerSize,
    sizeAttenuation,
    map: makeCircleTexture(64),
    transparent: true,
    alphaTest: 0.5,
  });
  const points = new THREE.Points(geom, mat);
  group.add(points);
  group.visible = visible;
  scene.add(group);

  function valueOfInput(inp) {
    if (isPointSequence(inp)) return inp.getArray();

    if (isLine(inp)) {
      return arrayFromLine(inp);
    }

    if (isPointLike(inp)) {
      const v = toVec2Like(inp);
      return [v.x, v.y];
    }

    if (Array.isArray(inp)) {
      if (inp.length && isPointLike(inp[0])) {
        return inp.map((p) => {
          const v = toVec2Like(p);
          return [v.x, v.y];
        });
      }
    }

    throw new Error("PointSequence: unsupported input type.");
  }

  function concatValues(arraysOrPairs) {
    const out = [];
    for (const it of arraysOrPairs) {
      if (Array.isArray(it) && it.length && Array.isArray(it[0])) {
        for (const row of it) out.push([row[0], row[1]]);
      } else {
        out.push([it[0], it[1]]);
      }
    }
    return out;
  }

  function recompute() {
    let xy;
    try {
      if (!callback) {
        const vals = inps.map(valueOfInput);
        xy = concatValues(vals);
      } else {
        const vals = inps.map(valueOfInput);
        xy = callback(...vals);
      }
      if (!Array.isArray(xy))
        throw new Error("PointSequence callback must return Nx2 array.");
    } catch (e) {
      group.visible = false;
      return;
    }

    const n = xy.length | 0;
    const arr = new Float32Array(n * 3);
    for (let i = 0; i < n; i++) {
      const xi = +xy[i][0] || 0;
      const yi = +xy[i][1] || 0;
      arr[i * 3 + 0] = xi;
      arr[i * 3 + 1] = yi;
      arr[i * 3 + 2] = 0;
    }

    geom.setAttribute("position", new THREE.BufferAttribute(arr, 3));
    geom.attributes.position.needsUpdate = true;
    geom.computeBoundingSphere?.();

    group.visible = visible;
    _currentArray = xy;
  }

  function wireDependencies() {
    for (const inp of inps) {
      if (isMesh(inp)) {
        addDependency(inp, group, recompute);
      } else if (isLine(inp)) {
        addDependency(inp, group, recompute);
      } else if (isPointSequence(inp)) {
        addDependency(inp.group, group, recompute);
      } else if (Array.isArray(inp)) {
        for (const p of inp) {
          if (isMesh(p)) addDependency(p, group, recompute);
        }
      }
    }
  }

  let _currentArray = [];
  recompute();
  wireDependencies();

  return {
    group,
    points,
    getArray: () => _currentArray.map(([x, y]) => [x, y]),
    setColor(c) {
      points.material.color = new THREE.Color(c);
      points.material.needsUpdate = true;
    },
    setMarkerSize(s) {
      points.material.size = 16 * s;
      points.material.needsUpdate = true;
    },
    setVisible(v) {
      group.visible = !!v;
    },
    isPointSequence: true,
  };
}

function isFunc(f) {
  return typeof f === "function";
}
function isThreeObj(o) {
  return !!(o && o.isObject3D);
}
function isMesh(o) {
  return !!(o && o.isObject3D && o.position && o.position.isVector3);
}
function isVec2(o) {
  return !!(o && o.isVector2);
}
function isVec3(o) {
  return !!(o && o.isVector3);
}
function isPointSequence(o) {
  return !!(o && o.isPointSequence && o.group && o.points);
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
function toVec2Like(o) {
  if (isMesh(o)) return new THREE.Vector2(o.position.x, o.position.y);
  if (isVec2(o)) return o;
  if (isVec3(o)) return new THREE.Vector2(o.x, o.y);
  if (Array.isArray(o)) return new THREE.Vector2(o[0] ?? 0, o[1] ?? 0);
  if (o && typeof o === "object" && "x" in o && "y" in o)
    return new THREE.Vector2(o.x ?? 0, o.y ?? 0);
  throw new Error("Unsupported point-like.");
}
function isLine(o) {
  return !!(
    o &&
    o.isLine &&
    o.geometry &&
    o.geometry.attributes &&
    o.geometry.attributes.position
  );
}
function arrayFromLine(line) {
  const pos = line.geometry.getAttribute("position");
  const out = [];
  for (let i = 0; i < pos.count; i++) {
    out.push([pos.getX(i), pos.getY(i)]);
  }
  return out;
}

function makeCircleTexture(size = 64, color = "white") {
  const canvas = document.createElement("canvas");
  canvas.width = canvas.height = size;
  const ctx = canvas.getContext("2d");
  const r = size / 2;

  const grad = ctx.createRadialGradient(r, r, 0, r, r, r);
  grad.addColorStop(0, color);
  grad.addColorStop(0.9, color);
  grad.addColorStop(1, "rgba(255,255,255,0)");

  ctx.fillStyle = grad;
  ctx.beginPath();
  ctx.arc(r, r, r, 0, Math.PI * 2);
  ctx.fill();

  const tex = new THREE.CanvasTexture(canvas);
  tex.minFilter = THREE.LinearFilter;
  tex.magFilter = THREE.LinearFilter;
  tex.needsUpdate = true;
  return tex;
}
