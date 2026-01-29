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

export function draw(scene) {}

// - @TODO curve --> tMin és tMax állíthatósága 0 és 1 helyett
// - @TODO image --> Legyen megadható akár több curve is
// - @TODO Dependency egységesítése (Tulajdonképpen csak annyi különbözik, hogy mit ad vissza)
// - @TODO Point sequence és poligno callback-el generáltatni (jelenleg a customValue-val helyettesíthető)
// - @TODO HTML beviteli mezőket hazsnálni a dependency rendszerbe (pl. egy numINput field aminek az értékét pl. egy dPoint megkapja)
// - @TODO Valamelyik callback hibával tér vissza, akkor objektum ne jelenjen meg és a tőle függő dolgok se jelenjenek meg
