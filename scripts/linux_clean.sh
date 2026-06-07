#!/bin/bash
# 无风工具箱 - 系统清理

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'; BOLD='\033[1m'

clear
echo -e "${CYAN}${BOLD}系统清理${NC}"
echo "========================"

if command -v apt &>/dev/null; then
  echo -e "清理 APT 缓存..."
  apt autoremove --purge -y 2>&1 | tail -2
  apt clean -y 2>/dev/null
  apt autoclean -y 2>/dev/null
  echo -e "${GREEN}[✓]${NC} APT 缓存已清理"
elif command -v dnf &>/dev/null; then
  dnf autoremove -y 2>&1 | tail -2
  dnf clean all 2>/dev/null
  echo -e "${GREEN}[✓]${NC} DNF 缓存已清理"
elif command -v yum &>/dev/null; then
  yum autoremove -y 2>&1 | tail -2
  yum clean all 2>/dev/null
  echo -e "${GREEN}[✓]${NC} YUM 缓存已清理"
elif command -v apk &>/dev/null; then
  apk cache clean 2>/dev/null
  echo -e "${GREEN}[✓]${NC} APK 缓存已清理"
fi

echo ""
echo -e "清理系统日志..."
journalctl --vacuum-time=1d 2>/dev/null && echo -e "${GREEN}[✓]${NC} 日志已清理(保留1天)"
journalctl --vacuum-size=50M 2>/dev/null

echo ""
echo -e "清理临时文件..."
rm -rf /tmp/* 2>/dev/null
rm -rf /var/tmp/* 2>/dev/null
echo -e "${GREEN}[✓]${NC} 临时文件已清理"

echo ""
echo -e "清理旧内核..."
if command -v apt &>/dev/null; then
  dpkg -l 'linux-*' 2>/dev/null | sed '/^ii/!d;/'"$(uname -r | sed "s/\(.*\)-\([^0-9]\+\)/\1/")"'/d;s/^[^ ]* [^ ]* \([^ ]*\).*/\1/;/[0-9]/!d' | head -3 | xargs apt-get -y purge 2>/dev/null
  echo -e "${GREEN}[✓]${NC} 旧内核已清理"
fi

echo ""
before_clean=$(df / | awk 'NR==2{print $4}')
echo "========================"
echo -e "  ${BOLD}磁盘使用:${NC} $(df -h / | awk 'NR==2{print $3 " / " $2 " (" $5 ")"}')"
echo ""
echo -e "${GREEN}${BOLD}✅ 系统清理完成！${NC}"
echo "========================"
read -p "按回车键返回主菜单..." < /dev/tty
