import { DragControls } from "three/addons/controls/DragControls.js";

let controls;

export function createControls(camera, renderer, scene) {
  controls = new DragControls([], camera, renderer.domElement);

  controls.addEventListener("dragstart", (event) => {
    if (event.object.material.emissive)
      event.object.material.emissive.set(0xaaaaaa);
  });

  controls.addEventListener("dragend", (event) => {
    if (event.object.material.emissive)
      event.object.material.emissive.set(0x000000);

    renderer.render(scene, camera);
  });

  controls.addEventListener("drag", () => {
    renderer.render(scene, camera);
  });
}

export function addDraggableObject(object) {
  controls.objects.push(object);
}
