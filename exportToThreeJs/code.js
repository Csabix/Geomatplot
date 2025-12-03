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

  const point_1 = point(scene, 50, 50, 10, "blue");
  const point_2 = point(scene, 20, 160, 10, "green");
  const point_3 = point(scene, -20, 50);
  const point_4 = point(scene, -50, -100);
  const point_5 = point(scene, 150, 50);
  const point_6 = point(scene, -200, -100);

  /* ----- CURVE ----- */

  // createUniformCurve(scene, [point_1, point_2, point_3, point_4]);
  // createUniformCurve(scene, point_5, point_6, 0.5, "green");
  // const curve = createCustomCurve(
  //   scene,
  //   (t) => {
  //     const x = t * 400 - 200;
  //     const y = Math.sin(t * Math.PI * 4) * 50;
  //     return [x, y];
  //   },
  //   { color: 0x3366ff, segments: 400 }
  // );
  // createCustomCurve(
  //   scene,
  //   point_1,
  //   point_2,
  //   (t, aPos, bPos) => {
  //     const x = THREE.MathUtils.lerp(aPos.x, bPos.x, t);
  //     const y =
  //       THREE.MathUtils.lerp(aPos.y, bPos.y, t) +
  //       Math.sin(t * Math.PI * 3) * 40;
  //     return new THREE.Vector3(x, y, 0);
  //   },
  //   { color: 0xdd5522, segments: 300 }
  // );

  /* ----- DEPENDENT POINT ----- */

  // dPoint(
  //   scene,
  //   point_1,
  //   point_6,
  //   point_4,
  //   (a, b, c) => a.clone().add(b).add(c).multiplyScalar(0.8),
  //   10,
  //   "green"
  // );

  // dPoint(
  //   scene,
  //   point_1,
  //   point_6,
  //   (a, b) => a.clone().add(b).multiplyScalar(0.5),
  //   10,
  //   "green",
  //   { dependencySystem: localDeps }
  // );

  /* ----- CIRCLE ----- */

  // const circ1 = circle(scene, point_1, point_2, point_3, {
  //   color: 0x0066ff,
  // });
  // const circ2 = circle(scene, point_1, point_2, { color: 0x22aa22 });
  // const circ3 = circle(scene, [300, -150], 120, { color: 0xaa2222 });

  /* ----- DISTANCE ----- */

  // const dAB = distance(point_2, point_5);
  // dAB.onChange((v) => console.log("|AB| =", v));

  // @TODO Lehessen callback-et megadni, hogy hoygan száámolódjon a távolság (ez is lehet paraméter) !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

  // const dA_to_many = distance(point_1, [point_4, point_5, [200, 10]]);
  // dA_to_many.onChange((v) => console.log("min dist(A, seq) =", v));

  // const circ = circle(scene, point_2, point_4, point_5, { color: 0x3366ff });
  // const dA_to_circ = distance(point_1, circ);
  // dA_to_circ.onChange((v) => console.log("gap(A, circle) =", v));

  // const poly = createUniformCurve(scene, [point_1, point_2, point_3]);
  // const dA_to_poly = distance(point_1, poly);
  // dA_to_poly.onChange((v) => console.log("min dist(A, polyline) =", v));

  /* ----- SEGMENT ----- */

  // const s1 = segment(scene, point_1, point_2, {
  //   color: 0x333333,
  //   linewidth: 2,
  // });

  // const s2 = segment(scene, point_1, point_2, point_3, point_4, {
  //   color: 0x555555,
  //   linewidth: 1.5,
  // });

  // const s3 = segment(scene, point_1, [80, -40], { dashed: true });

  /* ----- POLYGON ----- */

  // const poly1 = polygon(scene, [point_1, [0, 0], point_4, [30, 10]], {
  //   color: 0x0088ff,
  //   faceAlpha: 0.2,
  // });

  // const poly2 = polygon(scene, point_1, point_2, point_3, {
  //   color: 0xdd5522,
  //   faceAlpha: 0.15,
  // });

  // const seq = pointSequence(scene, point_1, point_2, point_3);
  // const curve = createUniformCurve(scene, [point_1, point_2, point_3]);
  // const poly3 = polygon(scene, seq, curve, { color: 0x22aa22, faceAlpha: 0.1 });

  /* ----- POINT SEQUENCE ----- */

  // const seq1 = pointSequence(
  //   scene,
  //   point_1,
  //   point_2,
  //   [
  //     [0, 0],
  //     [100, 100],
  //   ],
  //   { color: 0x3366ff, markerSize: 2 }
  // );

  // const seq2 = pointSequence(
  //   scene,
  //   point_1,
  //   point_2,
  //   point_3,
  //   (a, b, c) => {
  //     return [a, b, c].map(([x, y]) => [x, -y]);
  //   },
  //   { color: 0xdd5522 }
  // );

  // const poly = createUniformCurve(scene, [point_1, point_2, point_3]);
  // const seq3 = pointSequence(scene, seq1, poly, {
  //   color: 0x22aa22,
  //   markerSize: 1.5,
  // });

  /* ----- TEXT ------ */

  // const labelPoint1 = text(scene, point_1, "point_1", {
  //   color: 0x0000ff,
  //   fontSize: 200,
  //   offset: { x: 10, y: 10 },
  // });

  // const dAB = distance(point_1, point_2);
  // const dLabel = text(scene, point_1, [dAB], (B) => B.toFixed(2), {
  //   color: 0x008800,
  //   fontSize: 200,
  //   offset: { x: 10, y: -10 },
  // });

  // const dAC = distance(point_1, point_3);
  // const dLabel2 = text(scene, point_3, dAC, (B) => B.toFixed(1), {
  //   color: 0xaa0000,
  //   fontSize: 200,
  //   offset: { x: 10, y: 10 },
  // });

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

  const dAB = distance(point_1, point_2);
  const customVal = customValue([dAB], (d) => {
    return { a: d / 2 };
  });

  createCustomCurve(
    scene,
    point_1,
    point_2,
    customVal,
    (t, aPos, bPos, cval) => {
      const mid = aPos.clone().add(bPos).multiplyScalar(0.5);
      const dir = bPos.clone().sub(aPos);
      const x = THREE.MathUtils.lerp(aPos.x, bPos.x, t);
      const y =
        THREE.MathUtils.lerp(aPos.y, bPos.y, t) +
        Math.sin(t * Math.PI) * dir.length() * 0.25;
      return new THREE.Vector3(x + cval.a, y, 0);
    },
    { color: 0xdd5522 }
  );

  // cur(scene, customVal, (a) => [0, a.getValue()], 10, "yellow");

  // circle(scene, point_1, customVal.getValue(), { color: 0xaa2222 }); // TODO:

  /*
    @TODO
    - Átnézni a kódbázist, hogy hol van még esetleg todo ami elmaradt
    - Mindenre implementálni, hogy lehessen akár objektumot, akár tömböt (mint  koordináta) megadni
    - Callback-et megnézni a dPoiint-ra, mert weird a működése
    - Megnézni, miért nem frissül a customValue után a circle mérete -> A circle-t nem callback-ből akarjuk létrehozni,
      Azonban a dependent objektumokat tetszőleges típusból akarjuk létrehozni
    - dPoint, dScalar-nál is működjön a callback mint itt:
      createCustomCurve(
        scene,
        point_1,
        point_2,
        customVal,
        (t, aPos, bPos, cval) => {
          const mid = aPos.clone().add(bPos).multiplyScalar(0.5);
          const dir = bPos.clone().sub(aPos);
          const x = THREE.MathUtils.lerp(aPos.x, bPos.x, t);
          const y =
            THREE.MathUtils.lerp(aPos.y, bPos.y, t) +
            Math.sin(t * Math.PI) * dir.length() * 0.25;
          return new THREE.Vector3(x + cval, y, 0);
        },
        { color: 0xdd5522 }
      );    

      - Image: Frissülnie kell a képnek, kell bele a dependency rendszer 
        (trükk: Amíg mozgatunk valamit, addig a felbontás kisebb legyen)
        - CPU-n számítás költséges, kell a GPU-s shader alapú megoldás is (WebGL shader) -> 
            A shader-nek kell számolnia a heatmap-et (a színt számolja a shader)
              - Akár csak string-esen megadni és elődefiniált funkciókat használni
        - Legyen resolution paraméter
  */
}
