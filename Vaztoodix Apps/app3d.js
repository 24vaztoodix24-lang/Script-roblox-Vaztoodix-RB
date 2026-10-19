// ============================================================
// Vaztoodix Studio v3 - app3d.js
// Scène 3D + Bots R6 + Contrôles caméra + Mouvements
// ============================================================

const LuaAPI = [
  "game:GetService", "game.Players", "game.Workspace", "game.ReplicatedStorage",
  "game:HttpGet", "Instance.new", "loadstring",
  "wait", "task.wait", "spawn", "pcall",
  "print", "warn", "tostring", "tonumber",
  "math.random", "math.floor", "math.clamp",
  "CFrame.new", "Vector3.new", "Color3.fromRGB", "UDim2.new",
  "FindFirstChild", "WaitForChild", "GetChildren",
  "FireServer", "InvokeServer", "Connect",
  "Humanoid", "HumanoidRootPart", "Character", "Backpack",
  "LocalPlayer", "WalkSpeed", "JumpPower"
];

// ===== ÉTAT GLOBAL 3D =====
let scene, camera, renderer, controls;
let r6Model = null;
const bots = [];
let selectedBot = null;
let botSpeedMultiplier = 1;
let botJumpMultiplier = 1;
let botNoclip = false;
let botFlyMode = false;
const keys = {};

// ===== ÉDITEUR =====
function setupEditor() {
  const textarea = document.getElementById("codeTextarea");
  const lineNumbers = document.getElementById("lineNumbers");
  const autocompleteBox = document.getElementById("autocompleteBox");
  if (!textarea || !lineNumbers) return;

  const saved = localStorage.getItem("vaz_script") || "";
  textarea.value = saved;

  function updateLineNumbers() {
    const lines = textarea.value.split("\n").length;
    let html = "";
    for (let i = 1; i <= Math.max(lines, 20); i++) html += `<div class="line-number">${i}</div>`;
    lineNumbers.innerHTML = html;
  }

  textarea.addEventListener("input", updateLineNumbers);
  textarea.addEventListener("scroll", () => { lineNumbers.scrollTop = textarea.scrollTop; });

  let autocompleteIndex = 0;
  let currentSuggestions = [];

  textarea.addEventListener("input", () => {
    const cursorPos = textarea.selectionStart;
    const beforeCursor = textarea.value.substring(0, cursorPos);
    const match = beforeCursor.match(/[\w.:]+$/);
    if (match && match[0].length >= 2) {
      const query = match[0].toLowerCase();
      currentSuggestions = LuaAPI.filter(api => api.toLowerCase().includes(query)).slice(0, 8);
      if (currentSuggestions.length > 0) showAutocomplete(currentSuggestions, autocompleteBox);
      else autocompleteBox.style.display = "none";
    } else autocompleteBox.style.display = "none";
  });

  textarea.addEventListener("keydown", (e) => {
    if (autocompleteBox.style.display === "block") {
      if (e.key === "ArrowDown") { e.preventDefault(); autocompleteIndex = (autocompleteIndex + 1) % currentSuggestions.length; highlightSuggestion(autocompleteBox, autocompleteIndex); }
      else if (e.key === "ArrowUp") { e.preventDefault(); autocompleteIndex = (autocompleteIndex - 1 + currentSuggestions.length) % currentSuggestions.length; highlightSuggestion(autocompleteBox, autocompleteIndex); }
      else if (e.key === "Enter" || e.key === "Tab") { e.preventDefault(); insertSuggestion(textarea, currentSuggestions[autocompleteIndex]); }
      else if (e.key === "Escape") autocompleteBox.style.display = "none";
    }
  });

  updateLineNumbers();
}

function showAutocomplete(suggestions, box) {
  box.innerHTML = suggestions.map((s, i) =>
    `<div class="autocomplete-item ${i === 0 ? 'selected' : ''}" onclick="insertSuggestion(document.getElementById('codeTextarea'), '${s}')">${s}</div>`
  ).join("");
  box.style.display = "block";
  autocompleteIndex = 0;
}
function highlightSuggestion(box, index) {
  box.querySelectorAll(".autocomplete-item").forEach((item, i) => item.classList.toggle("selected", i === index));
}
function insertSuggestion(textarea, suggestion) {
  const cursorPos = textarea.selectionStart;
  const before = textarea.value.substring(0, cursorPos);
  const after = textarea.value.substring(cursorPos);
  const match = before.match(/[\w.:]+$/);
  if (match) {
    const nb = before.substring(0, before.length - match[0].length) + suggestion;
    textarea.value = nb + after;
    textarea.selectionStart = textarea.selectionEnd = nb.length;
  }
  document.getElementById("autocompleteBox").style.display = "none";
}
function runScript() { showNotification("▶️ Script exécuté sur le bot"); }
function saveScript() { localStorage.setItem("vaz_script", document.getElementById("codeTextarea").value); showNotification("💾 Script sauvegardé"); }
function clearEditor() { if (confirm("Effacer ?")) { localStorage.removeItem("vaz_script"); document.getElementById("codeTextarea").value = ""; setupEditor(); } }

// ===== SCÈNE 3D =====
function initThreeJS() {
  const canvas = document.getElementById("three-canvas");
  if (!canvas || canvas.clientWidth === 0) { setTimeout(initThreeJS, 100); return; }

  scene = new THREE.Scene();
  scene.background = new THREE.Color(0x1a0a1f);
  scene.fog = new THREE.Fog(0x1a0a1f, 100, 400);

  camera = new THREE.PerspectiveCamera(60, canvas.clientWidth / canvas.clientHeight, 0.1, 1000);
  camera.position.set(0, 25, 50);

  renderer = new THREE.WebGLRenderer({ canvas, antialias: true });
  renderer.setSize(canvas.clientWidth, canvas.clientHeight, false);
  renderer.setPixelRatio(window.devicePixelRatio);
  renderer.shadowMap.enabled = true;

  controls = new THREE.OrbitControls(camera, renderer.domElement);
  controls.enableDamping = true;
  controls.maxPolarAngle = Math.PI / 2;
  controls.minDistance = 5;
  controls.maxDistance = 200;
  controls.target.set(0, 1, 0);

  scene.add(new THREE.AmbientLight(0xffffff, 0.7));
  const sun = new THREE.DirectionalLight(0xffffff, 0.9);
  sun.position.set(50, 100, 50);
  sun.castShadow = true;
  scene.add(sun);

  const BASEPLATE_SIZE = 300;
  const baseplate = new THREE.Mesh(
    new THREE.BoxGeometry(BASEPLATE_SIZE, 4, BASEPLATE_SIZE),
    new THREE.MeshLambertMaterial({ color: 0x404040 })
  );
  baseplate.position.y = -2;
  baseplate.receiveShadow = true;
  scene.add(baseplate);

  const grid = new THREE.GridHelper(BASEPLATE_SIZE, BASEPLATE_SIZE / 5, 0x606060, 0x606060);
  grid.position.y = 0.01;
  scene.add(grid);

  // Charger R6
  const GLB_URL = "https://raw.githubusercontent.com/24vaztoodix24-lang/Script-roblox-Vaztoodix-RB/refs/heads/main/roblox_r6_model.glb";
  const loader = new THREE.GLTFLoader();
  loader.load(GLB_URL,
    (gltf) => { r6Model = gltf.scene; r6Model.traverse(o => { if (o.isMesh) { o.castShadow = true; o.receiveShadow = true; } }); updateBots(5); },
    undefined,
    () => { updateBots(5); }
  );

  canvas.addEventListener("click", handleBotClick);

  // Sliders
  document.getElementById("sceneSizeSlider")?.addEventListener("input", (e) => {
    const pct = e.target.value;
    document.getElementById("sceneSizeValue").textContent = pct + "%";
    document.getElementById("sceneContainer").style.height = (260 * pct / 100) + "px";
    setTimeout(() => {
      const rect = canvas.getBoundingClientRect();
      if (rect.width === 0) return;
      camera.aspect = rect.width / rect.height;
      camera.updateProjectionMatrix();
      renderer.setSize(rect.width, rect.height, false);
    }, 50);
  });

  document.getElementById("zoomSlider")?.addEventListener("input", (e) => {
    camera.position.setLength(parseFloat(e.target.value) + 10);
    controls.update();
  });

  document.getElementById("rotationSlider")?.addEventListener("input", (e) => {
    const angle = parseFloat(e.target.value) * Math.PI / 180;
    const dist = camera.position.length();
    camera.position.set(Math.sin(angle) * dist, camera.position.y, Math.cos(angle) * dist);
    controls.update();
  });

  document.getElementById("botSpeedSlider")?.addEventListener("input", (e) => {
    botSpeedMultiplier = parseFloat(e.target.value) / 30;
  });

  document.getElementById("botSlider")?.addEventListener("input", (e) => updateBots(parseInt(e.target.value)));

  document.getElementById("btnCollapseRight")?.addEventListener("click", () => {
    document.getElementById("rightPanel").classList.toggle("collapsed");
    setTimeout(() => {
      const rect = canvas.getBoundingClientRect();
      if (rect.width === 0) return;
      camera.aspect = rect.width / rect.height;
      camera.updateProjectionMatrix();
      renderer.setSize(rect.width, rect.height, false);
    }, 400);
  });

  window.addEventListener("resize", () => {
    const rect = canvas.getBoundingClientRect();
    if (rect.width === 0) return;
    camera.aspect = rect.width / rect.height;
    camera.updateProjectionMatrix();
    renderer.setSize(rect.width, rect.height, false);
  });

  // Clavier
  window.addEventListener("keydown", (e) => { keys[e.key.toLowerCase()] = true; if (e.code === "Space") e.preventDefault(); });
  window.addEventListener("keyup", (e) => { keys[e.key.toLowerCase()] = false; });

  animate(0);
}

// ===== BOTS =====
function createCubeBot() {
  const bot = new THREE.Group();
  const skin = 0xffdcb3;
  const shirt = [0x3498db, 0xe74c3c, 0x2ecc71][Math.floor(Math.random()*3)];
  const pants = 0x2c3e50;
  const addBox = (w, h, d, c, x, y, z) => {
    const m = new THREE.Mesh(new THREE.BoxGeometry(w, h, d), new THREE.MeshLambertMaterial({ color: c }));
    m.position.set(x, y, z); m.castShadow = true; bot.add(m); return m;
  };
  addBox(1, 1, 1, skin, 0, 2.5, 0);
  addBox(1.2, 1.5, 0.6, shirt, 0, 1.25, 0);
  const leftArm = addBox(0.4, 1.4, 0.4, skin, -0.9, 1.25, 0);
  const rightArm = addBox(0.4, 1.4, 0.4, skin, 0.9, 1.25, 0);
  const leftLeg = addBox(0.5, 1.5, 0.5, pants, -0.3, 0, 0);
  const rightLeg = addBox(0.5, 1.5, 0.5, pants, 0.3, 0, 0);
  bot.userData = {
    leftArm, rightArm, leftLeg, rightLeg,
    velocityY: 0, velocityX: 0, velocityZ: 0,
    baseY: 0.75, walkPhase: Math.random()*Math.PI*2,
    targetRotationY: 0, isJumping: false
  };
  bot.position.set((Math.random()-0.5)*80, 0.75, (Math.random()-0.5)*80);
  scene.add(bot);
  return bot;
}

function createR6Bot() {
  if (!r6Model) return createCubeBot();
  const bot = r6Model.clone(true);
  let leftArm, rightArm, leftLeg, rightLeg;
  bot.traverse(o => {
    const n = o.name.toLowerCase();
    if (n.includes("leftarm")) leftArm = o;
    if (n.includes("rightarm")) rightArm = o;
    if (n.includes("leftleg")) leftLeg = o;
    if (n.includes("rightleg")) rightLeg = o;
  });
  const box = new THREE.Box3().setFromObject(bot);
  const modelBottom = box.min.y;
  bot.userData = {
    leftArm, rightArm, leftLeg, rightLeg,
    velocityY: 0, velocityX: 0, velocityZ: 0,
    baseY: -modelBottom, walkPhase: Math.random()*Math.PI*2,
    targetRotationY: bot.rotation.y, isJumping: false
  };
  bot.position.set((Math.random()-0.5)*80, -modelBottom, (Math.random()-0.5)*80);
  bot.rotation.y = Math.random() * Math.PI * 2;
  scene.add(bot);
  return bot;
}

function updateBots(count) {
  document.getElementById("botCount").textContent = count;
  while (bots.length < count) bots.push(r6Model ? createR6Bot() : createCubeBot());
  while (bots.length > count) { const b = bots.pop(); if (b === selectedBot) selectedBot = null; scene.remove(b); }
}

function handleBotClick(e) {
  const canvas = document.getElementById("three-canvas");
  const rect = canvas.getBoundingClientRect();
  const mouse = new THREE.Vector2(((e.clientX - rect.left) / rect.width) * 2 - 1, -((e.clientY - rect.top) / rect.height) * 2 + 1);
  const raycaster = new THREE.Raycaster();
  raycaster.setFromCamera(mouse, camera);
  const hits = raycaster.intersectObjects(bots, true);
  if (hits.length > 0) {
    let obj = hits[0].object;
    while (obj.parent && !bots.includes(obj)) obj = obj.parent;
    if (bots.includes(obj)) {
      if (selectedBot) selectedBot.traverse(o => { if (o.isMesh && o.userData.origMat) { o.material = o.userData.origMat; o.userData.origMat = null; } });
      selectedBot = obj;
      selectedBot.traverse(o => { if (o.isMesh) { o.userData.origMat = o.material; o.material = new THREE.MeshBasicMaterial({ color: 0x00ff00, wireframe: true, transparent: true, opacity: 0.5 }); } });
      showNotification("🎯 Bot sélectionné");
    }
  }
}

// ===== FONCTIONS DE MOUVEMENT (appliquées aux bots) =====
function toggleBotFly(enable) {
  botFlyMode = enable;
  bots.forEach(bot => {
    if (enable) bot.userData.flyOffset = 5;
    else bot.userData.flyOffset = 0;
  });
}

function setBotSpeed(multiplier) {
  botSpeedMultiplier = multiplier;
}

function setBotJump(multiplier) {
  botJumpMultiplier = multiplier;
}

function setBotNoclip(enable) {
  botNoclip = enable;
}

// ===== BOUCLE =====
function animate(time) {
  requestAnimationFrame(animate);
  const dt = 0.016;

  bots.forEach(bot => {
    const ud = bot.userData;

    // Gravité (désactivée si fly)
    if (!botFlyMode) {
      ud.velocityY -= 0.04;
      bot.position.y += ud.velocityY;
      if (bot.position.y <= ud.baseY) { bot.position.y = ud.baseY; ud.velocityY = 0; ud.isJumping = false; }
    } else {
      bot.position.y += ((ud.baseY + 5) - bot.position.y) * 0.05;
    }

    // Contrôles clavier (uniquement pour le bot sélectionné)
    if (bot === selectedBot) {
      const forward = new THREE.Vector3();
      camera.getWorldDirection(forward);
      forward.y = 0;
      forward.normalize();
      const right = new THREE.Vector3(-forward.z, 0, forward.x);

      let ix = (keys["d"] ? 1 : 0) - (keys["q"] || keys["a"] ? 1 : 0);
      let iz = ((keys["z"] || keys["w"]) ? 1 : 0) - (keys["s"] ? 1 : 0);
      const inputLen = Math.hypot(ix, iz);
      if (inputLen > 1) { ix /= inputLen; iz /= inputLen; }

      const moveDir = new THREE.Vector3().addScaledVector(forward, iz).addScaledVector(right, ix);
      const hasInput = moveDir.lengthSq() > 0.001;

      const maxSpeed = 6 * botSpeedMultiplier;
      const targetVX = hasInput ? moveDir.x * maxSpeed : 0;
      const targetVZ = hasInput ? moveDir.z * maxSpeed : 0;
      ud.velocityX += THREE.MathUtils.clamp(targetVX - ud.velocityX, -12 * dt, 12 * dt);
      ud.velocityZ += THREE.MathUtils.clamp(targetVZ - ud.velocityZ, -12 * dt, 12 * dt);

      bot.position.x += ud.velocityX * dt;
      bot.position.z += ud.velocityZ * dt;

      // Rotation vers la direction
      const speed = Math.hypot(ud.velocityX, ud.velocityZ);
      if (speed > 0.1) ud.targetRotationY = Math.atan2(ud.velocityX, ud.velocityZ);
      const rotDiff = Math.atan2(Math.sin(ud.targetRotationY - bot.rotation.y), Math.cos(ud.targetRotationY - bot.rotation.y));
      bot.rotation.y += THREE.MathUtils.clamp(rotDiff, -6 * dt, 6 * dt);

      // Saut
      if ((keys[" "] || keys["space"]) && !ud.isJumping && !botFlyMode) {
        ud.isJumping = true;
        ud.velocityY = 0.8 * botJumpMultiplier;
      }

      // Caméra 3e personne (suit le bot)
      const dist = 8, height = 5;
      camera.position.lerp(new THREE.Vector3(
        bot.position.x - Math.sin(bot.rotation.y) * dist,
        bot.position.y + height,
        bot.position.z - Math.cos(bot.rotation.y) * dist
      ), 0.1);
      camera.lookAt(bot.position.x, bot.position.y + 2, bot.position.z);
      controls.target.copy(bot.position);
    } else {
      // Marche aléatoire pour les autres bots
      ud.walkPhase += 0.02 * botSpeedMultiplier;
      bot.position.x += Math.sin(ud.walkPhase) * 0.02;
      bot.position.z += Math.cos(ud.walkPhase) * 0.02;
    }

    // Animation membres
    const swing = Math.sin(time * 0.003 + ud.walkPhase * 10) * 0.3;
    if (ud.leftArm) ud.leftArm.rotation.x = swing;
    if (ud.rightArm) ud.rightArm.rotation.x = -swing;
    if (ud.leftLeg) ud.leftLeg.rotation.x = -swing;
    if (ud.rightLeg) ud.rightLeg.rotation.x = swing;
  });

  if (!selectedBot) controls.update();
  renderer.render(scene, camera);
}

// ===== LANCEMENT =====
document.addEventListener("DOMContentLoaded", () => {
  setTimeout(initThreeJS, 200);
});