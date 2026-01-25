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
import { dScalar } from "./dScalar.js";
import { segment } from "./segment.js";
import { pointSequence } from "./pointSequence.js";
import { polygon } from "./polygon.js";
import { text } from "./text.js";
import { createDependencySystem } from "./dependency.js";
import { addImagePlane, createFunctionImage2D } from "./image.js";
import { customValue } from "./customValue.js";

export function draw(scene) {
  const point_1 = point(scene, 50, 50);
  const point_2 = point(scene, 150, 80);

  dPoint(
    scene,
    point_1,
    [10, 10],
    ([px, py], [dx, dy]) => {
      return [px + dx, py + dy];
    },
    { hidden: false, color: "green" },
  );

  const curve = createCustomCurve(
    scene,
    point_1,
    [10, 10], // Menjen inkább a pont egy és pont 2  között
    (t, aPos, bPos) => {
      const x = THREE.MathUtils.lerp(aPos.x, bPos.x, t);
      const y =
        THREE.MathUtils.lerp(aPos.y, bPos.y, t) +
        Math.sin(t * Math.PI * 3) * 40;
      return new THREE.Vector2(x, y);
    },
    { color: 0xdd5522, segments: 300, hidden: false },
  );

  const d_ab = dScalar(point_2, [10, 10], (a, b) => {
    return a.x + b[0];
  });

  const d_a_b = distance(point_1, point_2);
  d_a_b.onChange(() => {
    console.log(d_a_b.getValue());
  });

  const circ1 = circle(scene, point_1, d_ab, {
    color: 0x0066ff,
    hidden: false,
  });

  const s1 = segment(scene, point_1, point_2, {
    color: 0x333333,
    linewidth: 2,
    hidden: false,
  });

  const poly_1 = polygon(scene, [point_1, [0, 0], point_2, [30, 10]], {
    color: 0x0088ff,
    faceAlpha: 0.5,
    hidden: false,
  });

  const seq_1 = pointSequence(scene, point_1, point_2, {
    color: 0x3366ff,
    markerSize: 2,
    hidden: true,
  });

  const curve_seq = pointSequence(scene, curve, {
    color: 0x22aa22,
    markerSize: 1.5,
    hidden: false,
  });

  const label_1 = text(scene, point_1, "point_1", {
    color: 0x0000ff,
    fontSize: 200,
    offset: { x: 10, y: 10 },
    hidden: false,
  });

  const shader = `
  varying vec2 vWorld;
  void main() {
    float minD = 1e9;
    for (int i = 0; i < u_curve_seqCount; i++) {
      vec2 p = u_curve_seq[i].xy;
      float d = distance(vWorld, p);
      if (d < minD) minD = d;
    }
    float t = clamp(minD / 200.0, 0.0, 1.0);
    gl_FragColor = vec4(vec3(1.0 - t, 0.3, t), 0.9);
  }
`;

  const img_1 = createFunctionImage2D(scene, {
    inputs: { curve_seq },
    corner0: [-150, -50],
    corner1: [200, 250],
    filtering: "bilinear",
    z: -1,
    shader,
  });
}

// Prezire:
// - Több bevezetés
// - Egy picit gyorsabb

// Plusz:
// - Pontokat mutatva mutassam, hogy mozgatható (de a dPoint nem!)
// - Indexet nem kell feltétlen megmutatni, kód nem olyan fontos (inkább a látvány)
// - dPoint --> Kihangsúlyozni hogy callback alapján számolódik, elmondani mik a paraméterek és mit ad vissza
// - curve --> Parametrikus görbét ábrázol, a callback a parametrikus görbének a függvénye
// - customValue --> Nincs benne a bemutatóban, úgy kéne, hogy egyedi értéket adjon vissza, majd azt használja valami (pl. poligon az input, élhossz, súlypont, terület kiszámolása majd ezt egy struktúrában adja vissza, eyg szöveg kiírja terület: ..., élhossz: ... stb.)
// - @TODO curve --> tMin és tMax állíthatósága 0 és 1 helyett
// - @TODO pointSequence --> Inkább ebben lehessen állítani, hogy hány részre osztja fel pl. a curve-öt, mint sem curve segment
// - Shader példába átírni, hogy a színezés legyen (https://www.shadertoy.com/view/wtVyDz) 73-77
// - @TODO image --> Legyen megadható akár több curve is
// - @TODO Dependency egységesítése (Tulajdonképpen csak annyi különbözik, hogy mit ad vissza)
// - @TODO Callback-nél ellenőrzés, hogy ha hívható függvényt adunk át, akkor fusson le
// - @TODO Point sequence és poligno callback-el generáltatni (jelenleg a customValue-val helyettesíthető)

// - @TODO CustomValue lehessen input-ja az image-nek (feltételesen, pl. struktúrát ad vissza)
// - @TODO HTML beviteli mezőket hazsnálni a dependency rendszerbe (pl. egy numINput field aminek az értékét pl. egy dPoint megkapja)
// - @TODO Valamelyik callback hibával tér vissza, akkor objektum ne jelenjen meg és a tőle függő dolgok se jelenjenek meg
