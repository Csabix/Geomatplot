import { point, dPoint } from "./point.js";
import {
  createUniformCurve,
  createCentripetalCurve,
  createChordalCurve,
} from "./curve.js";
import { circle } from "./circle.js";
import { distance } from "./distance.js";
import { segment } from "./segment.js";
import { pointSequence } from "./pointSequence.js";
import { polygon } from "./polygon.js";
import { text } from "./text.js";

export function draw(scene) {
  /* ----- POINT ----- */

  const point_1 = point(scene, 50, 50);
  const point_2 = point(scene, 20, 160);
  const point_3 = point(scene, -20, 50);
  const point_4 = point(scene, -50, -100);
  const point_5 = point(scene, 150, 50);
  const point_6 = point(scene, -200, -100);

  /* ----- CURVE ----- */

  createUniformCurve(scene, [point_1, point_2, point_3, point_4]);
  createUniformCurve(scene, point_5, point_6, 0.5, "green"); // @TODO: Függvényt lehessen ábrázolni (callback-el)

  /* ----- DEPENDENT POINT ----- */

  dPoint(
    scene,
    point_1,
    point_6,
    point_4,
    (a, b, c) => a.clone().add(b).add(c).multiplyScalar(0.5), // @TODO: Finomítást igényel, hogy szebb legyen
    10,
    "green"
  );

  /* ----- CIRCLE ----- */

  // const circ1 = circle(scene, point_1, point_2, point_3, {
  //   color: 0x0066ff,
  // });
  // const circ2 = circle(scene, point_1, point_2, { color: 0x22aa22 });
  // const circ3 = circle(scene, [300, -150], 120, { color: 0xaa2222 });

  /* ----- DISTANCE ----- */

  // const dAB = distance(point_2, point_5);
  // dAB.onChange((v) => console.log("|AB| =", v));

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
  //   // @TODO: Engedélyezni kéne több point-ot is / throw warning hogy nem lehet
  //   color: 0x333333,
  //   linewidth: 2,
  // });
  // const s2 = segment(scene, point_1, [80, -40], { dashed: true });

  /* ----- POLYGON ----- */

  // const poly1 = polygon(
  //   scene,
  //   [
  //     [0, 0],
  //     [100, 0], // @TODO: Lehessen keverni is akár, itt pl. egy point_2 -> Háttérben a koordinátát egy ponttá alakítani
  //     [80, 60],
  //   ],
  //   { color: 0x0088ff, faceAlpha: 0.2 }
  // );

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
}
