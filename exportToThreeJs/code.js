import * as THREE from "three";
import { point, dPoint } from "./point.js";
import {
  createUniformCurve,
  createCentripetalCurve,
  createChordalCurve,
  createCustomCurve,
} from "./curve.js";
import { circle } from "./circle.js";
import { distance } from "./distance.js";
import { segment } from "./segment.js";
import { pointSequence } from "./pointSequence.js";
import { polygon } from "./polygon.js";
import { text } from "./text.js";
import { createDependencySystem } from "./dependency.js";
import { addImagePlane, createFunctionImage2D } from "./image.js";
import { customValue } from "./customValue.js";

export function draw(scene) {
  /* ----- LOCAL DEPENDENCY ------ */

  const localDeps = createDependencySystem();
  const localDeps2 = createDependencySystem();

  /* ----- POINT ----- */

  const point_1 = point(scene, 50, 50);
  const point_2 = point(scene, 20, 160);
  const point_3 = point(scene, -20, 50);
  const point_4 = point(scene, -50, -100, { hidden: true });
  const point_5 = point(scene, 150, 50, { hidden: true });
  const point_6 = point(scene, -200, -100, { hidden: true });

  /* ----- CURVE ----- */

  createUniformCurve(scene, [point_1, point_2, [10, 10], point_4], {
    hidden: true,
    color: "green",
  });

  const curve = createCustomCurve(
    scene,
    (t) => {
      const x = t * 400 - 200;
      const y = Math.sin(t * Math.PI * 4) * 50;
      return [x, y];
    },
    { color: 0x3366ff, segments: 400, hidden: true }
  );

  createCustomCurve(
    scene,
    point_1,
    [10, 10],
    (t, aPos, bPos) => {
      const x = THREE.MathUtils.lerp(aPos.x, bPos.x, t);
      const y =
        THREE.MathUtils.lerp(aPos.y, bPos.y, t) +
        Math.sin(t * Math.PI * 3) * 40;
      return new THREE.Vector3(x, y, 0);
    },
    { color: 0xdd5522, segments: 300, hidden: true }
  );

  /* ----- DEPENDENT POINT ----- */

  dPoint(
    scene,
    [10, 10],
    point_6,
    point_4,
    (a, b) => a.clone().add(b).multiplyScalar(0.5),
    { size: 10, color: "green", hidden: true }
  );

  dPoint(
    scene,
    point_1,
    point_4,
    ([px, py], [dx, dy]) => {
      return [px + dx, py + dy];
    },
    { hidden: true }
  );

  /* ----- CIRCLE ----- */

  circle(scene, point_1, point_2, point_3, {
    color: 0x0066ff,
    hidden: true,
  });

  const circ2 = circle(scene, point_1, point_2, {
    color: 0x22aa22,
    hidden: true,
  });

  const circ3 = circle(scene, [300, -150], 120, {
    color: 0xaa2222,
    hidden: true,
  });

  /* ----- DISTANCE ----- */

  const dAB = distance(point_2, [10, 10], (d, aPos, bPos) => {
    return d - aPos.distanceTo(bPos) + 20;
  });
  dAB.onChange((v) => console.log("|AB| =", v));

  const circ1 = circle(scene, point_1, dAB.getValue(), {
    color: 0x0066ff,
    hidden: true,
  });

  const dA_to_many = distance(point_1, [point_4, point_5, [200, 10]]);
  dA_to_many.onChange((v) => console.log("min dist(A, seq) =", v));

  const dA_to_circ = distance(point_1, circ1);
  // dA_to_circ.onChange((v) => console.log("gap(A, circle) =", v));

  const poly = createUniformCurve(scene, [point_1, point_2, point_3], {
    hidden: true,
  });
  const dA_to_poly = distance(point_1, poly);
  // dA_to_poly.onChange((v) => console.log("min dist(A, polyline) =", v));

  /* ----- SEGMENT ----- */

  const s1 = segment(scene, point_1, point_2, {
    color: 0x333333,
    linewidth: 2,
    hidden: true,
  });

  const s2 = segment(scene, point_1, point_2, point_3, point_4, {
    color: 0x555555,
    linewidth: 1.5,
    hidden: true,
  });

  const s3 = segment(scene, point_1, [80, -40], { dashed: true, hidden: true });

  /* ----- POLYGON ----- */

  const poly1 = polygon(scene, [point_1, [0, 0], point_4, [30, 10]], {
    color: 0x0088ff,
    faceAlpha: 0.2,
    hidden: true,
  });

  const poly2 = polygon(scene, point_1, point_2, point_3, {
    color: 0xdd5522,
    faceAlpha: 0.15,
    hidden: true,
  });

  const seq_points = pointSequence(scene, point_1, point_2, point_3, {
    hidden: true,
  });
  const seq_poly = pointSequence(scene, [point_1, point_2, point_3], poly, {
    color: 0x22aa22,
    markerSize: 1.5,
    hidden: true,
  });

  const poly3 = polygon(scene, seq_poly, curve, {
    color: 0x22aa22,
    faceAlpha: 0.1,
    hidden: true,
  });

  /* ----- POINT SEQUENCE ----- */

  const seq1 = pointSequence(
    scene,
    point_1,
    point_2,
    [
      [0, 0],
      [100, 100],
    ],
    { color: 0x3366ff, markerSize: 2, hidden: true }
  );

  const seq2 = pointSequence(
    scene,
    point_1,
    point_2,
    point_3,
    (a, b, c) => {
      return [a, b, c].map(([x, y]) => [x, -y]);
    },
    { color: 0xdd5522, hidden: true }
  );

  const seq3 = pointSequence(scene, seq1, poly, {
    color: 0x22aa22,
    markerSize: 1.5,
    hidden: true,
  });

  /* ----- TEXT ------ */

  const labelPoint1 = text(scene, point_1, "point_1", {
    color: 0x0000ff,
    fontSize: 200,
    offset: { x: 10, y: 10 },
    hidden: true,
  });

  const dLabel = text(scene, point_1, [dAB], (B) => B.toFixed(2), {
    color: 0x008800,
    fontSize: 200,
    offset: { x: 10, y: -10 },
    hidden: true,
  });

  const dAC = distance(point_1, point_3);
  const dLabel2 = text(scene, point_3, dAC, (B) => B.toFixed(1), {
    color: 0xaa0000,
    fontSize: 200,
    offset: { x: 10, y: 10 },
    hidden: true,
  });

  /* ----- IMAGE ----- */

  // const vertexShader = `
  //   varying vec2 vUv;
  //   void main() {
  //     vUv = uv;
  //     gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
  //   }
  // `;

  // const fragmentShader = `
  //   uniform sampler2D uTexture;
  //   varying vec2 vUv;
  //   void main() {
  //     vec4 color = texture2D(uTexture, vUv);
  //     float g = dot(color.rgb, vec3(0.299, 0.587, 0.114));
  //     gl_FragColor = vec4(vec3(g), color.a);
  //   }
  // `;

  // createFunctionImage2D(scene, {
  //   callback: (x, y) => {
  //     let minD = Infinity;
  //     for (const p of [point_1, point_2, point_3]) {
  //       const px = p.position.x;
  //       const py = p.position.y;
  //       const dx = x - px;
  //       const dy = y - py;
  //       const d = Math.sqrt(dx * dx + dy * dy);
  //       if (d < minD) minD = d;
  //     }
  //     return minD;
  //   },
  //   corner0: [-150, -50], // lower-left of domain
  //   corner1: [200, 250], // upper-right of domain
  //   resolution: 512,
  //   colormap: "grayscale",
  //   z: -0.01,
  // });

  // const poly = createUniformCurve(scene, [point_1, point_2, point_3]);
  // const seq = pointSequence(scene, [point_1, point_2, point_3], poly, {
  //   color: 0x22aa22,
  //   markerSize: 1.5,
  //   visible: false,
  // });

  // createFunctionImage2D(scene, {
  //   callback: (x, y) => {
  //     let minD2 = Infinity;

  //     for (const [sx, sy] of seq.getArray()) {
  //       const dx = x - sx;
  //       const dy = y - sy;
  //       const d2 = dx * dx + dy * dy;
  //       if (d2 < minD2) minD2 = d2;
  //     }

  //     return Math.sqrt(minD2);
  //   },

  //   corner0: [-150, -50], // lower-left of domain
  //   corner1: [200, 250], // upper-right of domain
  //   resolution: 512,
  //   colormap: "jet",
  //   z: -1,
  // });

  // addImagePlane(scene, "../examples/bez.png", {
  //   width: 200,
  //   position: { x: 100, y: 50, z: 0 },
  // });

  // addImagePlane(scene, "../examples/triangle.png", {
  //   position: { x: -100, y: -250, z: 0 },
  //   shader: {
  //     vertexShader,
  //     fragmentShader,
  //   },
  // });

  /* ----- CUSTOM VALUE ----- */

  const customVal = customValue([dAB], (d) => {
    return d / 2;
  });

  /* ----- TODOs ----- */

  //   ✅- Image: Frissülnie kell a képnek, kell bele a dependency rendszer
  //     (trükk: Amíg mozgatunk valamit, addig a felbontás kisebb legyen)
  //     - CPU-n számítás költséges, kell a GPU-s shader alapú megoldás is (WebGL shader) ->
  //         A shader-nek kell számolnia a heatmap-et (a színt számolja a shader)
  //           - Akár csak string-esen megadni és elődefiniált funkciókat használni
  //     - Legyen resolution paraméter
  //     - Beállítási lehetőség, bilinear/nearest neighbour mintavételezés (filtering), threeJs-ben benne lehet, csak cpu-nál számít

  const gpuFragmentShader = `
    uniform vec3 uInputs[256];
    uniform int uInputCount;
    uniform bool uIsPreview;
    varying vec2 vWorld;

    vec3 jet(float t) {
      t = clamp(t, 0.0, 1.0);
      float r = 0.0, g = 0.0, b = 0.0;
      if (t < 0.25) {
        float u = t / 0.25;
        r = 0.0; g = u; b = 1.0;
      } else if (t < 0.5) {
        float u = (t - 0.25) / 0.25;
        r = 0.0; g = 1.0; b = 1.0 - u;
      } else if (t < 0.75) {
        float u = (t - 0.5) / 0.25;
        r = u; g = 1.0; b = 0.0;
      } else {
        float u = (t - 0.75) / 0.25;
        r = 1.0; g = 1.0 - u; b = 0.0;
      }
      return vec3(r, g, b);
    }

    void main() {
      float minD = 1e9;
      for (int i = 0; i < uInputCount; i++) {
        vec2 p = uInputs[i].xy;
        float d = distance(vWorld, p);
        if (d < minD) minD = d;
      }

      float t = clamp(minD / 200.0, 0.0, 1.0);      
      vec3 color = jet(t);
      gl_FragColor = vec4(color, 0.9);
    }
  `;

  createFunctionImage2D(scene, {
    inputs: [point_1, [10, 10], point_3],
    corner0: [-150, -50],
    corner1: [200, 250],
    resolution: 512,
    previewScale: 0.3,
    filtering: "bilinear",
    z: -0.1,
    shader: gpuFragmentShader,
  });

  // GPU-rendered image: min distance to sequence (uInputs auto-filled from inputs)
  const seqDistanceFragmentShader = `
    uniform vec3 uInputs[256];
    uniform int uInputCount;
    uniform bool uIsPreview;
    varying vec2 vWorld;

    vec3 jet(float t) {
      t = clamp(t, 0.0, 1.0);
      float r = 0.0, g = 0.0, b = 0.0;
      if (t < 0.25) {
        float u = t / 0.25;
        r = 0.0; g = u; b = 1.0;
      } else if (t < 0.5) {
        float u = (t - 0.25) / 0.25;
        r = 0.0; g = 1.0; b = 1.0 - u;
      } else if (t < 0.75) {
        float u = (t - 0.5) / 0.25;
        r = u; g = 1.0; b = 0.0;
      } else {
        float u = (t - 0.75) / 0.25;
        r = 1.0; g = 1.0 - u; b = 0.0;
      }
      return vec3(r, g, b);
    }

    void main() {
      float minD = 1e9;
      for (int i = 0; i < uInputCount; i++) {
        vec2 p = uInputs[i].xy;
        float d = distance(vWorld, p);
        if (d < minD) minD = d;
      }

      float t = clamp(minD / 200.0, 0.0, 1.0);
      if (uIsPreview) {
        t = mix(t, 0.0, 0.15); // slight darkening while previewing
      }
      vec3 color = jet(t);
      gl_FragColor = vec4(color, 0.9);
    }
  `;

  const seqInput = {
    getValue: () =>
      seq_poly.getArray().map(([x, y]) => new THREE.Vector3(x, y, 0)),
    __depSource: seq_poly.group,
  };
  // 🆕 Utána nézni, hogy miért Vector3-nál mardtunk végül Vector2 helyett
  // 🆕 Inputokat tömb ként átadni, és akkor lenne nekik neve pl.: {elso_pont: point_1} így lehetne rá hivatkozni a shader-ben

  // createFunctionImage2D(scene, {
  //   inputs: [seqInput],
  //   corner0: [-150, -50],
  //   corner1: [200, 250],
  //   filtering: "bilinear",

  //   z: -1,
  //   shader: seqDistanceFragmentShader,
  // });

  // ✅ Opcionális argument-eknél legyen mindenhol egy hidden boolean, ami ha == true, akkor elrejti az objektumot
  // ✅ Bekerülni az utolsó arhument-be, mint opcionális paraméterek (átnézni mindet)
  // ✅ Automatikusan detektálni, hogy milyen fajta, ne kelljen a componentParams
  // 🆕 El kell fogadnia másféle paramétert is, pl. curve vagy circle. Ilyen esetekben a curve-nek a pont halmazát adja vissza, azzal tudunk számolni a paraméterben.

  dPoint(
    scene,
    point_1,
    point_2,
    (a, { x, y }) =>
      a.clone().add(new THREE.Vector3(x, y, 0)).multiplyScalar(0.5),
    { size: 8, color: "magenta" }
  );

  // 🆕 Component params is still in use

  // dPoint(
  //   scene,
  //   point_1,
  //   [10, 10],
  //   ([x, y], [xx, yy]) => [(x + xx) / 2, (y + yy) / 2],
  //   { size: 8, color: "magenta" }
  // );

  dPoint(
    scene,
    point_1,
    point_2,
    ([xx, yy], /* { x, y } */ b) => [(x + xx) / 2, (y + yy) / 2],
    { size: 8, color: "magenta" }
  );

  // 🆕 Ha point_2 és point_1 az input, callback oldalon kéne érzékelni, hogy mi történik
  //     A dPoint-ban ahogy írva van, ha [x,y] akkor csak a koordináta, de ha csak "b" akkor meg a pont legyen betéve
  //     Alternatíva a tömbbe megani, hogy mi az amiket unpack-elni kéne
  //     Minden paraméterre külön külön kell detektálni
  // 🆕 Valami verbose hiba jelentés, ha valamit rosszul ad meg a user és mondjuk nem renderelhető vagy nem ismert

  // 🆕 Distance és dScalar külön vétele, dScalar-nak kell a callback, nem a distance-nak
  // 🆕 dPoint, dScalar-nál is működjön a callback mint itt: --> Distance-ra még meg kell csinálni
  // createCustomCurve(
  //   scene,
  //   point_1,
  //   point_2,
  //   customVal,
  //   (t, aPos, bPos, cval) => {
  //     const mid = aPos.clone().add(bPos).multiplyScalar(0.5);
  //     const dir = bPos.clone().sub(aPos);
  //     const x = THREE.MathUtils.lerp(aPos.x, bPos.x, t);
  //     const y =
  //       THREE.MathUtils.lerp(aPos.y, bPos.y, t) +
  //       Math.sin(t * Math.PI) * dir.length() * 0.25;
  //     return new THREE.Vector3(x + cval, y, 0);
  //   },
  //   { color: 0xdd5522 }
  // );

  // 🆕 depValue-t ki kell csomagolni alapból, így akkor a dependency system-et is át kell nézni
  // const customVal2 = customValue([dAB], (d) => {
  //   // return d / 2;
  //   return [10, 10];
  // });
  // createCustomCurve(
  //   scene,
  //   point_1,
  //   point_2,
  //   customVal2,
  //   (t, aPos, bPos, cusVal) => {
  //     console.log(cusVal["__depValue"]); --> !!!!!!!!!!!!
  //     const x = THREE.MathUtils.lerp(aPos.x, bPos.x, t);
  //     const y =
  //       THREE.MathUtils.lerp(aPos.y, bPos.y, t) +
  //       Math.sin(t * Math.PI * 3) * 40;
  //     return new THREE.Vector3(x, y, 0);
  //   },
  //   { color: 0xdd5522, segments: 300 }
  // );

  // 🆕 Elkülöníteni a ThreeJS dependenciákat. Ne legyenek össze vissza a dependenciák, hogy később akár
  //    le lehessen cserélni valami más technológiára
  // 🆕 Legyen egy doksi arról (README), hogy hogyan kell lokálisan fejleszteni a projektet
}
