import * as THREE from "three";
import { addDependency } from "./dependency.js";

function toVec2Like(p) {
  if (p && p.position && p.position.isVector3)
    return new THREE.Vector2(p.position.x, p.position.y);
  if (p && p.isVector2) return p;
  if (p && p.isVector3) return new THREE.Vector2(p.x, p.y);
  if (Array.isArray(p)) return new THREE.Vector2(p[0] ?? 0, p[1] ?? 0);
  if (p && typeof p === "object" && "x" in p && "y" in p)
    return new THREE.Vector2(p.x ?? 0, p.y ?? 0);
  throw new Error(
    "Point must be Mesh/Object3D, Vector2/Vector3, [x,y(,z)], or {x,y(,z)}"
  );
}

function isMesh(p) {
  return !!(p && p.position && p.position.isVector3 && p.isObject3D);
}

function isScalarLike(v) {
  return (
    typeof v === "number" ||
    (v && (typeof v.getValue === "function" || typeof v.value === "number"))
  );
}

function isScalarSource(v) {
  return v && (typeof v.getValue === "function" || typeof v.value === "number");
}

function buildCircleGeometry(center, radius, segments = 128) {
  const pts = [];
  const cx = center.x,
    cy = center.y;
  for (let i = 0; i <= segments; i++) {
    const t = (i / segments) * Math.PI * 2;
    pts.push(
      new THREE.Vector2(cx + Math.cos(t) * radius, cy + Math.sin(t) * radius)
    );
  }
  return new THREE.BufferGeometry().setFromPoints(pts);
}

function circumcircle2D(A, B, C) {
  const ax = A.x,
    ay = A.y;
  const bx = B.x,
    by = B.y;
  const cx = C.x,
    cy = C.y;

  const d = 2 * (ax * (by - cy) + bx * (cy - ay) + cx * (ay - by));
  if (Math.abs(d) < 1e-9) return null;

  const a2 = ax * ax + ay * ay;
  const b2 = bx * bx + by * by;
  const c2 = cx * cx + cy * cy;

  const ux = (a2 * (by - cy) + b2 * (cy - ay) + c2 * (ay - by)) / d;
  const uy = (a2 * (cx - bx) + b2 * (ax - cx) + c2 * (bx - ax)) / d;

  const center = new THREE.Vector2(ux, uy);
  const radius = Math.hypot(ux - ax, uy - ay);
  return { center, radius };
}

export function circle(scene, A, B, C_or_opts, maybeOpts) {
  let mode;
  let C = undefined;
  let radiusSource = undefined;
  let opts =
    typeof C_or_opts === "object" &&
    !Array.isArray(C_or_opts) &&
    !isMesh(C_or_opts) &&
    !("isVector3" in (C_or_opts || {})) &&
    !("isVector2" in (C_or_opts || {}))
      ? C_or_opts
      : maybeOpts || {};

  if (C_or_opts !== undefined && C_or_opts !== opts) {
    C = C_or_opts;
    mode = "three";
  } else if (isScalarLike(B)) {
    mode = "fixedRadius";
    radiusSource = B;
  } else {
    mode = "throughPoint";
  }

  const color = opts.color ?? 0x222222;
  const segments = opts.segments ?? 128;
  const centerSize = opts.centerSize ?? 4;
  const centerColor = opts.centerColor ?? 0x8888ff;
  const hidden = !!opts.hidden;

  const material = new THREE.LineBasicMaterial({ color });
  const line = new THREE.Line(new THREE.BufferGeometry(), material);
  line.visible = !hidden;
  scene.add(line);

  const centerMarker = new THREE.Mesh(
    new THREE.CircleGeometry(centerSize, 24),
    new THREE.MeshBasicMaterial({ color: centerColor })
  );
  centerMarker.visible = !hidden;
  scene.add(centerMarker);

  let currentCenter = new THREE.Vector2(0, 0);
  let currentRadius = 0;

  const readRadius = () => {
    if (!isScalarLike(radiusSource)) return /** @type {number} */ (B);
    if (typeof radiusSource.getValue === "function") {
      const v = radiusSource.getValue();
      return v && typeof v.__depValue !== "undefined" ? v.__depValue : v;
    }
    if (typeof radiusSource.value === "number") return radiusSource.value;
    return /** @type {number} */ (radiusSource);
  };

  function rebuild() {
    if (hidden) {
      line.visible = false;
      centerMarker.visible = false;
      return;
    }

    if (mode === "three") {
      const a2 = toVec2Like(A),
        b2 = toVec2Like(B),
        c2 = toVec2Like(C);
      const cc = circumcircle2D(a2, b2, c2);
      if (!cc) {
        line.visible = false;
        centerMarker.visible = false;
        return;
      }
      line.visible = true;
      centerMarker.visible = true;
      currentCenter.copy(cc.center);
      currentRadius = cc.radius;
      line.geometry.dispose();
      line.geometry = buildCircleGeometry(
        currentCenter,
        currentRadius,
        segments
      );
      centerMarker.position.set(currentCenter.x, currentCenter.y, 0);
    } else if (mode === "throughPoint") {
      const a = toVec2Like(A);
      const b = toVec2Like(B);
      currentCenter.set(a.x, a.y);
      currentRadius = Math.hypot(b.x - a.x, b.y - a.y);
      line.visible = true;
      centerMarker.visible = true;
      line.geometry.dispose();
      line.geometry = buildCircleGeometry(
        currentCenter,
        currentRadius,
        segments
      );
      centerMarker.position.set(currentCenter.x, currentCenter.y, 0);
    } else {
      const a = toVec2Like(A);
      currentCenter.set(a.x, a.y);
      currentRadius = readRadius();
      line.visible = true;
      centerMarker.visible = true;
      line.geometry.dispose();
      line.geometry = buildCircleGeometry(
        currentCenter,
        currentRadius,
        segments
      );
      centerMarker.position.set(currentCenter.x, currentCenter.y, 0);
    }
  }

  rebuild();

  const sources = [];
  if (isMesh(A)) sources.push(A);
  if (mode === "throughPoint" && isMesh(B)) sources.push(B);
  if (mode === "three" && isMesh(B)) sources.push(B);
  if (mode === "three" && C && isMesh(C)) sources.push(C);
  if (mode === "fixedRadius" && isScalarSource(radiusSource)) {
    sources.push(radiusSource);
  }

  for (const s of sources) {
    addDependency(s, line, rebuild);
    addDependency(s, centerMarker, rebuild);
  }

  return {
    line,
    centerMarker,
    getCenter: () => currentCenter.clone(),
    getRadius: () => currentRadius,
    unlink: () => {},
  };
}
