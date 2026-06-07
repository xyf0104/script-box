#!/bin/bash
# 无风工具箱 - 系统更新

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'; BOLD='\033[1m'

clear
echo -e "${CYAN}${BOLD}系统更新${NC}"
echo "========================"

if command -v apt &>/dev/null; then
  PM="apt"
  echo -e "${GREEN}[✓]${NC} 检测到包管理器: apt (Debian/Ubuntu)"
  echo ""
  echo -e "正在更新软件包列表..."
  apt update -y 2>&1 | tail -3
  echo ""
  echo -e "正在升级已安装的软件包..."
  DEBIAN_FRONTEND=noninteractive apt full-upgrade -y 2>&1 | tail -5
elif command -v dnf &>/dev/null; then
  PM="dnf"
  echo -e "${GREEN}[✓]${NC} 检测到包管理器: dnf (Fedora/CentOS)"
  echo ""
  dnf update -y 2>&1 | tail -5
elif command -v yum &>/dev/null; then
  PM="yum"
  echo -e "${GREEN}[✓]${NC} 检测到包管理器: yum (CentOS)"
  echo ""
  yum update -y 2>&1 | tail -5
elif command -v apk &>/dev/null; then
  PM="apk"
  echo -e "${GREEN}[✓]${NC} 检测到包管理器: apk (Alpine)"
  echo ""
  apk update && apk upgrade 2>&1 | tail -5
else
  echo -e "${RED}[✗]${NC} 未检测到支持的包管理器"
  read -p "按回车键返回..." < /dev/tty
  exit 1
fi

echo ""
echo -e "${GREEN}${BOLD}✅ 系统更新完成！${NC}"
echo "========================"
read -p "按回车键返回主菜单..." < /dev/tty
