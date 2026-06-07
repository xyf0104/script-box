/**
 * ScriptBox - 脚本工具箱管理平台
 */

const express = require('express');
const path = require('path');
const cookieParser = require('cookie-parser');

const app = express();
const PORT = process.env.PORT || 3080;

// Middleware
app.use(express.json({ limit: '2mb' }));
app.use(express.urlencoded({ extended: true }));
app.use(cookieParser());

// 根路由：curl/wget 返回脚本，浏览器返回管理面板
app.get('/', (req, res, next) => {
  const ua = req.headers['user-agent'] || '';
  if (ua.includes('curl') || ua.includes('wget') || ua.includes('Wget')) {
    const shellGenerator = require('./src/generator/shellGenerator');
    const protocol = req.headers['x-forwarded-proto'] || req.protocol;
    const host = req.headers['x-forwarded-host'] || req.get('host');
    const baseUrl = process.env.BASE_URL || `${protocol}://${host}`;
    const script = shellGenerator.generateMainScript(baseUrl.replace(/\/$/, ''));
    res.setHeader('Content-Type', 'text/plain; charset=utf-8');
    return res.send(script);
  }
  next(); // 浏览器请求交给 static 中间件
});

// Static files (管理面板)
app.use(express.static(path.join(__dirname, 'public')));

// API routes (管理接口)
const apiRouter = require('./src/routes/api');
app.use('/api', apiRouter);

// Script routes (公开，生成 shell 脚本)
const scriptRouter = require('./src/routes/script');
app.use('/script', scriptRouter);

// 功能脚本 (直接 shell 脚本文件)
app.get('/scripts/:name', (req, res) => {
  const fs = require('fs');
  const scriptPath = path.join(__dirname, 'scripts', req.params.name);
  if (fs.existsSync(scriptPath) && req.params.name.endsWith('.sh')) {
    res.setHeader('Content-Type', 'text/plain; charset=utf-8');
    res.sendFile(scriptPath);
  } else {
    res.status(404).send('Script not found');
  }
});

// 健康检查
app.get('/health', (req, res) => {
  res.json({ status: 'ok', uptime: process.uptime() });
});

// SPA fallback - 管理面板
app.get('*', (req, res) => {
  // 如果请求的是脚本（通过 curl），返回主脚本
  const ua = req.headers['user-agent'] || '';
  if (ua.includes('curl') || ua.includes('wget')) {
    const scriptRouter = require('./src/routes/script');
    const shellGenerator = require('./src/generator/shellGenerator');
    const protocol = req.headers['x-forwarded-proto'] || req.protocol;
    const host = req.headers['x-forwarded-host'] || req.get('host');
    const baseUrl = process.env.BASE_URL || `${protocol}://${host}`;
    const script = shellGenerator.generateMainScript(baseUrl.replace(/\/$/, ''));
    res.setHeader('Content-Type', 'text/plain; charset=utf-8');
    return res.send(script);
  }
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// Start
app.listen(PORT, '0.0.0.0', () => {
  console.log('');
  console.log('  ╔══════════════════════════════════════════╗');
  console.log('  ║        📦 ScriptBox is running!          ║');
  console.log('  ╠══════════════════════════════════════════╣');
  console.log(`  ║  管理面板:  http://localhost:${PORT}        ║`);
  console.log(`  ║  脚本入口:  http://localhost:${PORT}/script  ║`);
  console.log('  ╚══════════════════════════════════════════╝');
  console.log('');
});
