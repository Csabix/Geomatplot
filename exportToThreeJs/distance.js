import { addDependency, updateDependencies } from "./dependency.js";

export function distance(...args) {
  if (args.length !== 2) {
    throw new Error("distance: expected exactly two inputs.");
  }
  if (args.some((a) => typeof a === "function")) {
    throw new Error("distance: callbacks are handled by dScalar.");
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

  const toPoint2 = (o, label) => {
    if (o && typeof o.getValue === "function") {
      return toPoint2(o.getValue(), label);
    }
    if (o && "value" in o) return toPoint2(o.value, label);
    if (o && o.position && o.position.isVector3) {
      return { x: o.position.x, y: o.position.y };
    }
    if (o && (o.isVector2 || o.isVector3)) {
      return { x: o.x, y: o.y };
    }
    if (Array.isArray(o)) {
      return { x: o[0] ?? 0, y: o[1] ?? 0 };
    }
    if (o && typeof o === "object" && "x" in o && "y" in o) {
      return { x: o.x ?? 0, y: o.y ?? 0 };
    }
    throw new Error(`distance: unsupported ${label} point input.`);
  };

  const recompute = () => {
    const A = toPoint2(a, "first");
    const B = toPoint2(b, "second");
    scalar.value = Math.hypot(A.x - B.x, A.y - B.y);
    notify();
    updateDependencies(scalar);
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

  attachDep(a);
  attachDep(b);

  return scalar;
}
