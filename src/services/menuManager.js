/**
 * Menu Manager - 菜单数据管理服务
 */

const fs = require('fs');
const path = require('path');

const DATA_FILE = path.join(__dirname, '../../data/menu.json');

// 确保数据目录存在
function ensureDataDir() {
  const dir = path.dirname(DATA_FILE);
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
}

// 读取菜单数据
function getMenuData() {
  ensureDataDir();
  if (!fs.existsSync(DATA_FILE)) {
    const defaultData = {
      config: {
        title: '无风工具箱',
        version: '1.0.0',
        ascii: '╦ ╦╦ ╦╔═╗╔═╗╔╗╔╔═╗\n║║║║ ║╠╣ ║╣ ║║║║ ╦\n╚╩╝╚═╝╚  ╚═╝╝╚╝╚═╝'
      },
      items: []
    };
    fs.writeFileSync(DATA_FILE, JSON.stringify(defaultData, null, 2), 'utf8');
    return defaultData;
  }
  const raw = fs.readFileSync(DATA_FILE, 'utf8');
  return JSON.parse(raw);
}

// 保存菜单数据
function saveMenuData(data) {
  ensureDataDir();
  fs.writeFileSync(DATA_FILE, JSON.stringify(data, null, 2), 'utf8');
}

// 获取配置
function getConfig() {
  const data = getMenuData();
  return data.config || {};
}

// 保存配置
function saveConfig(config) {
  const data = getMenuData();
  data.config = { ...data.config, ...config };
  saveMenuData(data);
  return data.config;
}

// 获取菜单项列表
function getItems() {
  const data = getMenuData();
  return data.items || [];
}

// 保存菜单项列表
function saveItems(items) {
  const data = getMenuData();
  data.items = items;
  saveMenuData(data);
  return items;
}

// 递归查找子菜单
function findSubmenu(items, id) {
  for (const item of items) {
    if (item.id === id) return item;
    if (item.children) {
      const found = findSubmenu(item.children, id);
      if (found) return found;
    }
  }
  return null;
}

// 生成唯一ID
function generateId() {
  return 'item_' + Date.now() + '_' + Math.random().toString(36).substr(2, 6);
}

module.exports = {
  getMenuData,
  saveMenuData,
  getConfig,
  saveConfig,
  getItems,
  saveItems,
  findSubmenu,
  generateId
};
