// image.js
import * as THREE from "three";

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
    onLoad,
  } = options;

  const geom = new THREE.PlaneGeometry(width, height || width);
  const placeholderMat = new THREE.MeshBasicMaterial({ color: 0x888888 });
  const mesh = new THREE.Mesh(geom, placeholderMat);
  mesh.position.set(position.x ?? 0, position.y ?? 0, position.z ?? 0);
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
 * JS version of Geomatplot "Image" (simplified, CPU-only).
 *
 * It evaluates a callback on a rectangular grid and draws a heatmap.
 *
 * @param {THREE.Scene} scene
 * @param {object} options
 *   - callback: (x, y, ...inputs) => number | [r,g,b]
 *         * x,y are in canvas coordinates (domain below)
 *         * "inputs" can be whatever you want – typically points, distances etc.
 *   - inputs?: any[]  (will be passed as-is to callback)
 *   - corner0?: [x0,y0]  lower-left corner (default [0,0])
 *   - corner1?: [x1,y1]  upper-right corner (default [1,1])
 *   - resolution?: number  target total pixels ~ resolution^2 (default 512)
 *   - colormap?: 'jet' | 'grayscale'  (only used if callback returns scalar)
 *   - valueRange?: [min,max]  manually set scalar range; if omitted we auto-detect
 *   - z?: number plane z-position (default -0.001 so it’s behind points/curves)
 *
 * @returns {{ mesh: THREE.Mesh, update: () => void }}
 *          - mesh: the plane mesh with the DataTexture
 *          - update(): recompute texture (e.g. if your inputs moved)
 */
export function createFunctionImage2D(scene, options) {
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
  } = options || {};

  if (typeof callback !== "function") {
    throw new Error(
      "createFunctionImage2D: options.callback must be a function"
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

  // Decide pixel width/height so that total pixels ~ resolution^2 and aspect matches domain.
  const aspect = widthWorld / heightWorld;
  const totalPixels = resolution * resolution;
  const texWidth = Math.max(16, Math.round(Math.sqrt(totalPixels * aspect)));
  const texHeight = Math.max(16, Math.round(texWidth / aspect));

  // Typed array RGBA
  const data = new Uint8Array(texWidth * texHeight * 4);
  const texture = new THREE.DataTexture(
    data,
    texWidth,
    texHeight,
    THREE.RGBAFormat,
    THREE.UnsignedByteType
  );
  texture.needsUpdate = true;

  const material = new THREE.MeshBasicMaterial({
    map: texture,
    transparent: false,
  });

  const geom = new THREE.PlaneGeometry(widthWorld, heightWorld);
  const mesh = new THREE.Mesh(geom, material);
  // Place plane so its lower-left corner is corner0
  mesh.position.set(x0 + widthWorld / 2, y0 + heightWorld / 2, z);
  scene.add(mesh);

  /**
   * Recompute the texture by evaluating callback over the grid.
   */
  function update() {
    let vMin = Number.POSITIVE_INFINITY;
    let vMax = Number.NEGATIVE_INFINITY;

    // First pass: compute raw values, maybe track min/max
    const values = new Float32Array(texWidth * texHeight);
    let idx = 0;
    for (let j = 0; j < texHeight; j++) {
      const ty = j / (texHeight - 1);
      const y = y0 + ty * heightWorld;
      for (let i = 0; i < texWidth; i++) {
        const tx = i / (texWidth - 1);
        const x = x0 + tx * widthWorld;

        const result = callback(x, y, ...inputs);

        if (Array.isArray(result)) {
          // Already RGB [0..1] or [0..255]; store dummy scalar
          values[idx] = 0;
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

    if (valueRange) {
      vMin = valueRange[0];
      vMax = valueRange[1];
    } else {
      if (!isFinite(vMin) || !isFinite(vMax) || vMin === vMax) {
        vMin = 0;
        vMax = 1;
      }
    }

    // Second pass: fill RGBA with either palette or raw RGB
    idx = 0;
    for (let j = 0; j < texHeight; j++) {
      for (let i = 0; i < texWidth; i++) {
        const dataIndex = (j * texWidth + i) * 4;
        const v = values[idx];

        let r, g, b;

        if (Array.isArray(callback(x0, y0, ...inputs))) {
          // If callback returns RGB arrays we would need to store them separately.
          // For this simplified version, we assume scalar output for heatmaps.
          r = g = b = 0;
        } else if (colormap === "grayscale") {
          const t = (v - vMin) / (vMax - vMin);
          const gVal = Math.min(1, Math.max(0, t));
          r = gVal;
          g = gVal;
          b = gVal;
        } else {
          // 'jet' palette
          const t = (v - vMin) / (vMax - vMin);
          [r, g, b] = scalarToColorJet(t);
        }

        data[dataIndex + 0] = Math.round(r * 255);
        data[dataIndex + 1] = Math.round(g * 255);
        data[dataIndex + 2] = Math.round(b * 255);
        data[dataIndex + 3] = 255; // opaque
        idx++;
      }
    }

    texture.needsUpdate = true;
  }

  // Initial computation
  update();

  return { mesh, update };
}
