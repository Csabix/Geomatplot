import * as THREE from "three";
import { addDependency } from "./dependency.js";

/**
 * polygon(scene, ...inputsOrPosition [, opts])
 *
 * Overloads:
 *   1) polygon(scene, [[x,y], ...], opts?)
 *       - "movable" polygon defined by a fixed coordinate array (no dependencies)
 *
 *   2) polygon(scene, A, B, ..., opts?)
 *       - dependent polygon: inputs can be
 *           * point-like: mesh with .position, THREE.Vector3, [x,y,(z)], {x,y,(z)}
 *           * pointSequence object (from pointSequence.js)
 *           * another polygon (this module)
 *           * THREE.Line (polyline – its vertices are used)
 *       - all vertices are concatenated in the given order and connected.
 *
 * opts:
 *   {
 *     color?: number|string,    // edge & fill color, default 0x0000ff (like 'b')
 *     lineWidth?: number,       // outline width, default 1
 *     faceAlpha?: number,       // [0,1], default 0.15 (MATLAB default)
 *     visible?: boolean,        // default true
 *     hidden?: boolean          // if true, hides the polygon (alias for visible=false)
 *   }
 *
 * Returns:
 *   {
 *     group: THREE.Group,
 *     outline: THREE.LineLoop,
 *     fill: THREE.Mesh,
 *     getVertices(): [ [x,y], ... ],
 *     setColor(c): void,
 *     setLineWidth(w): void,
 *     setFaceAlpha(a): void,
 *     setVisible(v): void,
 *     isPolygon: true
 *   }
 */

export function polygon(scene, ...args) {
  if (!scene || !scene.isScene) {
    throw new Error("polygon: first argument must be a THREE.Scene");
  }

  let opts = {};
  if (
    args.length &&
    isPlainObject(args[args.length - 1]) &&
    !isThreeObject(args[args.length - 1])
  ) {
    opts = args.pop();
  }

  const color = opts.color ?? 0x0000ff;
  const lineWidth = opts.lineWidth ?? 1;
  const faceAlpha = opts.faceAlpha ?? 0.15;
  const visible = opts.hidden ? false : opts.visible ?? true;

  let inputs = args;

  let explicitPositions = null;
  if (
    inputs.length === 1 &&
    Array.isArray(inputs[0]) &&
    inputs[0].length &&
    Array.isArray(inputs[0][0])
  ) {
    explicitPositions = inputs[0];
    inputs = [];
  }

  const group = new THREE.Group();
  group.visible = visible;

  const outlineGeom = new THREE.BufferGeometry();
  const outlineMat = new THREE.LineBasicMaterial({
    color: new THREE.Color(color),
    linewidth: lineWidth,
  });
  const outline = new THREE.LineLoop(outlineGeom, outlineMat);
  group.add(outline);

  const fillShape = new THREE.Shape();
  const fillGeom = new THREE.ShapeGeometry(fillShape);
  const fillMat = new THREE.MeshBasicMaterial({
    color: new THREE.Color(color),
    opacity: faceAlpha,
    transparent: faceAlpha < 1,
    side: THREE.DoubleSide,
  });
  const fill = new THREE.Mesh(fillGeom, fillMat);
  group.add(fill);

  scene.add(group);

  let _vertices = [];

  function rebuildVertices() {
    let verts = [];

    if (explicitPositions) {
      for (const row of explicitPositions) {
        verts.push([+row[0] || 0, +row[1] || 0]);
      }
    } else {
      for (const inp of inputs) {
        const part = verticesFromInput(inp);
        verts = verts.concat(part);
      }
    }

    if (verts.length < 3) {
      group.visible = false;
      _vertices = [];
      return;
    }

    _vertices = verts;
    updateGeometryFromVertices(verts);
    group.visible = visible;
  }

  function updateGeometryFromVertices(verts) {
    const pts3 = verts.map(([x, y]) => new THREE.Vector3(x, y, 0));
    const lineGeom = new THREE.BufferGeometry().setFromPoints(pts3);
    outline.geometry.dispose();
    outline.geometry = lineGeom;

    const shape = new THREE.Shape();
    if (verts.length) {
      shape.moveTo(verts[0][0], verts[0][1]);
      for (let i = 1; i < verts.length; i++) {
        shape.lineTo(verts[i][0], verts[i][1]);
      }
      shape.closePath();
    }
    const fg = new THREE.ShapeGeometry(shape);
    fill.geometry.dispose();
    fill.geometry = fg;
  }

  rebuildVertices();

  if (!explicitPositions) {
    for (const inp of inputs) {
      attachDependencyForInput(inp, rebuildVertices, group);
    }
  }

  return {
    group,
    outline,
    fill,
    getVertices() {
      return _vertices.map(([x, y]) => [x, y]);
    },
    setColor(c) {
      outline.material.color = new THREE.Color(c);
      outline.material.needsUpdate = true;
      fill.material.color = new THREE.Color(c);
      fill.material.needsUpdate = true;
    },
    setLineWidth(w) {
      outline.material.linewidth = w;
      outline.material.needsUpdate = true;
    },
    setFaceAlpha(a) {
      fill.material.opacity = a;
      fill.material.transparent = a < 1;
      fill.material.needsUpdate = true;
    },
    setVisible(v) {
      group.visible = !!v;
    },
    isPolygon: true,
  };
}

function isPlainObject(o) {
  return o && typeof o === "object" && !o.isObject3D && !Array.isArray(o);
}
function isThreeObject(o) {
  return !!(o && o.isObject3D);
}
function isMesh(o) {
  return !!(o && o.isObject3D && o.position && o.position.isVector3);
}
function isVec3(o) {
  return !!(o && o.isVector3);
}
function isPointSequence(o) {
  return !!(o && o.isPointSequence && o.group && o.points);
}
function isPolygon(o) {
  return !!(o && o.isPolygon && o.group);
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

function toVec3Like(o) {
  if (isMesh(o)) return o.position;
  if (isVec3(o)) return o;
  if (Array.isArray(o))
    return new THREE.Vector3(o[0] ?? 0, o[1] ?? 0, o[2] ?? 0);
  if (o && typeof o === "object" && "x" in o && "y" in o) {
    return new THREE.Vector3(o.x ?? 0, o.y ?? 0, o.z ?? 0);
  }
  throw new Error("polygon: unsupported point-like input.");
}

function verticesFromInput(inp) {
  if (isPointSequence(inp)) {
    return inp.getArray().map(([x, y]) => [x, y]);
  }
  if (isPolygon(inp)) {
    return inp.getVertices().map(([x, y]) => [x, y]);
  }
  if (isLine(inp)) {
    const pos = inp.geometry.getAttribute("position");
    const out = [];
    for (let i = 0; i < pos.count; i++) {
      out.push([pos.getX(i), pos.getY(i)]);
    }
    return out;
  }
  if (Array.isArray(inp) && inp.length) {
    const out = [];
    for (const item of inp) {
      if (Array.isArray(item)) {
        // [x,y]
        const [x, y] = item;
        out.push([+x || 0, +y || 0]);
      } else {
        // point-like (mesh, vec3, object ...)
        const v = toVec3Like(item);
        out.push([v.x, v.y]);
      }
    }
    return out;
  }
  const v = toVec3Like(inp);
  return [[v.x, v.y]];
}

function attachDependencyForInput(inp, callback, group) {
  const wrapped = () => callback();

  if (isMesh(inp)) {
    addDependency(inp, group, wrapped);
  } else if (isLine(inp)) {
    addDependency(inp, group, wrapped);
  } else if (isPointSequence(inp)) {
    addDependency(inp.group, group, wrapped);
  } else if (isPolygon(inp)) {
    addDependency(inp.group, group, wrapped);
  } else if (Array.isArray(inp)) {
    for (const item of inp) {
      if (isMesh(item)) {
        addDependency(item, group, wrapped);
      } else if (!Array.isArray(item)) {
        try {
          const v = toVec3Like(item);
          addDependency(item, group, wrapped);
        } catch {}
      }
    }
  }
}
