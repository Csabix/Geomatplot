import * as THREE from "three";
import { addDependency } from "./dependency.js";

export function distance(...args) {
  // Allow final plain-object options (currently unused, kept for future parity)
  let opts = {};
  if (args.length >= 3 && isPlainObject(args[args.length - 1])) {
    opts = args.pop(); // eslint-disable-line no-unused-vars
  }

  // Optional callback overload: distance(...sources, fn, opts?)
  const fnIndex = args.findIndex((a) => typeof a === "function");
  if (fnIndex !== -1) {
    const callback = args[fnIndex];
    const sources = args.slice(0, fnIndex).concat(args.slice(fnIndex + 1));
    return distanceWithCallback(sources, callback);
  }

  if (args.length < 2) {
    throw new Error("distance: expected at least two inputs.");
  }

  const [a, b] = args;
  const listeners = new Set();
  const notify = () => listeners.forEach((fn) => fn(scalar.value));

  const scalar = {
    value: 0,
    getValue() {
      return this.value;
    },
    onChange(fn) {
      if (typeof fn === "function") listeners.add(fn);
    },
    unlink() {},
  };

  function isMesh(o) {
    return !!(o && o.isObject3D && o.position && o.position.isVector3);
  }
  function isVec3(o) {
    return !!(o && o.isVector3);
  }
  function toVec3Like(o) {
    if (isMesh(o)) return o.position;
    if (isVec3(o)) return o;
    if (Array.isArray(o))
      return new THREE.Vector3(o[0] ?? 0, o[1] ?? 0, o[2] ?? 0);
    if (o && typeof o === "object" && "x" in o && "y" in o)
      return new THREE.Vector3(o.x ?? 0, o.y ?? 0, o.z ?? 0);
    throw new Error("Unsupported point-like input.");
  }
  function toVec2(o) {
    const v = toVec3Like(o);
    return new THREE.Vector2(v.x, v.y);
  }
  function isCircleObj(o) {
    return !!(
      o &&
      typeof o.getCenter === "function" &&
      typeof o.getRadius === "function"
    );
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
  function seqFromArray(arr) {
    return arr.map((p) => toVec2(p));
  }
  function seqFromLine(line) {
    const pos = line.geometry.getAttribute("position");
    const out = [];
    for (let i = 0; i < pos.count; i++) {
      out.push(new THREE.Vector2(pos.getX(i), pos.getY(i)));
    }
    return out;
  }

  const dist2 = (p, q) => Math.hypot(p.x - q.x, p.y - q.y);

  function pointToPolylineMinDist(P, poly) {
    let best = Infinity;
    for (let i = 0; i < poly.length - 1; i++) {
      const A = poly[i],
        B = poly[i + 1];
      const dx = B.x - A.x,
        dy = B.y - A.y;
      const len2 = dx * dx + dy * dy;
      let t = 0;
      if (len2 > 0) {
        t = -((A.x - P.x) * dx + (A.y - P.y) * dy) / len2;
        t = Math.max(0, Math.min(1, t));
      }
      const X = A.x + t * dx,
        Y = A.y + t * dy;
      const d = Math.hypot(P.x - X, P.y - Y);
      if (d < best) best = d;
    }
    return best === Infinity ? 0 : best;
  }

  const A2 = toVec2(a);

  let mode = null;
  let B2 = null;
  let SEQ = null;
  let CIRCLE = null;

  if (isCircleObj(b)) {
    mode = "circle";
    CIRCLE = b;
  } else if (isLine(b)) {
    mode = "polyline";
    SEQ = seqFromLine(b);
  } else if (
    Array.isArray(b) &&
    b.length &&
    (isMesh(b[0]) ||
      isVec3(b[0]) ||
      Array.isArray(b[0]) ||
      (b[0] && typeof b[0] === "object" && "x" in b[0]))
  ) {
    mode = "pointseq";
    SEQ = seqFromArray(b);
  } else {
    mode = "point";
    B2 = toVec2(b);
  }

  function recompute() {
    if (mode === "circle") {
      const P = A2.clone();
      const C = CIRCLE.getCenter();
      const R = CIRCLE.getRadius();
      const d = Math.hypot(P.x - C.x, P.y - C.y);
      scalar.value = Math.abs(d - R);
    } else if (mode === "polyline") {
      scalar.value = pointToPolylineMinDist(A2.clone(), SEQ);
    } else if (mode === "pointseq") {
      const p = A2.clone();
      let best = Infinity;
      for (const q of SEQ) {
        const d = dist2(p, q);
        if (d < best) best = d;
      }
      scalar.value = best === Infinity ? 0 : best;
    } else {
      scalar.value = dist2(A2, B2);
    }
    notify();
  }

  recompute();

  if (isMesh(a)) {
    addDependency(a, scalar, () => {
      A2.set(a.position.x, a.position.y);
      recompute();
    });
  }

  if (mode === "circle") {
    if (b.line) addDependency(b.line, scalar, recompute);
    if (b.centerMarker) addDependency(b.centerMarker, scalar, recompute);
  } else if (mode === "polyline") {
    if (isLine(b)) {
      addDependency(b, scalar, () => {
        SEQ = seqFromLine(b);
        recompute();
      });
    }
  } else if (mode === "pointseq") {
    const meshes = b.filter((x) => isMesh(x));
    for (const m of meshes) {
      addDependency(m, scalar, () => {
        SEQ = b.map((item) => toVec2(item));
        recompute();
      });
    }
  } else {
    if (isMesh(b)) {
      addDependency(b, scalar, () => {
        B2.set(b.position.x, b.position.y);
        recompute();
      });
    }
  }

  return scalar;
}

// ---- Custom callback overload ----
function distanceWithCallback(sources, callback) {
  const listeners = new Set();
  const notify = () => listeners.forEach((fn) => fn(scalar.value));

  const scalar = {
    value: 0,
    getValue() {
      return this.value;
    },
    onChange(fn) {
      if (typeof fn === "function") listeners.add(fn);
    },
    unlink() {},
  };

  const extractValue = (src) => {
    if (src == null) return src;
    if (typeof src.getValue === "function") return src.getValue();
    if ("value" in src) return src.value;
    if (src.position && src.position.isVector3) return src.position;
    if (src.isVector3) return src;
    if (Array.isArray(src))
      return new THREE.Vector3(src[0] ?? 0, src[1] ?? 0, src[2] ?? 0);
    if (typeof src === "object" && ("x" in src || "y" in src || "z" in src))
      return new THREE.Vector3(src.x ?? 0, src.y ?? 0, src.z ?? 0);
    return src;
  };

  const toVec3Like = (v, label) => {
    if (v && v.isVector3) return v;
    if (v && v.position && v.position.isVector3) return v.position;
    if (Array.isArray(v))
      return new THREE.Vector3(v[0] ?? 0, v[1] ?? 0, v[2] ?? 0);
    if (typeof v === "object" && v && ("x" in v || "y" in v || "z" in v))
      return new THREE.Vector3(v.x ?? 0, v.y ?? 0, v.z ?? 0);
    throw new Error(`distance: cannot compute base distance, invalid ${label}.`);
  };

  const recompute = () => {
    const values = sources.map(extractValue);
    if (values.length < 2) {
      throw new Error("distance: callback overload needs at least two positional inputs.");
    }
    const p0 = toVec3Like(values[0], "first point");
    const p1 = toVec3Like(values[1], "second point");
    const baseDist = p0.distanceTo(p1);
    const res = callback(baseDist, ...values);
    if (!Number.isFinite(res)) {
      throw new Error("distance: callback must return a finite number.");
    }
    scalar.value = res;
    notify();
  };

  recompute();

  const attachDep = (src) => {
    if (
      src &&
      (src.isObject3D ||
        (src.position && src.position.isVector3) ||
        typeof src.getValue === "function" ||
        "value" in src)
    ) {
      addDependency(src, scalar, recompute);
    }
  };

  sources.forEach(attachDep);

  return scalar;
}

function isPlainObject(o) {
  if (!o || typeof o !== "object") return false;
  const proto = Object.getPrototypeOf(o);
  return proto === Object.prototype || proto === null;
}
