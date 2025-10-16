import { point } from "./point.js";
import {
  createUniformCurve,
  createCentripetalCurve,
  createChordalCurve,
} from "./curve.js";

export function draw(scene) {
  const point_1 = point(scene, 200, 250);
  const point_2 = point(scene, 200, 500);
  const point_3 = point(scene, -200, 250);
  const point_4 = point(scene, -500, -100);

  const point_5 = point(scene, 500, 50);
  const point_6 = point(scene, -500, -100);

  createUniformCurve(scene, [point_1, point_2, point_3, point_4]);
  createUniformCurve(scene, point_5, point_6, 0.5, "green");
}
