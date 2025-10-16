import * as THREE from "three";

export function init() {
  let container, camera, scene, renderer;

  container = document.getElementById("container");

  createScene();
  createCamera();
  createRenderer();

  scene.add(new THREE.AmbientLight(0xf0f0f0, 3));
  window.addEventListener("resize", onWindowResize);

  return { container, camera, scene, renderer };

  function onWindowResize() {
    updateOrthoFrustum();
    const { w, h } = sizeFromContainer(container);
    renderer.setSize(w, h);
    renderer.render(scene, camera);
  }

  function updateOrthoFrustum() {
    const { w, h } = sizeFromContainer(container);
    camera.left = -w / 2;
    camera.right = w / 2;
    camera.top = h / 2;
    camera.bottom = -h / 2;
    camera.updateProjectionMatrix();
  }

  function createCamera() {
    const { w, h } = sizeFromContainer(container);
    camera = new THREE.OrthographicCamera(
      -w / 2,
      w / 2,
      h / 2,
      -h / 2,
      1,
      5000
    );
    camera.position.set(0, 0, 1000);
    camera.lookAt(0, 0, 0);
    camera.zoom = 1;
    camera.updateProjectionMatrix();
    scene.add(camera);
  }

  function sizeFromContainer(container) {
    const r = container.getBoundingClientRect();
    return { w: Math.round(r.width), h: Math.round(r.height) };
  }

  function createScene() {
    scene = new THREE.Scene();
  }

  function createRenderer() {
    renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true });
    renderer.setClearColor(0x000000, 0);
    renderer.setPixelRatio(window.devicePixelRatio);
    const { w, h } = sizeFromContainer(container);
    renderer.setSize(w, h);
    renderer.shadowMap.enabled = true;
    container.appendChild(renderer.domElement);
  }
}
