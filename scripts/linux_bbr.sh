#!/bin/bash
# 无风工具箱 - BBR管理

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'; BOLD='\033[1m'

show_bbr_status() {
  clear
  echo -e "${CYAN}${BOLD}BBR管理${NC}"
  echo "========================"
  local cc=$(sysctl -n net.ipv4.tcp_congestion_control 2>/dev/null)
  local qdisc=$(sysctl -n net.core.default_qdisc 2>/dev/null)
  local avail=$(sysctl -n net.ipv4.tcp_available_congestion_control 2>/dev/null)
  echo -e "  ${BOLD}当前拥塞控制:${NC}   ${CYAN}${cc:-未知}${NC}"
  echo -e "  ${BOLD}队列算法:${NC}       ${qdisc:-未知}"
  echo -e "  ${BOLD}可用算法:${NC}       ${avail:-未知}"
  if [ "$cc" = "bbr" ]; then
    echo -e "  ${BOLD}BBR状态:${NC}        ${GREEN}✅ 已开启${NC}"
  else
    echo -e "  ${BOLD}BBR状态:${NC}        ${RED}❌ 未开启${NC}"
  fi
  echo "========================"
}

enable_bbr() {
  echo -e "正在开启 BBR..."
  cat > /etc/sysctl.d/99-bbr.conf << 'EOF'
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
EOF
  sysctl -p /etc/sysctl.d/99-bbr.conf > /dev/null 2>&1
  local cc=$(sysctl -n net.ipv4.tcp_congestion_control 2>/dev/null)
  if [ "$cc" = "bbr" ]; then
    echo -e "${GREEN}${BOLD}✅ BBR 已成功开启！${NC}"
  else
    echo -e "${RED}❌ BBR 开启失败，可能内核不支持${NC}"
  fi
}

disable_bbr() {
  echo -e "正在关闭 BBR..."
  cat > /etc/sysctl.d/99-bbr.conf << 'EOF'
net.core.default_qdisc=pfifo_fast
net.ipv4.tcp_congestion_control=cubic
EOF
  sysctl -p /etc/sysctl.d/99-bbr.conf > /dev/null 2>&1
  echo -e "${GREEN}✅ 已切换回 cubic${NC}"
}

while true; do
  show_bbr_status
  echo "1.  开启BBR"
  echo "2.  关闭BBR (切换cubic)"
  echo "3.  开启BBRv3 (需要内核支持)"
  echo "------------------------"
  echo "0.  返回主菜单"
  echo "------------------------"
  read -p "请输入你的选择: " choice < /dev/tty
  case "$choice" in
    1) enable_bbr; read -p "按回车键继续..." < /dev/tty ;;
    2) disable_bbr; read -p "按回车键继续..." < /dev/tty ;;
    3)
      echo -e "正在尝试开启 BBRv3..."
      modprobe tcp_bbr 2>/dev/null
      cat > /etc/sysctl.d/99-bbr.conf << 'EOF'
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
EOF
      sysctl -p /etc/sysctl.d/99-bbr.conf > /dev/null 2>&1
      echo -e "${GREEN}✅ 已尝试开启BBRv3 (需要 5.18+ 内核)${NC}"
      read -p "按回车键继续..." < /dev/tty
      ;;
    0) break ;;
    *) echo -e "${RED}无效选择${NC}"; sleep 1 ;;
  esac
done
