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

export function draw(scene) {
  /* ----- POINT ----- */

  const point_1 = point(scene, 50, 50);
  const point_2 = point(scene, 20, 160);
  const point_3 = point(scene, -20, 50);
  const point_4 = point(scene, -50, -100);
  const point_5 = point(scene, 150, 50);
  // const point_6 = point(scene, -200, -100);

  /* ----- CURVE ----- */

  // createUniformCurve(scene, [point_1, point_2, point_3, point_4]);
  // createUniformCurve(scene, point_5, point_6, 0.5, "green");

  /* ----- DEPENDENT POINT ----- */

  // dPoint(
  //   scene,
  //   point_1,
  //   point_6,
  //   (a, b) => a.clone().add(b).multiplyScalar(0.5),
  //   10,
  //   "green"
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
  // const s2 = segment(scene, point_1, [80, -40], { dashed: true });

  /* ----- POLYGON ----- */

  const poly1 = polygon(
    scene,
    [
      [0, 0],
      [100, 0],
      [80, 60],
    ],
    { color: 0x0088ff, faceAlpha: 0.2 }
  );

  const poly2 = polygon(scene, point_1, point_2, point_3, {
    color: 0xdd5522,
    faceAlpha: 0.15,
  });

  const seq = pointSequence(scene, point_1, point_2, point_3);
  const curve = createUniformCurve(scene, [point_1, point_2, point_3]);
  const poly3 = polygon(scene, seq, curve, { color: 0x22aa22, faceAlpha: 0.1 });

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
}
