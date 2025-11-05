import { point, dPoint } from "./point.js";
import {
  createUniformCurve,
  createCentripetalCurve,
  createChordalCurve,
} from "./curve.js";
import { circle } from "./circle.js";

export function draw(scene) {
  const point_1 = point(scene, 50, 50);
  const point_2 = point(scene, 20, 160);
  const point_3 = point(scene, -20, 50);
  const point_4 = point(scene, -50, -100);
  const point_5 = point(scene, 150, 50);
  const point_6 = point(scene, -200, -100);

  createUniformCurve(scene, [point_1, point_2, point_3, point_4]);
  createUniformCurve(scene, point_5, point_6, 0.5, "green");

  dPoint(
    scene,
    point_1,
    point_6,
    (a, b) => a.clone().add(b).multiplyScalar(0.5),
    10,
    "green"
  );

  const circ1 = circle(scene, point_1, point_2, point_3, {
    color: 0x0066ff,
  });
  const circ2 = circle(scene, point_1, point_2, { color: 0x22aa22 });
  const circ3 = circle(scene, [300, -150], 120, { color: 0xaa2222 });
}
