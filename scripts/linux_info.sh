#!/bin/bash
# 无风工具箱 - 系统信息查询

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'; BOLD='\033[1m'

clear
echo -e "${CYAN}${BOLD}系统信息查询${NC}"
echo "========================"

# OS
os_name=$(cat /etc/os-release 2>/dev/null | grep PRETTY_NAME | cut -d'"' -f2)
kernel=$(uname -r)
arch=$(uname -m)
hostname=$(hostname)

# CPU
cpu_model=$(grep "model name" /proc/cpuinfo 2>/dev/null | head -1 | cut -d: -f2 | xargs)
cpu_cores=$(nproc 2>/dev/null || echo "?")
cpu_usage=$(top -bn1 2>/dev/null | grep "Cpu(s)" | awk '{print $2}' | cut -d. -f1)

# Memory
mem_total=$(free -h 2>/dev/null | awk '/Mem:/{print $2}')
mem_used=$(free -h 2>/dev/null | awk '/Mem:/{print $3}')
mem_pct=$(free 2>/dev/null | awk '/Mem:/{printf "%.0f", $3/$2*100}')
swap_total=$(free -h 2>/dev/null | awk '/Swap:/{print $2}')
swap_used=$(free -h 2>/dev/null | awk '/Swap:/{print $3}')

# Disk
disk_total=$(df -h / 2>/dev/null | awk 'NR==2{print $2}')
disk_used=$(df -h / 2>/dev/null | awk 'NR==2{print $3}')
disk_pct=$(df / 2>/dev/null | awk 'NR==2{print $5}')

# Network
ipv4=$(curl -s4 --max-time 3 ifconfig.me 2>/dev/null || curl -s4 --max-time 3 ip.sb 2>/dev/null || echo "N/A")
ipv6=$(curl -s6 --max-time 3 ifconfig.me 2>/dev/null || echo "N/A")
dns=$(cat /etc/resolv.conf 2>/dev/null | grep nameserver | head -1 | awk '{print $2}')

# Uptime & Load
up=$(uptime -p 2>/dev/null | sed 's/up //')
load=$(cat /proc/loadavg 2>/dev/null | awk '{print $1, $2, $3}')

# BBR
bbr_status=$(sysctl net.ipv4.tcp_congestion_control 2>/dev/null | awk '{print $3}')

echo -e "  ${BOLD}主机名:${NC}       $hostname"
echo -e "  ${BOLD}系统版本:${NC}     $os_name"
echo -e "  ${BOLD}内核版本:${NC}     $kernel"
echo -e "  ${BOLD}系统架构:${NC}     $arch"
echo ""
echo -e "  ${BOLD}CPU型号:${NC}      $cpu_model"
echo -e "  ${BOLD}CPU核心:${NC}      ${cpu_cores}核"
echo -e "  ${BOLD}CPU占用:${NC}      ${cpu_usage:-?}%"
echo ""
echo -e "  ${BOLD}物理内存:${NC}     $mem_used / $mem_total (${mem_pct}%)"
echo -e "  ${BOLD}虚拟内存:${NC}     $swap_used / $swap_total"
echo -e "  ${BOLD}硬盘占用:${NC}     $disk_used / $disk_total ($disk_pct)"
echo ""
echo -e "  ${BOLD}IPv4地址:${NC}     ${GREEN}$ipv4${NC}"
echo -e "  ${BOLD}IPv6地址:${NC}     ${GREEN}$ipv6${NC}"
echo -e "  ${BOLD}DNS地址:${NC}      $dns"
echo ""
echo -e "  ${BOLD}网络拥塞:${NC}     ${CYAN}${bbr_status:-未知}${NC}"
echo -e "  ${BOLD}系统负载:${NC}     $load"
echo -e "  ${BOLD}运行时长:${NC}     $up"
echo "========================"
echo ""
read -p "按回车键返回主菜单..." < /dev/tty
