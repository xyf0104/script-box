/**
 * API Routes - 管理面板 API
 */

const express = require('express');
const router = express.Router();
const menuManager = require('../services/menuManager');

// 认证中间件
function authMiddleware(req, res, next) {
  if (req.cookies && req.cookies.sb_auth === 'authenticated') {
    return next();
  }
  res.status(401).json({ error: '未登录' });
}

// 登录
router.post('/login', (req, res) => {
  const { username, password } = req.body;
  const validUser = process.env.USERNAME || 'admin';
  const validPass = process.env.PASSWORD || 'admin123';

  if (username === validUser && password === validPass) {
    res.cookie('sb_auth', 'authenticated', {
      httpOnly: true,
      maxAge: 7 * 24 * 60 * 60 * 1000, // 7天
      sameSite: 'lax'
    });
    res.json({ success: true });
  } else {
    res.status(401).json({ error: '用户名或密码错误' });
  }
});

// 登出
router.post('/logout', (req, res) => {
  res.clearCookie('sb_auth');
  res.json({ success: true });
});

// 检查登录状态
router.get('/auth/check', (req, res) => {
  if (req.cookies && req.cookies.sb_auth === 'authenticated') {
    res.json({ authenticated: true });
  } else {
    res.json({ authenticated: false });
  }
});

// ===== 以下需要认证 =====

// 获取完整菜单数据
router.get('/menu', authMiddleware, (req, res) => {
  try {
    const data = menuManager.getMenuData();
    res.json(data);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// 保存完整菜单数据
router.post('/menu', authMiddleware, (req, res) => {
  try {
    const { items } = req.body;
    if (!Array.isArray(items)) {
      return res.status(400).json({ error: 'items 必须是数组' });
    }
    menuManager.saveItems(items);
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// 获取配置
router.get('/config', authMiddleware, (req, res) => {
  try {
    const config = menuManager.getConfig();
    res.json(config);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// 保存配置
router.post('/config', authMiddleware, (req, res) => {
  try {
    const config = menuManager.saveConfig(req.body);
    res.json({ success: true, config });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// 生成新 ID
router.get('/generate-id', authMiddleware, (req, res) => {
  res.json({ id: menuManager.generateId() });
});

module.exports = router;
