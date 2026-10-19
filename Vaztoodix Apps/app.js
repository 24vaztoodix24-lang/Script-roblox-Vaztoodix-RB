// ============================================================
// Vaztoodix Studio v3 - app.js
// UI, catégories (mouvement), thèmes, polices
// ============================================================

const CATEGORIES = {
  home: {
    title: "🏠 Accueil",
    desc: "Bienvenue sur Vaztoodix Studio v3",
    tabs: {
      "Bienvenue": [
        { name: "Vaztoodix Studio v3", desc: "Dev / Mod / Script", icon: "⚡", action: "welcome" },
        { name: "Rejoindre Discord", desc: "Team Vaz Revenge™", icon: "💬", action: "openDiscord" },
        { name: "GitHub", desc: "Code source", icon: "🐙", action: "openGithub" }
      ]
    }
  },
  movement: {
    title: "🏃 Mouvement",
    desc: "Fly, Boost, Téléport et plus (sur bots)",
    tabs: {
      "Déplacements": [
        { name: "Vol (Fly)", desc: "WASD + Espace + Shift", icon: "🕊️", action: "fly" },
        { name: "Speed Boost", desc: "Vitesse x2", icon: "⚡", action: "speed" },
        { name: "Jump Boost", desc: "Saut x2", icon: "🦘", action: "jump" },
        { name: "Téléport (souris)", desc: "Se téléporter au clic", icon: "🎯", action: "teleport" },
        { name: "Noclip", desc: "Traverser les murs", icon: "👻", action: "noclip" },
        { name: "Infini Jump", desc: "Sauter sans cesse", icon: "♾️", action: "infJump" }
      ],
      "Contrôles": [
        { name: "Z : Avancer", desc: "Selon la caméra", icon: "⬆️", action: "info" },
        { name: "Q : Gauche", desc: "Rotation 360°", icon: "⬅️", action: "info" },
        { name: "S : Reculer", desc: "Selon la caméra", icon: "⬇️", action: "info" },
        { name: "D : Droite", desc: "Rotation 360°", icon: "➡️", action: "info" },
        { name: "Espace : Sauter", desc: "Saut du bot", icon: "⤒", action: "info" }
      ]
    }
  },
  themes: {
    title: "🎨 Thèmes & Apparence",
    desc: "Personnalise ton interface",
    tabs: {
      "Thèmes": [
        { name: "Thème : Sombre", desc: "Violet / Noir (défaut)", icon: "🌑", action: "theme", theme: "theme-dark" },
        { name: "Thème : Clair", desc: "Rose pastel", icon: "☀️", action: "theme", theme: "theme-light" },
        { name: "Thème : Cyber", desc: "Bleu néon", icon: "🟢", action: "theme", theme: "theme-cyber" },
        { name: "Thème : Violet", desc: "Pourpre profond", icon: "🟣", action: "theme", theme: "theme-purple" }
      ],
      "Police": [
        { name: "Segoe UI", desc: "Moderne (défaut)", icon: "🔤", action: "font", font: "'Segoe UI', sans-serif" },
        { name: "Arial", desc: "Classique", icon: "🔤", action: "font", font: "Arial, sans-serif" },
        { name: "Courier New", desc: "Monospace", icon: "🔤", action: "font", font: "'Courier New', monospace" },
        { name: "Georgia", desc: "Serif élégant", icon: "🔤", action: "font", font: "Georgia, serif" },
        { name: "Verdana", desc: "Lisible", icon: "🔤", action: "font", font: "Verdana, sans-serif" }
      ]
    }
  },
  editor: {
    title: "📜 Éditeur de code",
    desc: "Écris et teste tes scripts Lua",
    tabs: { "Éditeur": [] }
  },
  credits: {
    title: "ℹ️ Crédits",
    desc: "Équipe et contributeurs",
    tabs: {
      "Équipe": [
        { name: "Vaztoodix", desc: "Développeur principal", icon: "👑" },
        { name: "DeepSeek", desc: "IA assistante", icon: "🤖" },
        { name: "Antonio Vaztoodix", desc: "Designer", icon: "🎨" },
        { name: "Micha", desc: "Contributeur", icon: "⚔️" },
        { name: "Ismaël Daniel", desc: "Contributeur", icon: "🛡️" },
        { name: "Kim Nasir", desc: "Testeur", icon: "🧪" }
      ]
    }
  }
};

const AppState = {
  currentCat: "home",
  currentTab: null,
  searchQuery: "",
  activeTheme: "theme-dark",
  activeFont: "'Segoe UI', sans-serif",
  uiScale: 1,
  activeMovements: {}
};

const $ = (id) => document.getElementById(id);
const dom = {};

document.addEventListener("DOMContentLoaded", () => {
  dom.content = $("content");
  dom.catTitle = $("catTitle");
  dom.catDesc = $("catDesc");
  dom.searchBox = $("searchBox");
  dom.sidebarBtns = document.querySelectorAll(".nav-btn");
  dom.btnClose = $("btnClose");
  dom.panelHeader = document.querySelector(".panel-header");
  init();
});

function init() {
  const savedTheme = localStorage.getItem("vaz_theme") || "theme-dark";
  applyTheme(savedTheme, false);
  const savedFont = localStorage.getItem("vaz_font") || "'Segoe UI', sans-serif";
  applyFont(savedFont, false);
  const savedScale = parseFloat(localStorage.getItem("vaz_scale") || "1");
  applyScale(savedScale, false);

  dom.sidebarBtns.forEach(btn => {
    btn.addEventListener("click", () => showCategory(btn.dataset.cat));
  });
  dom.searchBox.addEventListener("input", (e) => {
    AppState.searchQuery = e.target.value.toLowerCase();
    renderContent();
  });
  dom.btnClose?.addEventListener("click", () => {
    if (confirm("Fermer Vaztoodix Studio ?")) window.close();
  });

  showCategory("home");
}

function showCategory(catName) {
  const cat = CATEGORIES[catName];
  if (!cat) return;
  AppState.currentCat = catName;
  AppState.currentTab = Object.keys(cat.tabs)[0];
  dom.sidebarBtns.forEach(btn => btn.classList.toggle("active", btn.dataset.cat === catName));
  dom.catTitle.textContent = cat.title;
  dom.catDesc.textContent = cat.desc;
  renderTabs();
  renderContent();
}

function renderTabs() {
  document.querySelector(".tabs-container")?.remove();
  const cat = CATEGORIES[AppState.currentCat];
  const tabNames = Object.keys(cat.tabs);
  if (tabNames.length <= 1) return;
  const tabsHTML = `<div class="tabs-container">
    ${tabNames.map(tab => `<button class="tab-btn ${tab === AppState.currentTab ? 'active' : ''}" onclick="selectTab('${tab}')">${tab}</button>`).join("")}
  </div>`;
  dom.panelHeader.insertAdjacentHTML("beforeend", tabsHTML);
  if (!document.getElementById("tabsStyle")) {
    const style = document.createElement("style");
    style.id = "tabsStyle";
    style.textContent = `
      .tabs-container { display: flex; gap: 6px; margin-top: 8px; flex-wrap: wrap; }
      .tab-btn { padding: 4px 12px; border-radius: 6px; font-size: 11px; background: rgba(60,20,45,0.6); color: white; border: none; cursor: pointer; transition: 0.2s; }
      .tab-btn:hover { background: rgba(120,40,70,0.8); }
      .tab-btn.active { background: var(--accent); box-shadow: 0 0 10px var(--accent); }
    `;
    document.head.appendChild(style);
  }
}

function selectTab(tabName) {
  AppState.currentTab = tabName;
  renderTabs();
  renderContent();
}

function renderContent() {
  if (AppState.currentCat === "editor") { renderEditor(); return; }
  const cat = CATEGORIES[AppState.currentCat];
  const modules = cat.tabs[AppState.currentTab] || [];
  let filtered = modules;
  if (AppState.searchQuery) {
    filtered = modules.filter(m =>
      m.name.toLowerCase().includes(AppState.searchQuery) ||
      (m.desc && m.desc.toLowerCase().includes(AppState.searchQuery))
    );
  }
  const html = `
    <div class="cards-grid">
      ${filtered.map(m => {
        const isActive =
          (m.action === "theme" && AppState.activeTheme === m.theme) ||
          (m.action === "font" && AppState.activeFont === m.font) ||
          (m.action === "fly" && AppState.activeMovements.fly) ||
          (m.action === "speed" && AppState.activeMovements.speed) ||
          (m.action === "jump" && AppState.activeMovements.jump) ||
          (m.action === "teleport" && AppState.activeMovements.teleport) ||
          (m.action === "noclip" && AppState.activeMovements.noclip) ||
          (m.action === "infJump" && AppState.activeMovements.infJump);
        return `
          <div class="card ${isActive ? 'active' : ''}" onclick='handleAction("${m.action}", ${JSON.stringify(m).replace(/'/g, "&#39;")})'>
            <div class="card-title">${m.icon || ""} ${m.name}</div>
            <div class="card-desc">${m.desc || ""}</div>
          </div>
        `;
      }).join("")}
    </div>
  `;
  dom.content.innerHTML = html;
}

function handleAction(action, module) {
  switch (action) {
    case "theme": applyTheme(module.theme); renderContent(); break;
    case "font": applyFont(module.font); renderContent(); break;
    case "openDiscord": window.open("https://discord.gg/Scc8Vf4Sz", "_blank"); break;
    case "openGithub": window.open("https://github.com/24vaztoodix24-lang/Script-roblox-Vaztoodix-RB", "_blank"); break;
    case "welcome": showNotification("👋 Bienvenue sur Vaztoodix Studio v3"); break;
    case "fly":
      AppState.activeMovements.fly = !AppState.activeMovements.fly;
      if (typeof toggleBotFly === "function") toggleBotFly(AppState.activeMovements.fly);
      showNotification(`Fly : ${AppState.activeMovements.fly ? "ON" : "OFF"}`);
      renderContent();
      break;
    case "speed":
      AppState.activeMovements.speed = !AppState.activeMovements.speed;
      if (typeof setBotSpeed === "function") setBotSpeed(AppState.activeMovements.speed ? 2 : 1);
      showNotification(`Speed : ${AppState.activeMovements.speed ? "ON" : "OFF"}`);
      renderContent();
      break;
    case "jump":
      AppState.activeMovements.jump = !AppState.activeMovements.jump;
      if (typeof setBotJump === "function") setBotJump(AppState.activeMovements.jump ? 2 : 1);
      showNotification(`Jump : ${AppState.activeMovements.jump ? "ON" : "OFF"}`);
      renderContent();
      break;
    case "teleport":
      AppState.activeMovements.teleport = !AppState.activeMovements.teleport;
      showNotification(`Téléport : ${AppState.activeMovements.teleport ? "ON" : "OFF"}`);
      renderContent();
      break;
    case "noclip":
      AppState.activeMovements.noclip = !AppState.activeMovements.noclip;
      if (typeof setBotNoclip === "function") setBotNoclip(AppState.activeMovements.noclip);
      showNotification(`Noclip : ${AppState.activeMovements.noclip ? "ON" : "OFF"}`);
      renderContent();
      break;
    case "infJump":
      AppState.activeMovements.infJump = !AppState.activeMovements.infJump;
      showNotification(`Infini Jump : ${AppState.activeMovements.infJump ? "ON" : "OFF"}`);
      renderContent();
      break;
    case "info":
      showNotification("Utilise ZQSD pour bouger, Espace pour sauter");
      break;
    default:
      console.log("[Vaztoodix] Action:", action, module);
  }
}

function applyTheme(theme, save = true) {
  document.body.className = theme;
  AppState.activeTheme = theme;
  if (save) {
    localStorage.setItem("vaz_theme", theme);
    showNotification(`Thème appliqué : ${theme.replace("theme-", "")}`);
  }
}

function applyFont(font, save = true) {
  document.documentElement.style.setProperty("--font-family", font);
  AppState.activeFont = font;
  if (save) {
    localStorage.setItem("vaz_font", font);
    showNotification(`Police : ${font.split(",")[0].replace(/'/g, "")}`);
  }
}

function applyScale(scale, save = true) {
  AppState.uiScale = scale;
  document.documentElement.style.setProperty("--font-size-base", (14 * scale) + "px");
  document.body.style.zoom = scale;
  if (save) localStorage.setItem("vaz_scale", scale.toString());
}

function renderEditor() {
  dom.content.innerHTML = `
    <div class="editor-wrapper">
      <div class="code-editor-wrapper">
        <div class="line-numbers" id="lineNumbers"></div>
        <textarea id="codeTextarea" spellcheck="false" placeholder="-- Écris ton script Lua ici..."></textarea>
      </div>
      <div class="autocomplete-box" id="autocompleteBox" style="display:none;"></div>
      <div class="editor-toolbar">
        <button onclick="runScript()">▶️ Exécuter</button>
        <button onclick="saveScript()">💾 Sauvegarder</button>
        <button onclick="clearEditor()">🗑️ Effacer</button>
      </div>
    </div>
  `;
  if (typeof setupEditor === "function") setupEditor();
}

function showNotification(message, type = "info") {
  const notif = document.createElement("div");
  notif.className = "glass";
  notif.style.cssText = `
    position: fixed; top: 70px; right: 20px;
    padding: 12px 20px; border-radius: 10px;
    background: ${type === "error" ? "rgba(255,80,100,0.9)" : "rgba(180,30,80,0.9)"};
    color: white; font-size: 13px; font-weight: bold;
    z-index: 1000; animation: slideIn 0.3s ease;
    box-shadow: 0 6px 20px rgba(0,0,0,0.4);
  `;
  notif.textContent = message;
  document.body.appendChild(notif);
  setTimeout(() => notif.remove(), 2500);
}

function addUIScaleSlider() {
  const sidebar = document.querySelector(".sidebar");
  if (!sidebar || document.getElementById("uiScaleContainer")) return;
  const container = document.createElement("div");
  container.id = "uiScaleContainer";
  container.style.cssText = "margin-top:auto;padding:8px 4px;display:flex;flex-direction:column;align-items:center;gap:4px;";
  container.innerHTML = `
    <input type="range" id="uiScaleSlider" min="70" max="130" value="${AppState.uiScale * 100}"
           style="width:36px;writing-mode:vertical-lr;direction:rtl;height:80px;accent-color:var(--accent);">
    <span style="font-size:9px;color:var(--text-secondary);">${Math.round(AppState.uiScale * 100)}%</span>
  `;
  sidebar.appendChild(container);
  const slider = document.getElementById("uiScaleSlider");
  slider.addEventListener("input", (e) => {
    const scale = parseInt(e.target.value) / 100;
    applyScale(scale, false);
    container.querySelector("span").textContent = e.target.value + "%";
  });
}
setTimeout(addUIScaleSlider, 100);