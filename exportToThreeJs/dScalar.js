import { addDependency, updateDependencies } from "./dependency.js";

export function dScalar(...args) {
  let opts = {};
  if (args.length >= 2 && isPlainObject(args[args.length - 1])) {
    opts = args.pop(); // eslint-disable-line no-unused-vars
  }

  const fnIndex = args.findIndex((a) => typeof a === "function");
  if (fnIndex === -1) {
    throw new Error("dScalar: a callback function is required.");
  }

  const callback = args[fnIndex];
  const sources = args.slice(0, fnIndex).concat(args.slice(fnIndex + 1));
  const expectedArgs = sources.length;
  if (callback.length !== expectedArgs) {
    throw new Error(`dScalar: callback needs ${expectedArgs} argument(s).`);
  }

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
    if (src.position && src.position.isVector3)
      return { x: src.position.x, y: src.position.y };
    if (src.isVector2 || src.isVector3) return src;
    if (Array.isArray(src)) return src;
    if (typeof src === "object" && ("x" in src || "y" in src || "z" in src))
      return src;
    return src;
  };

  const recompute = () => {
    const values = sources.map(extractValue);
    const res = callback(...values);
    if (!Number.isFinite(res)) {
      throw new Error("dScalar: callback must return a finite number.");
    }
    scalar.value = res;
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

  sources.forEach(attachDep);

  return scalar;
}

function isPlainObject(o) {
  if (!o || typeof o !== "object") return false;
  const proto = Object.getPrototypeOf(o);
  return proto === Object.prototype || proto === null;
}
