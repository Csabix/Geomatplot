import * as THREE from "three";
import { addDependency } from "./dependency.js";

/**
 * text(scene, pos, arg2, arg3?, arg4?)
 *
 * Supported overloads (matching the MATLAB forms you want):
 *
 * 1) Text(pos, 'asd')
 *    JS: text(scene, pos, 'asd', opts?)
 *
 * 2) Text(pos, {B}, @(B) num2str(B))
 *    JS: text(scene, pos, [B], (B) => String(B), opts?)
 *
 * 3) Text(pos,  B,  @(B) num2str(B))
 *    JS: text(scene, pos, B, (B) => String(B), opts?)
 *
 * Where:
 *   - scene: THREE.Scene
 *   - pos: point-like:
 *       * THREE.Mesh / Object3D with .position
 *       * [x, y] or [x, y, z]
 *       * { x, y, z? }
 *   - B: any "source":
 *       * scalar object with getValue() or .value
 *       * plain number/string
 *       * or even a mesh (we pass some useful value into the callback)
 *
 * opts (optional last argument):
 *   {
 *     color?: number|string,   // default: 0x000000 (black)
 *     fontSize?: number,       // CSS px, default: 18
 *     fontFamily?: string,     // default: "Arial"
 *     offset?: {x:number,y:number} // screen-space-ish world offset, default {x:0,y:0}
 *     hidden?: boolean         // default false; if true, sprite is hidden
 *   }
 *
 * Returns:
 *   {
 *     sprite: THREE.Sprite,
 *     getText(): string,
 *     setText(t: string): void,
 *     setColor(c): void,
 *     setVisible(v: boolean): void,
 *     isText: true
 *   }
 */

export function text(scene, pos, arg2, arg3, arg4) {
  if (!scene || !scene.isScene) {
    throw new Error("text: first argument must be a THREE.Scene");
  }

  let opts = {};
  if (arg4 && isPlainObject(arg4) && !isThreeObject(arg4)) {
    opts = arg4;
  } else if (arg3 && isPlainObject(arg3) && !isThreeObject(arg3)) {
    opts = arg3;
  }

  const color = opts.color ?? 0x000000;
  const fontSize = opts.fontSize ?? 18;
  const fontFamily = opts.fontFamily ?? "Arial";
  const offset = opts.offset ?? { x: 0, y: 0 };
  const hidden = !!opts.hidden;

  let constantText = null;
  let sources = [];
  let callback = null;

  if (typeof arg2 === "string") {
    constantText = arg2;
  } else if (Array.isArray(arg2) && typeof arg3 === "function") {
    sources = arg2;
    callback = arg3;
  } else if (typeof arg3 === "function") {
    sources = [arg2];
    callback = arg3;
  } else {
    throw new Error(
      "text: unsupported argument combination. Expected (pos,'str') or (pos,B,fn) or (pos,[B1,...],fn)."
    );
  }

  const sprite = new THREE.Sprite(
    new THREE.SpriteMaterial({
      map: makeTextTexture(constantText ?? "", fontSize, fontFamily, color),
      transparent: true,
    })
  );
  sprite.visible = !hidden;
  updateSpriteScaleFromMap(sprite);

  scene.add(sprite);

  let currentText = constantText ?? "";

  function getPosVec3() {
    let z = 0;
    let v2;
    if (isMesh(pos)) {
      v2 = new THREE.Vector2(pos.position.x, pos.position.y);
      z = 0;
    } else if (Array.isArray(pos)) {
      v2 = new THREE.Vector2(pos[0] ?? 0, pos[1] ?? 0);
      z = pos[2] ?? 0;
    } else if (pos && typeof pos === "object" && "x" in pos && "y" in pos) {
      v2 = new THREE.Vector2(pos.x ?? 0, pos.y ?? 0);
      z = pos.z ?? 0;
    } else {
      throw new Error("text: unsupported pos type.");
    }
    v2.add(new THREE.Vector2(offset.x ?? 0, offset.y ?? 0));
    return new THREE.Vector3(v2.x, v2.y, z);
  }

  function extractValue(src) {
    if (src && typeof src.getValue === "function") {
      return src.getValue();
    }
    if (src && "value" in src) {
      return src.value;
    }
    if (typeof src === "number" || typeof src === "string") {
      return src;
    }
    if (isMesh(src)) {
      return new THREE.Vector2(src.position.x, src.position.y);
    }
    return src;
  }

  function recompute() {
    const p = getPosVec3();
    sprite.position.copy(p);

    let newText = currentText;

    if (callback) {
      const vals = sources.map(extractValue);
      try {
        const res = callback(...vals);
        newText = String(res);
      } catch (e) {
        console.warn("text callback error:", e);
        return;
      }
    }

    if (newText !== currentText) {
      currentText = newText;
      if (sprite.material.map) sprite.material.map.dispose();
      sprite.material.map = makeTextTexture(
        currentText,
        fontSize,
        fontFamily,
        color
      );
      sprite.material.needsUpdate = true;
      updateSpriteScaleFromMap(sprite);
    }
  }

  recompute();

  if (isMesh(pos)) {
    addDependency(pos, sprite, () => {
      recompute();
    });
  }

  for (const src of sources) {
    if (isMesh(src)) {
      addDependency(src, sprite, () => {
        recompute();
      });
    } else if (src && typeof src.getValue === "function") {
      addDependency(src, sprite, () => {
        recompute();
      });
    } else if (src && "value" in src) {
      addDependency(src, sprite, () => {
        recompute();
      });
    }
  }

  return {
    sprite,
    getText() {
      return currentText;
    },
    setText(t) {
      constantText = String(t);
      callback = null;
      currentText = constantText;
      recompute();
    },
    setColor(c) {
      const col = new THREE.Color(c);
      sprite.material.color = col;
      if (sprite.material.map) sprite.material.map.dispose();
      sprite.material.map = makeTextTexture(
        currentText,
        fontSize,
        fontFamily,
        col
      );
      sprite.material.needsUpdate = true;
      updateSpriteScaleFromMap(sprite);
    },
    setVisible(v) {
      sprite.visible = !!v;
    },
    isText: true,
  };
}

function isPlainObject(o) {
  return !!o && typeof o === "object" && !o.isObject3D && !Array.isArray(o);
}
function isThreeObject(o) {
  return !!(o && o.isObject3D);
}
function isMesh(o) {
  return !!(o && o.isObject3D && o.position && o.position.isVector3);
}

function makeTextTexture(text, fontSize, fontFamily, color) {
  const canvas = document.createElement("canvas");
  const ctx = canvas.getContext("2d");

  const padding = 8;
  ctx.font = `${fontSize}px ${fontFamily}`;
  const metrics = ctx.measureText(text || " ");
  const w = Math.ceil(metrics.width + padding * 2);
  const h = Math.ceil(fontSize + padding * 2);

  canvas.width = w;
  canvas.height = h;

  const ctx2 = canvas.getContext("2d");
  ctx2.font = `${fontSize}px ${fontFamily}`;
  ctx2.textBaseline = "middle";
  ctx2.textAlign = "left";

  ctx2.clearRect(0, 0, w, h);

  const col = new THREE.Color(color);
  const cssColor = `rgb(${Math.round(col.r * 255)},${Math.round(
    col.g * 255
  )},${Math.round(col.b * 255)})`;
  ctx2.fillStyle = cssColor;

  ctx2.fillText(text, padding, h / 2);

  const tex = new THREE.CanvasTexture(canvas);
  tex.minFilter = THREE.LinearFilter;
  tex.magFilter = THREE.LinearFilter;
  tex.needsUpdate = true;
  return tex;
}

function updateSpriteScaleFromMap(sprite) {
  const map = sprite.material.map;
  if (!map || !map.image) return;
  const w = map.image.width || 1;
  const h = map.image.height || 1;

  const scaleFactor = 1 / 20;
  sprite.scale.set(w * scaleFactor, h * scaleFactor, 1);
}
