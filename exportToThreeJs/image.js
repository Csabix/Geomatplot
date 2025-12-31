// image.js
import * as THREE from "three";
import {
  addDependency,
  DependencySystem,
  globalDependencySystem,
} from "./dependency.js";

/**
 * Internal helper:
 * Given a texture + options, create a material.
 *
 * Options:
 *  - shader?: {
 *      vertexShader: string,
 *      fragmentShader: string,
 *      uniforms?: object,
 *      transparent?: boolean,
 *      side?: THREE.Side
 *    }
 *  - materialFactory?: (texture: THREE.Texture) => THREE.Material
 */
function createMaterialForTexture(texture, options = {}) {
  const { shader, materialFactory } = options;

  if (typeof materialFactory === "function") {
    return materialFactory(texture);
  }

  if (shader && shader.vertexShader && shader.fragmentShader) {
    const uniforms = {
      uTexture: { value: texture },
      ...(shader.uniforms || {}),
    };

    return new THREE.ShaderMaterial({
      uniforms,
      vertexShader: shader.vertexShader,
      fragmentShader: shader.fragmentShader,
      transparent: shader.transparent ?? true,
      side: shader.side ?? THREE.DoubleSide,
    });
  }

  // Default: simple textured material
  return new THREE.MeshBasicMaterial({
    map: texture,
    transparent: true,
  });
}

const DEFAULT_IMAGE_VERTEX_SHADER = `
  uniform vec2 uCorner0;
  uniform vec2 uCorner1;
  varying vec2 vUv;
  varying vec2 vWorld;
  void main() {
    vUv = uv;
    vWorld = mix(uCorner0, uCorner1, uv);
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
  }
`;

const DEFAULT_IMAGE_FRAGMENT_SHADER = `
  uniform sampler2D uTexture;
  varying vec2 vUv;
  void main() {
    gl_FragColor = texture2D(uTexture, vUv);
  }
`;

function clamp01(x) {
  return Math.min(1, Math.max(0, x));
}

function toTexDimensions(resolution, aspect) {
  const totalPixels = resolution * resolution;
  const texWidth = Math.max(16, Math.round(Math.sqrt(totalPixels * aspect)));
  const texHeight = Math.max(16, Math.round(texWidth / aspect));
  return { texWidth, texHeight };
}

function normalizeRGB(value) {
  if (!value) return null;
  if (value instanceof THREE.Color) {
    return [value.r, value.g, value.b];
  }
  if (Array.isArray(value)) {
    const [r = 0, g = 0, b = 0] = value;
    const scale = Math.max(Math.abs(r), Math.abs(g), Math.abs(b)) > 1 ? 1 / 255 : 1;
    return [r * scale, g * scale, b * scale];
  }
  if (typeof value === "object" && "x" in value && "y" in value && "z" in value) {
    return [value.x, value.y, value.z];
  }
  return null;
}

function resolveInputValue(input) {
  if (input == null) return input;
  if (typeof input.__depValue !== "undefined") return input.__depValue;
  if (
    typeof input.__depSource === "object" &&
    input.__depSource !== null &&
    typeof input.__depSource.getValue === "function"
  ) {
    return input.__depSource.getValue();
  }
  if (typeof input.getValue === "function") {
    return input.getValue();
  }
  return input;
}

function extractDependencySource(input) {
  if (!input) return null;
  if (typeof input.__depSource === "object" && input.__depSource !== null) {
    return input.__depSource;
  }
  if (
    input.isObject3D ||
    (input.position && input.position.isVector3) ||
    typeof input.getValue === "function" ||
    Object.prototype.hasOwnProperty.call(input, "value")
  ) {
    return input;
  }
  return null;
}

function collectDependencySources(input, out) {
  if (input == null) return;
  const maybeSrc = extractDependencySource(input);
  if (maybeSrc) out.add(maybeSrc);
  if (Array.isArray(input)) {
    for (const item of input) collectDependencySources(item, out);
  }
}

/**
 * addImagePlane
 * -------------
 * Places an IMAGE FILE (texture) as a rectangular plane in the scene.
 */
export function addImagePlane(scene, url, options = {}) {
  if (!scene || !scene.isScene) {
    throw new Error("addImagePlane: first argument must be a THREE.Scene");
  }

  const {
    width = 100,
    height = null, // auto from aspect if null
    position = {},
    hidden = false,
    onLoad,
  } = options;

  const geom = new THREE.PlaneGeometry(width, height || width);
  const placeholderMat = new THREE.MeshBasicMaterial({ color: 0x888888 });
  const mesh = new THREE.Mesh(geom, placeholderMat);
  mesh.position.set(position.x ?? 0, position.y ?? 0, position.z ?? 0);
  mesh.visible = !hidden;
  scene.add(mesh);

  const loader = new THREE.TextureLoader();
  loader.load(
    url,
    (tex) => {
      // three r160+ uses colorSpace; older uses encoding
      if ("colorSpace" in tex) {
        tex.colorSpace = THREE.SRGBColorSpace;
      } else {
        tex.encoding = THREE.sRGBEncoding;
      }

      // If height not specified, adjust to texture aspect
      if (!height && tex.image && tex.image.width && tex.image.height) {
        const aspect = tex.image.height / tex.image.width;
        mesh.geometry.dispose();
        mesh.geometry = new THREE.PlaneGeometry(width, width * aspect);
      }

      const mat = createMaterialForTexture(tex, options);
      mesh.material.dispose();
      mesh.material = mat;

      if (typeof onLoad === "function") {
        onLoad(mesh, tex);
      }
    },
    undefined,
    (err) => {
      console.error("addImagePlane: texture load error:", err);
    }
  );

  return mesh;
}

/* ------------------------------------------------------------------------- */
/*                          FUNCTION-BASED IMAGE (Image)                     */
/* ------------------------------------------------------------------------- */

/**
 * Map scalar value in [vmin, vmax] to a simple "jet-like" RGB color.
 * This is just to get a similar feel to the MATLAB colormap in your screenshot.
 */
function scalarToColorJet(t) {
  // clamp to [0,1]
  t = Math.min(1, Math.max(0, t));

  // simple piecewise: blue -> cyan -> green -> yellow -> red
  let r = 0,
    g = 0,
    b = 0;

  if (t < 0.25) {
    // blue -> cyan
    const u = t / 0.25;
    r = 0;
    g = u;
    b = 1;
  } else if (t < 0.5) {
    // cyan -> green
    const u = (t - 0.25) / 0.25;
    r = 0;
    g = 1;
    b = 1 - u;
  } else if (t < 0.75) {
    // green -> yellow
    const u = (t - 0.5) / 0.25;
    r = u;
    g = 1;
    b = 0;
  } else {
    // yellow -> red
    const u = (t - 0.75) / 0.25;
    r = 1;
    g = 1 - u;
    b = 0;
  }

  return [r, g, b];
}

/**
 * createFunctionImage2D
 * ---------------------
 * JS version of Geomatplot "Image".
 *
 * It evaluates a callback on a rectangular grid or, if a shader is provided,
 * lets the GPU compute colors directly.
 *
 * @param {THREE.Scene} scene
 * @param {object} options
 *   - callback: (x, y, ...inputs) => number | [r,g,b]
 *         * x,y are in canvas coordinates (domain below)
 *         * "inputs" can be whatever you want — typically points, distances etc.
 *   - inputs?: any[]  (will be passed as-is to callback)
 *   - corner0?: [x0,y0]  lower-left corner (default [0,0])
 *   - corner1?: [x1,y1]  upper-right corner (default [1,1])
 *   - resolution?: number  target total pixels ~ resolution^2 (default 512)
 *   - colormap?: 'jet' | 'grayscale'  (only used if callback returns scalar)
 *   - valueRange?: [min,max]  manually set scalar range; if omitted we auto-detect
 *   - z?: number plane z-position (default -0.001 so it sits behind points/curves)
 *   - dependencySystem?: DependencySystem to use (defaults to global)
 *   - previewResolution?: number  resolution used while dependencies are moving
 *   - previewScale?: number factor applied to resolution for preview (default 0.35)
 *   - previewDebounceMs?: number wait before re-rendering full resolution (default 120)
 *   - filtering?: 'linear' | 'bilinear' | 'nearest' texture filtering (CPU texture mode)
 *   - shader?: string | {
 *       vertexShader?,
 *       fragmentShader?,            // if string provided directly, treated as fragmentShader
 *       uniforms?,
 *       transparent?,
 *       side?,
 *       onUpdateUniforms?,          // optional; defaults wire inputs into uniforms
 *       useDataTexture?
 *     }
 *   - shaderInputCapacity?: number  // max uInputs auto-allocated (default 256)
 *   - hidden?: boolean              // if true, mesh is not rendered (default false)
 *
 * @returns {{
 *   mesh: THREE.Mesh,
 *   update: (opts?: { preview?: boolean }) => void,
 *   setResolution: (r: number) => void,
 *   getTexture: () => THREE.Texture | null
 * }}
 *          - mesh: the plane mesh with the texture
 *          - update(): recompute texture (e.g. if your inputs moved)
 */
export function createFunctionImage2D(scene, options = {}) {
  if (!scene || !scene.isScene) {
    throw new Error(
      "createFunctionImage2D: first argument must be a THREE.Scene"
    );
  }

  const {
    callback,
    inputs = [],
    corner0 = [0, 0],
    corner1 = [1, 1],
    resolution = 512,
    colormap = "jet",
    valueRange = null,
    z = -0.001,
    dependencySystem,
    previewResolution,
    previewScale = 0.35,
    previewDebounceMs = 120,
    filtering = "linear",
    shader = null,
    shaderInputCapacity = 256,
    hidden = false,
  } = options || {};

  const shaderObj =
    typeof shader === "string" ? { fragmentShader: shader } : shader || null;
  const hasCallback = typeof callback === "function";
  const hasShader = !!shaderObj;

  if (!hasCallback && !hasShader) {
    throw new Error(
      "createFunctionImage2D: provide a callback or a shader to draw the image."
    );
  }

  const [x0, y0] = corner0;
  const [x1, y1] = corner1;
  const widthWorld = x1 - x0;
  const heightWorld = y1 - y0;

  if (!(widthWorld > 0 && heightWorld > 0)) {
    throw new Error(
      "createFunctionImage2D: corner1 must be above/right of corner0"
    );
  }

  const aspect = widthWorld / heightWorld;
  const depSystem =
    dependencySystem instanceof DependencySystem
      ? dependencySystem
      : globalDependencySystem;
  const baseResolution = Math.max(16, Math.round(resolution));
  let targetResolution = baseResolution;
  const previewScaleClamped = clamp01(previewScale);
  const filterMode = (filtering || "linear").toLowerCase();
  const texFilter =
    filterMode === "nearest"
      ? THREE.NearestFilter
      : THREE.LinearFilter; // treat "linear"/"bilinear"/unknown as linear
  const useDataTexture = hasCallback || (shaderObj && shaderObj.useDataTexture);

  let texWidth = 0;
  let texHeight = 0;
  let data = null;
  let texture = null;
  let settleTimer = null;
  let previewActive = false;

  const geom = new THREE.PlaneGeometry(widthWorld, heightWorld);

  const declaredUniformLen =
    (shaderObj &&
      shaderObj.uniforms &&
      shaderObj.uniforms.uInputs &&
      Array.isArray(shaderObj.uniforms.uInputs.value) &&
      shaderObj.uniforms.uInputs.value.length) ||
    0;
  const maxShaderInputs = Math.max(
    16,
    Math.floor(shaderInputCapacity || 0),
    declaredUniformLen,
    256 // safe minimum to match sample shader defaults
  );
  const initialShaderInputs = maxShaderInputs;

  const shaderUniforms = hasShader
    ? {
        uTexture: { value: null },
        uCorner0: { value: new THREE.Vector2(x0, y0) },
        uCorner1: { value: new THREE.Vector2(x1, y1) },
        uIsPreview: { value: false },
        uPreviewLevel: { value: 1 },
        uResolution: { value: new THREE.Vector2() },
        uInputs: {
          value: Array.from({ length: initialShaderInputs }, () => new THREE.Vector3()),
        },
        uInputCount: { value: 0 },
        ...(shaderObj.uniforms || {}),
      }
    : null;

  const material = hasShader
    ? new THREE.ShaderMaterial({
        uniforms: shaderUniforms,
        vertexShader: shaderObj.vertexShader || DEFAULT_IMAGE_VERTEX_SHADER,
        fragmentShader:
          shaderObj.fragmentShader ||
          (useDataTexture ? DEFAULT_IMAGE_FRAGMENT_SHADER : null),
        transparent: shaderObj.transparent ?? false,
        side: shaderObj.side ?? THREE.DoubleSide,
      })
    : new THREE.MeshBasicMaterial({
        map: null,
        transparent: false,
      });

  if (hasShader && !material.fragmentShader) {
    throw new Error(
      "createFunctionImage2D: shader.fragmentShader is required when no callback is provided."
    );
  }

  const mesh = new THREE.Mesh(geom, material);
  mesh.position.set(x0 + widthWorld / 2, y0 + heightWorld / 2, z);
  mesh.visible = !hidden;
  scene.add(mesh);

  const imageNode = {
    mesh,
    update: (opts) => scheduleUpdate(opts),
    setResolution: (r) => {
      const next = Math.max(16, Math.round(r));
      if (next !== targetResolution) {
        targetResolution = next;
        scheduleUpdate({ preview: false, resolutionOverride: next });
      }
    },
    getTexture: () => texture,
  };

  function ensureTexture(res) {
    if (!useDataTexture) return { texWidth: 0, texHeight: 0 };
    const dims = toTexDimensions(res, aspect);
    const sizeChanged = dims.texWidth !== texWidth || dims.texHeight !== texHeight;

    texWidth = dims.texWidth;
    texHeight = dims.texHeight;

    if (!texture) {
      data = new Uint8Array(texWidth * texHeight * 4);
      texture = new THREE.DataTexture(
        data,
        texWidth,
        texHeight,
        THREE.RGBAFormat,
        THREE.UnsignedByteType
      );
      texture.needsUpdate = true;
      texture.magFilter = texFilter;
      texture.minFilter = texFilter;
      texture.generateMipmaps = false;
      if (!hasShader) {
        material.map = texture;
      }
    } else if (sizeChanged) {
      data = new Uint8Array(texWidth * texHeight * 4);
      texture.image.data = data;
      texture.image.width = texWidth;
      texture.image.height = texHeight;
      texture.needsUpdate = true;
    }

    if (shaderUniforms && shaderUniforms.uTexture) {
      shaderUniforms.uTexture.value = texture;
    }
    if (shaderUniforms && shaderUniforms.uResolution) {
      shaderUniforms.uResolution.value.set(texWidth, texHeight);
    }
    return dims;
  }

  function applyColormap(v, vMin, vMax) {
    if (colormap === "grayscale") {
      const t = clamp01((v - vMin) / (vMax - vMin || 1));
      return [t, t, t];
    }
    const t = clamp01((v - vMin) / (vMax - vMin || 1));
    return scalarToColorJet(t);
  }

  function computeTexture(resolvedInputs, res, isPreview) {
    if (!useDataTexture || !hasCallback) return;
    const { texWidth: w, texHeight: h } = ensureTexture(res);
    if (!w || !h) return;

    let vMin = Number.POSITIVE_INFINITY;
    let vMax = Number.NEGATIVE_INFINITY;
    let hasColor = false;
    const values = new Float32Array(w * h);

    let idx = 0;
    for (let j = 0; j < h; j++) {
      const ty = j / (h - 1 || 1);
      const y = y0 + ty * heightWorld;
      for (let i = 0; i < w; i++) {
        const tx = i / (w - 1 || 1);
        const x = x0 + tx * widthWorld;
        const result = callback(x, y, ...resolvedInputs);
        const rgb = normalizeRGB(result);
        const dataIndex = idx * 4;

        if (rgb) {
          hasColor = true;
          data[dataIndex + 0] = Math.round(clamp01(rgb[0]) * 255);
          data[dataIndex + 1] = Math.round(clamp01(rgb[1]) * 255);
          data[dataIndex + 2] = Math.round(clamp01(rgb[2]) * 255);
          data[dataIndex + 3] = 255;
        } else {
          const v = Number(result);
          values[idx] = v;
          if (!valueRange) {
            if (v < vMin) vMin = v;
            if (v > vMax) vMax = v;
          }
        }
        idx++;
      }
    }

    if (hasColor) {
      texture.needsUpdate = true;
      return;
    }

    if (valueRange) {
      vMin = valueRange[0];
      vMax = valueRange[1];
    } else if (!isFinite(vMin) || !isFinite(vMax) || vMin === vMax) {
      vMin = 0;
      vMax = 1;
    }

    for (let k = 0; k < values.length; k++) {
      const baseIndex = k * 4;
      const [r, g, b] = applyColormap(values[k], vMin, vMax);
      data[baseIndex + 0] = Math.round(clamp01(r) * 255);
      data[baseIndex + 1] = Math.round(clamp01(g) * 255);
      data[baseIndex + 2] = Math.round(clamp01(b) * 255);
      data[baseIndex + 3] = 255;
    }

    texture.needsUpdate = true;
  }

  function runUpdate(res, isPreview) {
    const resolvedInputs = inputs.map(resolveInputValue);
    computeTexture(resolvedInputs, res, isPreview);

    if (shaderUniforms) {
      if (shaderUniforms.uIsPreview) {
        shaderUniforms.uIsPreview.value = !!isPreview;
      }
      if (shaderUniforms.uPreviewLevel) {
        const level = res ? res / targetResolution : 1;
        shaderUniforms.uPreviewLevel.value = level;
      }
      if (shaderUniforms.uInputs && Array.isArray(shaderUniforms.uInputs.value)) {
        const arr = shaderUniforms.uInputs.value;
        // Guarantee length >= maxShaderInputs and every slot is a Vector3
        while (arr.length < maxShaderInputs) arr.push(new THREE.Vector3());
        for (let i = 0; i < arr.length; i++) {
          if (!arr[i] || !arr[i].isVector3) {
            arr[i] = new THREE.Vector3();
          }
        }
        let writeIndex = 0;

        const writeVec = (vec, v) => {
          if (v && v.isVector3) {
            vec.copy(v);
          } else if (v && v.isVector2) {
            vec.set(v.x, v.y, 0);
          } else if (v && v.position && v.position.isVector3) {
            vec.copy(v.position);
          } else if (Array.isArray(v)) {
            vec.set(v[0] ?? 0, v[1] ?? 0, v[2] ?? 0);
          } else if (typeof v === "number") {
            vec.set(v, 0, 0);
          } else if (v && typeof v === "object" && "x" in v && "y" in v) {
            vec.set(v.x ?? 0, v.y ?? 0, v.z ?? 0);
          } else {
            vec.set(0, 0, 0);
          }
        };

        // Ensure array is large enough for all flattened inputs
        const ensureSize = (needed) => {
          const capped = Math.min(needed, maxShaderInputs);
          while (arr.length < capped) arr.push(new THREE.Vector3());
        };

        for (const v of resolvedInputs) {
          if (
            Array.isArray(v) &&
            v.length &&
            (Array.isArray(v[0]) ||
              (v[0] && (v[0].isVector2 || v[0].isVector3)))
          ) {
            ensureSize(writeIndex + v.length);
            for (let j = 0; j < v.length && writeIndex < maxShaderInputs; j++) {
              writeVec(arr[writeIndex], v[j]);
              writeIndex++;
            }
          } else {
            ensureSize(writeIndex + 1);
            writeVec(arr[writeIndex], v);
            writeIndex++;
          }
        }

        // Zero-fill the rest
        for (let k = writeIndex; k < arr.length; k++) {
          arr[k].set(0, 0, 0);
        }

        if (shaderUniforms.uInputCount) {
          shaderUniforms.uInputCount.value = Math.min(writeIndex, maxShaderInputs);
        }
      }
    }

    if (!hasShader && material.map) {
      material.map.needsUpdate = true;
    }

    if (!isPreview) {
      previewActive = false;
    }

    depSystem.updateDependencies(imageNode);
  }

  function scheduleUpdate(opts = {}) {
    const interactive = !!opts.preview;
    const resolutionOverride =
      opts.resolutionOverride && Number.isFinite(opts.resolutionOverride)
        ? Math.max(16, Math.round(opts.resolutionOverride))
        : null;
    const targetRes = resolutionOverride || targetResolution;
    const previewResValue = Math.max(
      16,
      Math.round(
        previewResolution && Number.isFinite(previewResolution)
          ? previewResolution
          : targetRes * previewScaleClamped
      )
    );
    const shouldPreview = interactive && previewResValue < targetRes;

    clearTimeout(settleTimer);

    if (shouldPreview) {
      previewActive = true;
      runUpdate(previewResValue, true);
      settleTimer = setTimeout(() => {
        previewActive = false;
        runUpdate(targetRes, false);
      }, previewDebounceMs);
    } else {
      previewActive = false;
      runUpdate(targetRes, false);
    }
  }

  const depSources = new Set();
  inputs.forEach((inp) => collectDependencySources(inp, depSources));
  const attachDependency =
    typeof depSystem.addDependency === "function"
      ? depSystem.addDependency.bind(depSystem)
      : addDependency;
  depSources.forEach((src) => {
    attachDependency(src, imageNode, () => scheduleUpdate({ preview: true }));
  });

  scheduleUpdate();

  return imageNode;
}
