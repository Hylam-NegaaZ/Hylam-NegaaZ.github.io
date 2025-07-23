import * as THREE from 'three';
import { GLTFLoader } from 'three/addons/loaders/GLTFLoader.js';

/* ========================normal js========================== */
// Get all radio inputs with name="color"
const radios = document.querySelectorAll('input[name="color"]');
const colorPicker = document.getElementById('customColor');

let selectedColor = null;

// Watch radio buttons
radios.forEach((radio) => {
  radio.addEventListener('change', () => {
    if (radio.checked) {
      selectedColor = radio.value;
      console.log('Selected radio color:', selectedColor);
    
    if (targetMesh) {
        targetMesh.material.color.set(selectedColor);
      }
    }
  });
});

// Handle custom color picker
colorPicker.addEventListener('input', (e) => {
    selectedColor = e.target.value;
    console.log('Custom picked color:', selectedColor);

    radios.forEach((r) => (r.checked = false));

    if (targetMesh) {
    targetMesh.material.color.set(selectedColor);
}
});
const colorPreview = colorPicker.parentElement; // the label

colorPicker.addEventListener('input', (e) => {
  selectedColor = e.target.value;
  radios.forEach((r) => (r.checked = false));

  // set preview fill to selected color
  colorPreview.style.backgroundColor = selectedColor;

  // apply color to mesh
  if (targetMesh) {
    targetMesh.material.color.set(selectedColor);
  }
});
/* ----------------------------------------------------------- */



var container = document.getElementById( 'canvas' );
let mixer;

const scene = new THREE.Scene();
    scene.background = new THREE.Color( '#f6f6f6' );

const camera = new THREE.PerspectiveCamera(75, container.clientWidth/container.clientHeight);
    camera.position.z = 5;
    camera.position.x = -5;
    camera.position.y = 5;

const renderer = new THREE.WebGLRenderer({ antialias: true });
    renderer.setSize( container.clientWidth-16, container.clientHeight-16 );
    renderer.shadowMap.enabled = true;
    renderer.shadowMap.type = THREE.PCFSoftShadowMap;
    container.appendChild( renderer.domElement );

import { OrbitControls } from 'three/addons/controls/OrbitControls.js';
const controls = new OrbitControls(camera, renderer.domElement);

var ambientLight = new THREE.AmbientLight( 'white', 0.5 );
    scene.add( ambientLight );
    
const dirLight = new THREE.DirectionalLight(0xffffff, 1);
    dirLight.position.set(0, 15, 10);
    dirLight.castShadow = true;
    
    // Optional: improve shadow quality
    dirLight.shadow.radius = 4;
    dirLight.shadow.mapSize.width = 2048;
    dirLight.shadow.mapSize.height = 2048;
    dirLight.shadow.camera.left = -20;
    dirLight.shadow.camera.right = 20;
    dirLight.shadow.camera.top = 20;
    dirLight.shadow.camera.bottom = -20;
    dirLight.shadow.camera.near = 0.5;
    dirLight.shadow.camera.far = 1000;
    dirLight.shadow.bias = -0.001;
    scene.add(dirLight);

// Plane geometry: width, height
    const geometry = new THREE.PlaneGeometry(10000, 10000); // huge plane
    const shadowMat = new THREE.ShadowMaterial({ opacity: 0.2 }); // 0.0–1.0 for shadow darkness
const plane = new THREE.Mesh(geometry, shadowMat);
    
    shadowMat.transparent = true;
    plane.rotation.x = -Math.PI / 2;
    plane.receiveShadow = true;
    scene.add(plane);
    

    let targetMesh = null;
    let meshList = [];
    let currentMeshIndex = 0;
const loader = new GLTFLoader();
loader.load('basas_sneaker_2.glb', (gltf) => {
    const model = gltf.scene;
    model.castShadow = true;
    model.scale.set(1, 1, 1);
    model.position.y += 2.5;
    model.rotation.x = THREE.MathUtils.degToRad(30);
    scene.add(model);

    model.traverse((child) => {
        if (child.isMesh) {
            child.castShadow = true;
            child.receiveShadow = true;
            meshList.push(child);
        }
        });
        if (meshList.length > 0) {
        targetMesh = meshList[0];
        }
});
function updateTargetMesh(index) {
  if (meshList.length === 0) return;

  // Clamp index within valid range
  currentMeshIndex = (index + meshList.length) % meshList.length;
  targetMesh = meshList[currentMeshIndex];

  console.log("Now targeting:", targetMesh.name);

  // Optional highlight
  meshList.forEach((m) => {
    if (m.material?.emissive) m.material.emissive.set(0x000000);
  });

  if (targetMesh.material?.emissive) {
    targetMesh.material.emissive.set(0x333333); // subtle glow
  }
}
/* buttons */
document.getElementById("nextMesh").addEventListener("click", () => {
  updateTargetMesh(currentMeshIndex + 1);
});

document.getElementById("prevMesh").addEventListener("click", () => {
  updateTargetMesh(currentMeshIndex - 1);
});

const clock = new THREE.Clock();

function animate() {
    requestAnimationFrame(animate);

    const delta = clock.getDelta(); // Time since last frame
    if (mixer) mixer.update(delta); // Advance animation

    if (camera.position.y < plane.position.y) {
        plane.visible = false;
    } else {
        plane.visible = true;
    }

    renderer.render(scene, camera);
    controls.update();
}
animate();
