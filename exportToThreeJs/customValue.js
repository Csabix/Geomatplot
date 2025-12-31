import * as THREE from "three";
import {
  addDependency,
  updateDependencies,
  DependencySystem,
} from "./dependency.js";

/**
 * CustomValue
 * -----------
 * Creates a dependent "custom value" driven by arbitrary inputs.
 *
 * JS version of MATLAB:
 *   CustomValue({A,B,...}, callback) -> dependent object
 *
 * Usage:
 *   const cv = customValue([pointA, pointB], (a, b) => {
 *     // a, b are "values" extracted from inputs:
 *     // - for points: THREE.Vector2 (position)
 *     // - for scalars: number
 *     // - otherwise: passed through
 *     return a.distanceTo(b);
 *   });
 *
 *   console.log(cv.getValue());
 *   const off = cv.onChange(v => console.log("custom value =", v));
 *
 * Options:
 *   - dependencySystem?: DependencySystem
 */
export function customValue(inputs, userCallback, options = {}) {
  if (typeof userCallback !== "function") {
    throw new Error(
      "customValue(inputs, callback): callback must be a function"
    );
  }

  const depSys =
    options.dependencySystem instanceof DependencySystem
      ? options.dependencySystem
      : null; // optional local system

  // Normalize inputs to array
  const inArray = Array.isArray(inputs) ? inputs : [inputs];

  // --- How to extract a "value" from each input ---------------------------
  function extractValue(obj) {
    if (obj == null) return obj;

    // Three.js object (point) -> use its position (2D)
    if (obj.isObject3D && obj.position && obj.position.isVector3) {
      return new THREE.Vector2(obj.position.x, obj.position.y);
    }

    if (obj.isVector2) return obj;
    if (obj.isVector3) return new THREE.Vector2(obj.x, obj.y);

    // Objects with getValue() method (e.g. distance, scalar, etc.)
    if (typeof obj.getValue === "function") {
      return obj.getValue();
    }

    // Objects with .value property
    if (Object.prototype.hasOwnProperty.call(obj, "value")) {
      return obj.value;
    }

    // Plain number, array, etc. -> pass through
    return obj;
  }

  // --- Internal state + listeners ----------------------------------------
  let currentValue = undefined;
  const listeners = new Set();

  function notify(newVal) {
    for (const fn of listeners) {
      try {
        fn(newVal);
      } catch (e) {
        console.warn("customValue listener error:", e);
      }
    }
  }

  // --- Public API object (also used as dependency target) -----------------
  const self = {
    /**
     * Get the current value (may be undefined if callback failed).
     */
    getValue() {
      return wrapValue(currentValue, self);
    },

    /**
     * Subscribe to changes. Returns an unsubscribe function.
     * @param {(value: any) => void} fn
     */
    onChange(fn) {
      if (typeof fn !== "function") return () => {};
      listeners.add(fn);
      // immediate call if you want the current value right away:
      fn(currentValue);
      return () => listeners.delete(fn);
    },

    /**
     * Force recompute (usually not needed; dependency system calls rebuild).
     */
    recompute: () => rebuild(),

    /**
     * Expose raw inputs for debugging.
     */
    inputs: inArray,
  };

  // --- Rebuild function (called when any input changes) -------------------
  function rebuild() {
    try {
      const args = inArray.map(extractValue);
      const v = userCallback(...args);
      currentValue = v;
      notify(v);
    } catch (e) {
      console.warn(
        "customValue: callback threw error, marking value undefined.",
        e
      );
      currentValue = undefined;
      notify(undefined);
    }
    wrapValue.sourceRef = self;
    const updater = depSys
      ? depSys.updateDependencies.bind(depSys)
      : updateDependencies;
    updater(self);
  }

  // --- Register dependencies ---------------------------------------------
  for (const src of inArray) {
    // Only things that can change need to be wired (points, other dependents)
    if (src && (src.isObject3D || typeof src === "object")) {
      if (depSys) {
        depSys.addDependency(src, self, rebuild);
      } else {
        addDependency(src, self, rebuild);
      }
    }
  }

  // Initial computation
  rebuild();

  // --- Public API ---------------------------------------------------------
  return self;
}

function wrapValue(v, sourceRef) {
  // Always return a wrapper object so consumers can find the source and unwrap safely.
  return {
    __depSource: sourceRef,
    __depValue: v,
  };
}
