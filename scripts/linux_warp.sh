#!/bin/bash
# 无风工具箱 - WARP管理

CYAN='\033[0;36m'; GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; NC='\033[0m'; BOLD='\033[1m'

show_warp_status() {
  echo -e "${CYAN}WARP状态${NC}"
  echo "------------------------"
  if command -v warp-cli &>/dev/null; then
    echo -e "WARP-CLI: ${GREEN}已安装${NC}"
    warp-cli status 2>/dev/null || echo "状态获取失败"
  elif [ -f /etc/wireguard/warp.conf ]; then
    echo -e "WARP WireGuard: ${GREEN}已配置${NC}"
    wg show 2>/dev/null | head -5 || echo "接口未启动"
  else
    echo -e "WARP: ${RED}未安装${NC}"
  fi
  echo ""
  echo -e "当前IPv4: $(curl -s4 --max-time 3 ifconfig.me 2>/dev/null || echo 'N/A')"
  echo -e "当前IPv6: $(curl -s6 --max-time 3 ifconfig.me 2>/dev/null || echo 'N/A')"
  echo "------------------------"
}

while true; do
  clear
  echo -e "${CYAN}${BOLD}WARP管理${NC}"
  echo -e "${CYAN}------------------------${NC}"
  show_warp_status
  echo ""
  echo -e "1.   安装/更新 CloudFlare WARP (官方CLI)"
  echo -e "2.   WARP开启/关闭"
  echo -e "3.   安装 WireGuard + WARP"
  echo -e "4.   fscarmen WARP脚本 ${YELLOW}★${NC}"
  echo -e "5.   P3TERX Warp.sh 脚本"
  echo -e "${CYAN}------------------------${NC}"
  echo -e "9.   卸载WARP"
  echo -e "${CYAN}------------------------${NC}"
  echo -e "0.   返回主菜单"
  echo -e "${CYAN}------------------------${NC}"
  read -e -p "请输入你的选择: " choice < /dev/tty

  case "$choice" in
    1)
      clear
      echo "正在安装 CloudFlare WARP..."
      # 官方安装方式：手动添加 apt 源
      if command -v apt &>/dev/null; then
        curl -fsSL https://pkg.cloudflareclient.com/pubkey.gpg | gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg 2>/dev/null
        echo "deb [arch=amd64 signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $(lsb_release -cs) main" > /etc/apt/sources.list.d/cloudflare-client.list
        apt update && apt install -y cloudflare-warp
      else
        echo -e "${YELLOW}非 Debian/Ubuntu 系统，建议使用选项4 fscarmen脚本安装${NC}"
      fi
      warp-cli registration new 2>/dev/null
      echo -e "${GREEN}✅ 安装完成，使用 warp-cli connect 连接${NC}"
      ;;
    2)
      if command -v warp-cli &>/dev/null; then
        status=$(warp-cli status 2>/dev/null | grep -i "connected" | wc -l)
        if [ "$status" -gt 0 ]; then
          warp-cli disconnect 2>/dev/null
          echo -e "${YELLOW}WARP 已关闭${NC}"
        else
          warp-cli connect 2>/dev/null
          echo -e "${GREEN}WARP 已开启${NC}"
        fi
      else
        echo -e "${RED}WARP未安装${NC}"
      fi
      ;;
    3)
      clear
      echo "正在安装 WireGuard..."
      apt install -y wireguard 2>/dev/null || dnf install -y wireguard-tools 2>/dev/null
      echo -e "${GREEN}✅ WireGuard 已安装${NC}"
      echo "请手动配置 /etc/wireguard/warp.conf"
      ;;
    4)
      clear
      bash <(curl -sSL https://gitlab.com/fscarmen/warp/-/raw/main/menu.sh)
      ;;
    5)
      clear
      bash <(curl -fsSL git.io/warp.sh) menu
      ;;
    9)
      echo -e "${YELLOW}正在卸载 WARP...${NC}"
      warp-cli disconnect 2>/dev/null
      apt remove -y cloudflare-warp 2>/dev/null
      rm -f /etc/wireguard/warp.conf 2>/dev/null
      echo -e "${GREEN}✅ WARP 已卸载${NC}"
      ;;
    0) break ;;
    *) echo -e "${RED}无效的输入!${NC}" ;;
  esac
  echo ""
  read -p "按回车键继续..." < /dev/tty
done
