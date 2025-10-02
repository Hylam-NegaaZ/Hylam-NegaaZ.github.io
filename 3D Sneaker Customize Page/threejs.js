import * as THREE from 'three';
import { OrbitControls } from 'three/addons/controls/OrbitControls.js';
import { OBJLoader } from 'three/addons/loaders/OBJLoader.js';
import { MTLLoader } from 'three/addons/loaders/MTLLoader.js';

let container = document.getElementById('canvas');
const scene = new THREE.Scene();
scene.background = new THREE.Color('#f6f6f6');

const camera = new THREE.PerspectiveCamera(75, container.clientWidth / container.clientHeight);
camera.position.set(-5, 5, 5);

const renderer = new THREE.WebGLRenderer({ antialias: true });
renderer.setSize(container.clientWidth - 16, container.clientHeight - 16);
renderer.shadowMap.enabled = true;
renderer.shadowMap.type = THREE.PCFSoftShadowMap;
container.appendChild(renderer.domElement);

const controls = new OrbitControls(camera, renderer.domElement);
controls.enableDamping = true;
controls.dampingFactor = 0.05;
controls.rotateSpeed = 0.7;
controls.zoomSpeed = 0.6;
controls.panSpeed = 0.4;

const ambientLight = new THREE.AmbientLight('white', 0.5);
scene.add(ambientLight);

const dirLight = new THREE.DirectionalLight(0xffffff, 1);
dirLight.position.set(0, 15, 10);
dirLight.castShadow = true;
dirLight.shadow.radius = 4;
dirLight.shadow.mapSize.width = 2048;
dirLight.shadow.mapSize.height = 2048;
dirLight.shadow.camera.left = -20;
dirLight.shadow.camera.right = 20;
dirLight.shadow.camera.top = 20;
dirLight.shadow.camera.bottom = -20;
dirLight.shadow.bias = -0.001;
scene.add(dirLight);

const planeGeometry = new THREE.PlaneGeometry(10000, 10000);
const shadowMat = new THREE.ShadowMaterial({ opacity: 0.2 });
shadowMat.transparent = true;
const plane = new THREE.Mesh(planeGeometry, shadowMat);
plane.rotation.x = -Math.PI / 2;
plane.receiveShadow = true;
scene.add(plane);

let objectList = [];
let targetMesh = null;
let currentMeshIndex = 0;

// Load MTL first
const mtlLoader = new MTLLoader();
mtlLoader.load('ananas.mtl', (materials) => {
  materials.preload(); // preload materials for OBJ

  const objLoader = new OBJLoader();
  objLoader.setMaterials(materials); // 🔗 assign materials
  objLoader.load('ananas.obj', (obj) => {
    obj.traverse((child) => {
      if (child.isMesh) {
        child.castShadow = true;
        child.receiveShadow = true;
        console.log("Mesh name:", child.name);
        // Optional: clone material to avoid shared reference bugs
        child.material = child.material.clone();
      const customMaterial = new THREE.MeshStandardMaterial({
        color: child.material.color ? child.material.color.clone() : new THREE.Color(0xffffff),
        roughness: 0.9,   // Make surface rough (matte)
        metalness: 0.0,   // No metallic reflection
      });

      // Retain texture if available
      if (child.material.map) {
        customMaterial.map = child.material.map;
        customMaterial.map.needsUpdate = true;
      }

      child.material = customMaterial;
        objectList.push(child);
      }
    });

    obj.scale.set(1, 1, 1);
    obj.position.set(0, 2, 0);
    scene.add(obj);

    if (objectList.length > 0) {
      targetMesh = objectList[0];
    }
  });
});

const meshNameMap = {
  'Đế': 'Đế giày',
  'Mũi': 'Mũi giày',
  'Lỗ_xỏ': 'Lỗ xỏ dây',
  'Thân': 'Thân giày',
  'Lót_trên': 'Lót trong giày',
  'Logo1': 'Trang trí trước giày',
  'Dây1': 'Dây giày',
  'Logo2': 'Trang trí sau giày'
};
let previousMesh = null; // track previously highlighted mesh

function updateTargetMesh(index) {
  if (objectList.length === 0) return;

  // Restore previous material if needed
  if (previousMesh && previousMesh.userData.originalMaterial) {
    previousMesh.material = previousMesh.userData.originalMaterial;
    previousMesh.userData.originalMaterial = null; // clean up
  }

  // Clamp and update index
  currentMeshIndex = (index + objectList.length) % objectList.length;
  targetMesh = objectList[currentMeshIndex];
  if (!targetMesh) return;

  console.log('Now targeting:', targetMesh.name);
  document.getElementById('custom_name').innerText = meshNameMap[targetMesh.name] || targetMesh.name;

  // Save original material
  if (!targetMesh.userData.originalMaterial) {
    targetMesh.userData.originalMaterial = targetMesh.material;
  }

  // Clone highlight material
  const highlightMaterial = targetMesh.material.clone();
  highlightMaterial.emissive = new THREE.Color(0, 0, 1); // yellow
  highlightMaterial.emissiveIntensity = 1;
  targetMesh.material = highlightMaterial;

  previousMesh = targetMesh; // update reference

  // Animate pulse
  let pulseStart = performance.now();
  const pulseDuration = 1000;
  const pulseInterval = setInterval(() => {
    const now = performance.now();
    const elapsed = now - pulseStart;
    const t = (elapsed % pulseDuration) / pulseDuration;
    const intensity = 0.5 + 0.5 * Math.sin(t * Math.PI * 2);
    highlightMaterial.emissiveIntensity = intensity;

    if (elapsed > pulseDuration) {
      clearInterval(pulseInterval);
      if (targetMesh && targetMesh.userData.originalMaterial) {
        targetMesh.material = targetMesh.userData.originalMaterial;
        targetMesh.userData.originalMaterial = null;
      }
    }
  }, 33);
}

document.getElementById('nextMesh').addEventListener('click', () => {
  updateTargetMesh(currentMeshIndex + 1);
});

document.getElementById('prevMesh').addEventListener('click', () => {
  updateTargetMesh(currentMeshIndex - 1);
});

// Handle color selection
const radios = document.querySelectorAll('input[name="color"]');
const colorPicker = document.getElementById('customColor');
const colorPreview = colorPicker.parentElement;
let selectedColor = null;

radios.forEach((radio) => {
  radio.addEventListener('change', () => {
    if (radio.checked) {
      selectedColor = radio.value;
      if (targetMesh && targetMesh.material) {
        targetMesh.material.color.set(selectedColor);
      }
    }
  });
});

colorPicker.addEventListener('input', (e) => {
  selectedColor = e.target.value;
  radios.forEach((r) => (r.checked = false));
  colorPreview.style.backgroundColor = selectedColor;
  if (targetMesh && targetMesh.material) {
    targetMesh.material.color.set(selectedColor);
  }
});

const clock = new THREE.Clock();

function animate() {
  requestAnimationFrame(animate);

  if (camera.position.y < plane.position.y) {
    plane.visible = false;
  } else {
    plane.visible = true;
  }

  renderer.render(scene, camera);
  controls.update();
}

animate();