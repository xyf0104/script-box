#!/bin/bash
# 无风工具箱 - 无风专属

CYAN='\033[0;36m'; GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; NC='\033[0m'; BOLD='\033[1m'

# ==================== 检测函数 ====================
is_sui()      { systemctl is-active s-ui &>/dev/null || [ -d /usr/local/s-ui ]; }
is_bridge()   { systemctl is-active sui-bridge &>/dev/null || [ -f /etc/systemd/system/sui-bridge.service ]; }
is_hy2()      { command -v hysteria &>/dev/null || [ -f /usr/local/bin/hysteria ]; }
is_subhub()   { [ -d /opt/subhub ]; }
is_acme()     { [ -d ~/.acme.sh ]; }
is_moontv()   { docker ps -a --format '{{.Names}}' 2>/dev/null | grep -qi 'moontv\|moon-tv'; }
is_monitor()  { [ -d /opt/ai-credits-monitor ]; }
is_npm()      { docker ps -a --format '{{.Names}}' 2>/dev/null | grep -q '^npm'; }
is_rxe()      { [ -f /usr/local/bin/ranxiaoer ] || [ -d /opt/ranxiaoer ] || systemctl is-active ranxiaoer &>/dev/null; }

# 状态标签
sl() { if $1; then echo -e "${GREEN}✅${NC}"; else echo -e "${RED}❌${NC}"; fi; }

# 下载到本地再执行
run_remote() {
  local tmp="/tmp/wf_$$.sh"
  curl -sL "$1" -o "$tmp" 2>/dev/null
  if [ -s "$tmp" ]; then bash "$tmp"; else echo -e "${RED}❌ 脚本下载失败${NC}"; fi
  rm -f "$tmp" 2>/dev/null
}

# ==================== 卸载函数（安全清理） ====================

uninstall_sui() {
  systemctl stop s-ui 2>/dev/null; systemctl disable s-ui 2>/dev/null
  rm -f /etc/systemd/system/s-ui.service; systemctl daemon-reload 2>/dev/null
  rm -rf /usr/local/s-ui
  # 清理可能存在的 Docker 容器（不删除 Docker 引擎本身）
  docker stop s-ui 2>/dev/null; docker rm s-ui 2>/dev/null
  echo "已清理: systemd 服务、/usr/local/s-ui、Docker 容器(如有)"
}

uninstall_bridge() {
  systemctl stop sui-bridge 2>/dev/null; systemctl disable sui-bridge 2>/dev/null
  rm -f /etc/systemd/system/sui-bridge.service; systemctl daemon-reload 2>/dev/null
  rm -rf /opt/sui-bridge /usr/local/bin/sui-bridge
  echo "已清理: systemd 服务、程序文件"
}

uninstall_hy2() {
  # 优先使用官方卸载脚本
  local tmp="/tmp/hy2_rm_$$.sh"
  curl -fsSL https://get.hy2.sh/ -o "$tmp" 2>/dev/null && bash "$tmp" --remove 2>/dev/null
  rm -f "$tmp" 2>/dev/null
  # 补充清理
  systemctl stop hysteria-server 2>/dev/null; systemctl disable hysteria-server 2>/dev/null
  rm -f /etc/systemd/system/hysteria-server.service /etc/systemd/system/hysteria-server@*.service
  systemctl daemon-reload 2>/dev/null
  rm -f /usr/local/bin/hysteria
  rm -rf /etc/hysteria
  echo "已清理: 二进制、配置 /etc/hysteria、systemd 服务"
}

uninstall_subhub() {
  if [ -d /opt/subhub ]; then
    cd /opt/subhub && docker compose down --rmi local 2>/dev/null
  fi
  rm -rf /opt/subhub
  echo "已清理: Docker Compose 服务、/opt/subhub"
}

uninstall_acme() {
  ~/.acme.sh/acme.sh --uninstall 2>/dev/null
  rm -rf ~/.acme.sh
  echo "已清理: acme.sh（已签发的证书文件不受影响）"
}

uninstall_moontv() {
  # 查找所有 moontv 相关容器
  for c in $(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -i 'moontv\|moon-tv'); do
    docker stop "$c" 2>/dev/null; docker rm "$c" 2>/dev/null
  done
  docker images --format '{{.Repository}}:{{.Tag}}' | grep -i moon | xargs -r docker rmi 2>/dev/null
  rm -rf /home/docker/moontv /opt/moontv /opt/MoonTV
  echo "已清理: Docker 容器、镜像、数据目录"
}

uninstall_monitor() {
  # 尝试多种服务名
  for svc in ai-credits-monitor ai-credits ai_credits_monitor; do
    systemctl stop "$svc" 2>/dev/null; systemctl disable "$svc" 2>/dev/null
    rm -f "/etc/systemd/system/${svc}.service"
  done
  systemctl daemon-reload 2>/dev/null
  rm -rf /opt/ai-credits-monitor
  echo "已清理: systemd 服务、/opt/ai-credits-monitor"
}

uninstall_npm() {
  # 安全检查：确认没有其他服务依赖 NPM 反代
  echo -e "${YELLOW}注意: 卸载 NPM 后，所有通过它反代的服务将无法通过域名访问${NC}"
  # 同时检查两种可能的容器名
  for n in npm npm-app; do
    docker stop "$n" 2>/dev/null; docker rm "$n" 2>/dev/null
  done
  docker rmi jc21/nginx-proxy-manager:latest 2>/dev/null
  rm -rf /home/docker/npm
  echo "已清理: Docker 容器、镜像、/home/docker/npm"
}

uninstall_rxe() {
  systemctl stop ranxiaoer 2>/dev/null; systemctl disable ranxiaoer 2>/dev/null
  rm -f /etc/systemd/system/ranxiaoer.service; systemctl daemon-reload 2>/dev/null
  rm -f /usr/local/bin/ranxiaoer
  rm -rf /opt/ranxiaoer
  echo "已清理: 程序文件、系统服务"
}

# ==================== 通用管理界面 ====================
# 参数: $1=名称 $2=描述 $3=检测函数 $4=安装命令 $5=卸载函数 $6=重启命令
manage() {
  local name=$1 desc=$2 check=$3 install=$4 uninst=$5 restart=$6
  clear
  echo -e "${CYAN}${BOLD}${name}${NC}"
  echo "$desc"
  echo "------------------------"

  if $check; then
    echo -e "状态: ${GREEN}已安装${NC}"
    echo ""
    echo "1. 更新    2. 卸载    3. 重启    0. 返回"
    read -e -p "选择: " c < /dev/tty
    case "$c" in
      1) echo -e "${YELLOW}⏳ 正在更新 ${name}...${NC}"
         echo "------------------------"
         eval "$install"
         echo "------------------------"
         echo -e "${GREEN}✅ 更新完成${NC}" ;;
      2) echo ""
         echo -e "${RED}⚠️  确认卸载 ${name}？所有相关配置和数据将被删除！${NC}"
         read -e -p "输入 y 确认: " cf < /dev/tty
         if [ "$cf" = "y" ] || [ "$cf" = "Y" ]; then
           echo "------------------------"
           $uninst
           echo "------------------------"
           echo -e "${GREEN}✅ ${name} 已完全卸载${NC}"
         else
           echo "已取消"
         fi ;;
      3) if [ -n "$restart" ]; then
           eval "$restart"
           echo -e "${GREEN}✅ ${name} 已重启${NC}"
         else
           echo "该服务不支持重启"
         fi ;;
    esac
  else
    echo -e "状态: ${RED}未安装${NC}"
    echo ""
    echo "1. 安装    0. 返回"
    read -e -p "选择: " c < /dev/tty
    if [ "$c" = "1" ]; then
      echo -e "${YELLOW}⏳ 正在安装 ${name}...${NC}"
      echo "------------------------"
      eval "$install"
      echo "------------------------"
      echo -e "${GREEN}✅ 安装完成${NC}"
    fi
  fi
}

# ==================== 主菜单 ====================
while true; do
  clear
  echo -e "${CYAN}${BOLD}无风工具箱 > 无风专属${NC}"
  echo "------------------------"
  printf "   1.  VPS一键初始化                           %b\n" "[工具]"
  printf "   2.  S-UI 面板                               %b\n" "$(sl is_sui)"
  printf "   3.  SUI-Bridge 订阅桥接                     %b\n" "$(sl is_bridge)"
  printf "   4.  Hysteria2 代理                          %b\n" "$(sl is_hy2)"
  printf "   5.  SubHub 订阅管理                         %b\n" "$(sl is_subhub)"
  printf "   6.  SSL证书管理(acme)                       %b\n" "$(sl is_acme)"
  printf "   7.  MoonTV影视                              %b\n" "$(sl is_moontv)"
  printf "   8.  AI点数监控                              %b\n" "$(sl is_monitor)"
  printf "   9.  NPM反代                                %b\n" "$(sl is_npm)"
  printf "  10.  然小二库存系统                           [安装脚本]\n"
  echo "------------------------"
  echo "   0.  返回主菜单"
  echo "------------------------"
  read -e -p "请输入你的选择: " choice < /dev/tty

  case "$choice" in
    1)
      clear
      echo -e "${CYAN}${BOLD}VPS一键初始化${NC}"
      echo "静态IP + BBR + SSH加固 + 看门狗"
      echo "------------------------"
      echo "1. 运行    0. 返回"
      read -e -p "选择: " c < /dev/tty
      [ "$c" = "1" ] && run_remote "https://raw.githubusercontent.com/xyf0104/server-init/master/server-init.sh"
      ;;
    2)
      manage "S-UI" "Xray 可视化代理面板" \
        is_sui \
        'run_remote "https://raw.githubusercontent.com/xyf0104/demo/main/s-ui-install.sh"' \
        uninstall_sui \
        "systemctl restart s-ui"
      ;;
    3)
      manage "SUI-Bridge" "S-UI 订阅转换桥接服务" \
        is_bridge \
        'run_remote "https://raw.githubusercontent.com/xyf0104/subhub/main/sui-bridge/install_bridge.sh"' \
        uninstall_bridge \
        "systemctl restart sui-bridge"
      ;;
    4)
      manage "Hysteria2" "Hysteria2 协议代理工具" \
        is_hy2 \
        'wget -N --no-check-certificate https://raw.githubusercontent.com/xyf0104/hysteria2/main/hysteria.sh && bash hysteria.sh && rm -f hysteria.sh' \
        uninstall_hy2 \
        "systemctl restart hysteria-server"
      ;;
    5)
      manage "SubHub" "订阅聚合管理 (Docker Compose)" \
        is_subhub \
        'rm -rf /opt/subhub; git clone https://github.com/xyf0104/subhub.git /opt/subhub && cd /opt/subhub && bash install.sh' \
        uninstall_subhub \
        'cd /opt/subhub && docker compose restart'
      ;;
    6)
      manage "SSL证书管理(acme)" "ACME 证书自动签发与管理" \
        is_acme \
        'run_remote "https://raw.githubusercontent.com/yonggekkk/acme-yg/main/acme.sh"' \
        uninstall_acme \
        ""
      ;;
    7)
      manage "MoonTV影视" "MoonTV 在线影视聚合 (Docker)" \
        is_moontv \
        'run_remote "https://raw.githubusercontent.com/xyf0104/MoonTVPlus/main/install.sh"' \
        uninstall_moontv \
        'docker restart $(docker ps -a --format "{{.Names}}" | grep -i "moontv\|moon-tv" | head -1) 2>/dev/null'
      ;;
    8)
      manage "AI点数监控" "AI API 额度监控面板" \
        is_monitor \
        'rm -rf /opt/ai-credits-monitor; git clone https://github.com/xyf0104/ai-credits-monitor.git /opt/ai-credits-monitor && cd /opt/ai-credits-monitor && sudo ./install.sh' \
        uninstall_monitor \
        "systemctl restart ai-credits-monitor 2>/dev/null || systemctl restart ai-credits 2>/dev/null"
      ;;
    9)
      manage "NPM反代" "Nginx Proxy Manager 反向代理面板 | 初始: admin@example.com / changeme" \
        is_npm \
        'docker run -d --name npm -p 80:80 -p 81:81 -p 443:443 -v /home/docker/npm/data:/data -v /home/docker/npm/letsencrypt:/etc/letsencrypt --restart always jc21/nginx-proxy-manager:latest' \
        uninstall_npm \
        'docker restart npm 2>/dev/null || docker restart npm-app 2>/dev/null'
      ;;
    10)
      clear
      echo -e "${CYAN}${BOLD}然小二库存系统${NC}"
      echo "然小二 POS 库存管理系统"
      echo "------------------------"
      echo "1. 安装/管理    0. 返回"
      read -e -p "选择: " c < /dev/tty
      [ "$c" = "1" ] && run_remote "r.xiass.com"
      ;;
    0) break ;;
    *) echo -e "${RED}无效的输入!${NC}" ;;
  esac
  echo ""
  read -p "按回车键继续..." < /dev/tty
done
