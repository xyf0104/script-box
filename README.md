# 无风工具箱 (ScriptBox)

一键部署的 Linux 服务器管理工具箱，支持 Web 管理面板 + 命令行交互式菜单。

## 功能模块

| 序号 | 模块 | 说明 |
|------|------|------|
| 1 | 无风专属 | VPS初始化、S-UI、Hysteria2、SubHub、MoonTV 等 |
| 2 | 系统信息查询 | CPU/内存/硬盘/IP/DNS 一览 |
| 3 | 系统更新 | 自动检测包管理器并更新 |
| 4 | 系统清理 | 清理缓存、日志、无用包 |
| 5 | 基础工具 | curl/wget/htop/btop/tmux/git 等 17 个工具 |
| 6 | BBR管理 | 一键开启/关闭 BBR 加速 |
| 7 | Docker管理 | 安装/卸载/容器管理/镜像清理 |
| 8 | WARP管理 | CloudFlare WARP / fscarmen 脚本 |
| 9 | 测试脚本合集 | 流媒体解锁/IP质量/三网测速/回程路由等 16 项 |
| 10 | 系统工具 | 40+ 项系统管理功能 |
| 11 | 应用市场 | 宝塔/1Panel/哪吒监控/青龙面板等 |
| 12 | AI工具 | Ollama/OpenWebUI/LobeChat 等 |
| 13 | 网络安全 | 防火墙/SSH/Fail2Ban/ACME证书 |
| 14 | 影视媒体 | MoonTV/Jellyfin/Emby/Plex/MoviePilot 等 |

## 一键安装

```bash
bash <(curl -sL https://raw.githubusercontent.com/xyf0104/script-box/main/install.sh)
```

## 使用方法

安装完成后，配置域名反代到 3080 端口，然后：

```bash
# 命令行运行工具箱
bash <(curl -sL 你的域名)

# Web 管理面板
浏览器访问 http://你的域名
```

## 目录结构

```
script-box/
├── server.js              # Node.js 服务入口
├── Dockerfile             # Docker 构建文件
├── docker-compose.yml     # Docker Compose 配置
├── install.sh             # 一键安装脚本
├── package.json           # Node.js 依赖
├── data/
│   └── menu.json          # 菜单配置（JSON）
├── scripts/               # 功能脚本目录
│   ├── linux_info.sh      # 系统信息
│   ├── linux_update.sh    # 系统更新
│   ├── linux_clean.sh     # 系统清理
│   ├── linux_tools.sh     # 基础工具
│   ├── linux_bbr.sh       # BBR管理
│   ├── linux_docker.sh    # Docker管理
│   ├── linux_warp.sh      # WARP管理
│   ├── linux_test.sh      # 测试脚本合集
│   ├── linux_systemtools.sh # 系统工具
│   ├── linux_appmarket.sh # 应用市场
│   ├── linux_ai.sh        # AI工具
│   ├── linux_security.sh  # 网络安全
│   └── linux_media.sh     # 影视媒体
├── src/
│   ├── generator/
│   │   └── shellGenerator.js  # 核心：菜单→Shell脚本生成器
│   ├── routes/
│   │   ├── api.js         # 管理 API
│   │   └── script.js      # 脚本输出路由
│   └── services/
│       └── menuManager.js # 菜单数据管理
└── public/                # Web 管理面板前端
    ├── index.html
    ├── style.css
    └── app.js
```

## 环境要求

- Linux (Debian/Ubuntu/CentOS)
- Docker & Docker Compose
- 域名（可选，用于反代）

## 许可

Private - by 无风
