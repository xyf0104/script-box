/**
 * ScriptBox - 管理面板前端逻辑
 */

// ===== State =====
let menuData = { config: {}, items: [] };
let editingItem = null;
let editingParent = null; // null = root, or parent item reference
let isNewItem = false;
const expandedItems = new Set(); // track which submenus are expanded
let dragState = { dragging: null, parentId: null }; // 拖拽状态

// ===== Init =====
document.addEventListener('DOMContentLoaded', () => {
  checkAuth();
  document.getElementById('loginForm').addEventListener('submit', handleLogin);
});

// ===== Auth =====
async function checkAuth() {
  try {
    const res = await fetch('/api/auth/check');
    const data = await res.json();
    if (data.authenticated) {
      showAdmin();
    } else {
      showLogin();
    }
  } catch {
    showLogin();
  }
}

function showLogin() {
  document.getElementById('loginPage').style.display = 'flex';
  document.getElementById('adminPanel').style.display = 'none';
}

function showAdmin() {
  document.getElementById('loginPage').style.display = 'none';
  document.getElementById('adminPanel').style.display = 'block';
  loadMenu();
}

async function handleLogin(e) {
  e.preventDefault();
  const username = document.getElementById('loginUser').value;
  const password = document.getElementById('loginPass').value;
  const errorEl = document.getElementById('loginError');

  try {
    const res = await fetch('/api/login', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ username, password })
    });
    const data = await res.json();
    if (data.success) {
      showAdmin();
    } else {
      errorEl.textContent = data.error || '登录失败';
      errorEl.style.display = 'block';
    }
  } catch {
    errorEl.textContent = '网络错误';
    errorEl.style.display = 'block';
  }
}

async function logout() {
  await fetch('/api/logout', { method: 'POST' });
  showLogin();
}

// ===== Menu Data =====
async function loadMenu() {
  try {
    const res = await fetch('/api/menu');
    if (res.status === 401) { showLogin(); return; }
    menuData = await res.json();
    renderMenuTree();
    refreshPreview();
  } catch (err) {
    console.error('加载菜单失败:', err);
  }
}

async function saveMenu() {
  try {
    const res = await fetch('/api/menu', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ items: menuData.items })
    });
    const data = await res.json();
    if (data.success) {
      const status = document.getElementById('saveStatus');
      status.textContent = '✓ 已保存';
      status.classList.add('show');
      setTimeout(() => status.classList.remove('show'), 2000);
      refreshPreview();
    }
  } catch (err) {
    alert('保存失败: ' + err.message);
  }
}

// ===== Render Menu Tree =====
function renderMenuTree() {
  const container = document.getElementById('menuTree');

  if (!menuData.items || menuData.items.length === 0) {
    container.innerHTML = `
      <div class="tree-empty">
        <p>📭 还没有菜单项</p>
        <button class="btn btn-primary btn-sm" onclick="addRootItem()">+ 添加第一个菜单项</button>
      </div>
    `;
    updateStats();
    return;
  }

  container.innerHTML = renderItems(menuData.items, null);
  updateStats();
}

function updateStats() {
  const el = document.getElementById('menuStats');
  if (!el) return;
  let total = 0;
  (menuData.items || []).forEach(i => {
    if (i.type === 'submenu' && i.children) total += i.children.length;
    else total++;
  });
  el.textContent = `${menuData.items?.length || 0} 分类 · ${total} 脚本`;
}

function toggleSubmenu(itemId, event) {
  // Don't toggle if clicking action buttons
  if (event && event.target.closest('.item-actions')) return;
  if (expandedItems.has(itemId)) {
    expandedItems.delete(itemId);
  } else {
    expandedItems.add(itemId);
  }
  renderMenuTree();
}

function renderItems(items, parentId) {
  let html = '';
  items.forEach((item, index) => {
    const isSubmenu = item.type === 'submenu';
    const isExpanded = expandedItems.has(item.id);
    const childCount = isSubmenu && item.children ? item.children.length : 0;
    const chevron = isSubmenu ? `<span class="item-chevron ${isExpanded ? 'expanded' : ''}">▶</span>` : '';
    const icon = isSubmenu ? (isExpanded ? '📂' : '📁') : '📜';
    const typeLabel = isSubmenu ? `${childCount}项` : '脚本';
    // 子菜单点击展开/收起，脚本项点击无操作
    const clickHandler = isSubmenu ? `onclick="toggleSubmenu('${item.id}', event)"` : '';

    html += `
      <div class="tree-item" data-id="${item.id}" data-parent="${parentId}" draggable="true"
           ondragstart="handleDragStart(event, '${item.id}', '${parentId}')"
           ondragover="handleDragOver(event)" ondrop="handleDrop(event, '${item.id}', '${parentId}')">
        <div class="tree-item-row ${isSubmenu ? 'is-submenu' : 'is-script'} ${isExpanded ? 'is-expanded' : ''}" ${clickHandler}>
          <span class="drag-handle" title="拖拽排序">⠿</span>
          ${chevron}
          <span class="item-number">${index + 1}</span>
          <span class="item-icon">${icon}</span>
          <span class="item-name">${escapeHtml(item.name)}</span>
          <span class="item-type">${typeLabel}</span>
          <div class="item-actions">
            <button class="btn-icon" onclick="event.stopPropagation();editItem('${item.id}')" title="编辑">✏️</button>
            <button class="btn-icon danger" onclick="event.stopPropagation();deleteItem('${item.id}', '${parentId}')" title="删除">🗑</button>
          </div>
        </div>
        ${isSubmenu ? `
          <div class="tree-children ${isExpanded ? 'expanded' : 'collapsed'}">
            ${item.children && item.children.length > 0 ? renderItems(item.children, item.id) : ''}
            <button class="add-child-btn" onclick="addChildItem('${item.id}')">+ 添加子项</button>
          </div>
        ` : ''}
      </div>
    `;
  });
  return html;
}

// ===== 拖拽排序 =====
function handleDragStart(e, itemId, parentId) {
  dragState.dragging = itemId;
  dragState.parentId = parentId;
  e.dataTransfer.effectAllowed = 'move';
  e.target.closest('.tree-item').classList.add('dragging');
}

function handleDragOver(e) {
  e.preventDefault();
  e.dataTransfer.dropEffect = 'move';
  // 高亮放置目标
  const target = e.target.closest('.tree-item');
  document.querySelectorAll('.tree-item.drag-over').forEach(el => el.classList.remove('drag-over'));
  if (target) target.classList.add('drag-over');
}

function handleDrop(e, targetId, targetParentId) {
  e.preventDefault();
  document.querySelectorAll('.dragging,.drag-over').forEach(el => el.classList.remove('dragging', 'drag-over'));
  if (!dragState.dragging || dragState.dragging === targetId) return;
  // 只允许同层级拖拽（同 parent）
  if (dragState.parentId !== targetParentId) return;

  let items;
  if (targetParentId && targetParentId !== 'null') {
    const parent = findItem(menuData.items, targetParentId);
    items = parent?.children;
  } else {
    items = menuData.items;
  }
  if (!items) return;

  const fromIdx = items.findIndex(i => i.id === dragState.dragging);
  const toIdx = items.findIndex(i => i.id === targetId);
  if (fromIdx < 0 || toIdx < 0) return;

  const [moved] = items.splice(fromIdx, 1);
  items.splice(toIdx, 0, moved);

  dragState.dragging = null;
  renderMenuTree();
  refreshPreview();
}

// ===== Menu Operations =====
function addRootItem() {
  editingItem = null;
  editingParent = null;
  isNewItem = true;
  document.getElementById('editModalTitle').textContent = '添加菜单项';
  document.getElementById('editName').value = '';
  document.getElementById('editType').value = 'script';
  document.getElementById('editUrl').value = '';
  toggleUrlField();
  openEditModal();
}

function addChildItem(parentId) {
  editingItem = null;
  editingParent = parentId;
  isNewItem = true;
  document.getElementById('editModalTitle').textContent = '添加子菜单项';
  document.getElementById('editName').value = '';
  document.getElementById('editType').value = 'script';
  document.getElementById('editUrl').value = '';
  toggleUrlField();
  openEditModal();
}

function editItem(itemId) {
  const item = findItem(menuData.items, itemId);
  if (!item) return;

  editingItem = item;
  editingParent = null;
  isNewItem = false;
  document.getElementById('editModalTitle').textContent = '编辑: ' + item.name;
  document.getElementById('editName').value = item.name;
  document.getElementById('editType').value = item.type;
  document.getElementById('editUrl').value = item.url || '';
  toggleUrlField();
  // 如果是脚本类型，加载脚本预览
  loadScriptPreview(item);
  openEditModal();
}

/** 在编辑弹窗中加载脚本预览 */
function loadScriptPreview(item) {
  const previewEl = document.getElementById('editScriptPreview');
  if (!previewEl) return;
  if (item.type !== 'script' || !item.url) {
    previewEl.style.display = 'none';
    return;
  }
  previewEl.style.display = 'block';
  const contentEl = document.getElementById('editScriptContent');
  contentEl.textContent = '加载中...';
  if (item.url.startsWith('http://') || item.url.startsWith('https://')) {
    fetch(item.url).then(r => r.ok ? r.text() : Promise.reject('HTTP ' + r.status))
      .then(text => { contentEl.textContent = text.substring(0, 3000) + (text.length > 3000 ? '\n\n... (截断)' : ''); })
      .catch(() => { contentEl.textContent = '无法加载 (可能跨域限制)'; });
  } else {
    contentEl.textContent = '命令: ' + item.url;
  }
}

function confirmEdit() {
  const name = document.getElementById('editName').value.trim();
  const type = document.getElementById('editType').value;
  const url = document.getElementById('editUrl').value.trim();

  if (!name) {
    alert('请输入名称');
    return;
  }

  if (isNewItem) {
    const newItem = {
      id: 'item_' + Date.now() + '_' + Math.random().toString(36).substr(2, 4),
      name,
      type,
    };

    if (type === 'script') {
      newItem.url = url;
    } else {
      newItem.children = [];
    }

    if (editingParent) {
      const parent = findItem(menuData.items, editingParent);
      if (parent && parent.children) {
        parent.children.push(newItem);
      }
    } else {
      menuData.items.push(newItem);
    }
  } else if (editingItem) {
    editingItem.name = name;
    
    if (editingItem.type !== type) {
      editingItem.type = type;
      if (type === 'submenu') {
        editingItem.children = editingItem.children || [];
        delete editingItem.url;
      } else {
        editingItem.url = url;
        delete editingItem.children;
      }
    } else if (type === 'script') {
      editingItem.url = url;
    }
  }

  closeEditModal();
  renderMenuTree();
  refreshPreview();
}

function deleteItem(itemId, parentId) {
  if (!confirm('确定要删除这个菜单项吗？')) return;

  if (parentId && parentId !== 'null') {
    const parent = findItem(menuData.items, parentId);
    if (parent && parent.children) {
      parent.children = parent.children.filter(i => i.id !== itemId);
    }
  } else {
    menuData.items = menuData.items.filter(i => i.id !== itemId);
  }

  renderMenuTree();
  refreshPreview();
}

function moveItem(itemId, parentId, direction) {
  let items;
  if (parentId && parentId !== 'null') {
    const parent = findItem(menuData.items, parentId);
    items = parent?.children;
  } else {
    items = menuData.items;
  }

  if (!items) return;

  const index = items.findIndex(i => i.id === itemId);
  if (index < 0) return;

  const newIndex = index + direction;
  if (newIndex < 0 || newIndex >= items.length) return;

  [items[index], items[newIndex]] = [items[newIndex], items[index]];

  renderMenuTree();
  refreshPreview();
}

function findItem(items, id) {
  for (const item of items) {
    if (item.id === id) return item;
    if (item.children) {
      const found = findItem(item.children, id);
      if (found) return found;
    }
  }
  return null;
}

// ===== Config =====
function openConfigModal() {
  const config = menuData.config || {};
  document.getElementById('configTitle').value = config.title || '';
  document.getElementById('configVersion').value = config.version || '';
  document.getElementById('configAscii').value = config.ascii || '';
  document.getElementById('configModal').style.display = 'flex';
}

function closeConfigModal() {
  document.getElementById('configModal').style.display = 'none';
}

async function saveConfig() {
  const config = {
    title: document.getElementById('configTitle').value.trim(),
    version: document.getElementById('configVersion').value.trim(),
    ascii: document.getElementById('configAscii').value,
  };

  try {
    const res = await fetch('/api/config', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(config)
    });
    const data = await res.json();
    if (data.success) {
      menuData.config = data.config;
      closeConfigModal();
      refreshPreview();
    }
  } catch (err) {
    alert('保存失败: ' + err.message);
  }
}

// ===== Terminal Preview =====
function refreshPreview() {
  const terminal = document.getElementById('terminalPreview');
  const config = menuData.config || {};
  const items = menuData.items || [];

  const title = config.title || '无风工具箱';
  const version = config.version || '1.2.1';
  const ascii = config.ascii || '';

  let lines = [];
  lines.push('');

  // ASCII Art
  if (ascii) {
    ascii.split('\n').forEach(line => {
      lines.push(`<span class="t-cyan">${escapeHtml(line)}</span>`);
    });
  }

  lines.push(`<span class="t-cyan">${escapeHtml(title)}</span>  <span class="t-dim">v${escapeHtml(version)}</span>`);
  lines.push(`<span class="t-dim">  命令行输入 wf 可快速启动脚本</span>`);
  lines.push(`<span class="t-line">────────────────────────────────</span>`);

  // Menu items
  items.forEach((item, index) => {
    const num = String(index + 1).padStart(2, ' ');
    const arrow = item.type === 'submenu' ? `  <span class="t-yellow">→</span>` : '';
    const n = item.type === 'submenu'
      ? `<span class="t-green">${escapeHtml(item.name)}</span>`
      : escapeHtml(item.name);
    lines.push(`  <span class="t-num">${num}.</span>   ${n}${arrow}`);
  });

  lines.push(`<span class="t-line">────────────────────────────────</span>`);
  lines.push(`  <span class="t-num">00.</span>   脚本更新`);
  lines.push(`<span class="t-line">────────────────────────────────</span>`);
  lines.push(`   <span class="t-num">0.</span>   退出脚本`);
  lines.push(`<span class="t-line">────────────────────────────────</span>`);
  lines.push(`  请输入你的选择: <span class="t-cursor">█</span>`);
  lines.push('');

  terminal.innerHTML = lines.join('\n');
}

// ===== Modals =====
function openEditModal() {
  document.getElementById('editModal').style.display = 'flex';
  document.getElementById('editName').focus();
}

function closeEditModal() {
  document.getElementById('editModal').style.display = 'none';
}

function toggleUrlField() {
  const type = document.getElementById('editType').value;
  document.getElementById('urlGroup').style.display = type === 'script' ? 'block' : 'none';
}

// ===== Utils =====
function escapeHtml(str) {
  const div = document.createElement('div');
  div.textContent = str;
  return div.innerHTML;
}

function copyInstallCmd() {
  const text = 'bash <(curl -sL xiass.com)';
  navigator.clipboard.writeText(text).then(() => {
    const btn = document.querySelector('.btn-copy');
    const orig = btn.innerHTML;
    btn.innerHTML = '✓ 已复制';
    btn.style.background = '#22c55e';
    setTimeout(() => { btn.innerHTML = orig; btn.style.background = ''; }, 1500);
  });
}

// ===== View Script =====
function viewScript(itemId, event) {
  if (event && event.target.closest('.item-actions')) return;
  const item = findItem(menuData.items, itemId);
  if (!item) return;

  const modal = document.getElementById('viewModal');
  document.getElementById('viewModalTitle').textContent = item.name;
  const urlEl = document.getElementById('viewUrl');
  const contentEl = document.getElementById('viewContent');

  urlEl.textContent = item.url || '未配置脚本URL';
  contentEl.textContent = '加载中...';
  modal.style.display = 'flex';

  // Try to fetch script content
  if (item.url && (item.url.startsWith('http://') || item.url.startsWith('https://'))) {
    fetch(item.url).then(r => r.ok ? r.text() : Promise.reject('HTTP ' + r.status))
      .then(text => { contentEl.textContent = text.substring(0, 3000) + (text.length > 3000 ? '\n\n... (内容已截断)' : ''); })
      .catch(() => { contentEl.textContent = '无法加载脚本内容 (可能跨域限制)'; });
  } else if (item.url) {
    contentEl.textContent = '命令: ' + item.url;
  } else {
    contentEl.textContent = '未配置脚本';
  }
}

function closeViewModal() {
  document.getElementById('viewModal').style.display = 'none';
}

function copyScriptUrl() {
  const url = document.getElementById('viewUrl').textContent;
  navigator.clipboard.writeText(url).then(() => {
    const btn = document.getElementById('copyUrlBtn');
    const orig = btn.textContent;
    btn.textContent = '✓ 已复制';
    setTimeout(() => { btn.textContent = orig; }, 1500);
  });
}
