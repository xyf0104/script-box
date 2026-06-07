/**
 * Script Routes - Shell 脚本生成路由（公开，无需认证）
 */

const express = require('express');
const router = express.Router();
const shellGenerator = require('../generator/shellGenerator');

// 获取 baseUrl
function getBaseUrl(req) {
  // 优先使用环境变量配置的域名
  if (process.env.BASE_URL) {
    return process.env.BASE_URL.replace(/\/$/, '');
  }
  const protocol = req.headers['x-forwarded-proto'] || req.protocol;
  const host = req.headers['x-forwarded-host'] || req.get('host');
  return `${protocol}://${host}`;
}

// 主脚本
router.get('/', (req, res) => {
  try {
    const baseUrl = getBaseUrl(req);
    const script = shellGenerator.generateMainScript(baseUrl);
    res.setHeader('Content-Type', 'text/plain; charset=utf-8');
    res.send(script);
  } catch (err) {
    res.status(500).send(`#!/bin/bash\necho "错误: ${err.message}"`);
  }
});

// 子菜单脚本
router.get('/:id', (req, res) => {
  try {
    const baseUrl = getBaseUrl(req);
    const script = shellGenerator.generateSubmenuScript(req.params.id, baseUrl);
    if (!script) {
      res.status(404).send('#!/bin/bash\necho "菜单未找到"');
      return;
    }
    res.setHeader('Content-Type', 'text/plain; charset=utf-8');
    res.send(script);
  } catch (err) {
    res.status(500).send(`#!/bin/bash\necho "错误: ${err.message}"`);
  }
});

module.exports = router;
