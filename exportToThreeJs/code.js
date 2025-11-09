import { point, dPoint } from "./point.js";
import {
  createUniformCurve,
  createCentripetalCurve,
  createChordalCurve,
} from "./curve.js";
import { circle } from "./circle.js";
import { distance } from "./distance.js";

export function draw(scene) {
  const point_1 = point(scene, 50, 50);
  const point_2 = point(scene, 20, 160);
  const point_3 = point(scene, -20, 50);
  const point_4 = point(scene, -50, -100);
  const point_5 = point(scene, 150, 50);
  // const point_6 = point(scene, -200, -100);

  // createUniformCurve(scene, [point_1, point_2, point_3, point_4]);
  // createUniformCurve(scene, point_5, point_6, 0.5, "green");

  // dPoint(
  //   scene,
  //   point_1,
  //   point_6,
  //   (a, b) => a.clone().add(b).multiplyScalar(0.5),
  //   10,
  //   "green"
  // );

  // const circ1 = circle(scene, point_1, point_2, point_3, {
  //   color: 0x0066ff,
  // });
  // const circ2 = circle(scene, point_1, point_2, { color: 0x22aa22 });
  // const circ3 = circle(scene, [300, -150], 120, { color: 0xaa2222 });

  const dAB = distance(point_2, point_5);
  // dAB.onChange((v) => console.log("|AB| =", v));

  const dA_to_many = distance(point_1, [point_4, point_5, [200, 10]]);
  // dA_to_many.onChange((v) => console.log("min dist(A, seq) =", v));

  const circ = circle(scene, point_2, point_4, point_5, { color: 0x3366ff });
  const dA_to_circ = distance(point_1, circ);
  // dA_to_circ.onChange((v) => console.log("gap(A, circle) =", v));

  const poly = createUniformCurve(scene, [point_1, point_2, point_3]);
  const dA_to_poly = distance(point_1, poly);
  // dA_to_poly.onChange((v) => console.log("min dist(A, polyline) =", v));
}
