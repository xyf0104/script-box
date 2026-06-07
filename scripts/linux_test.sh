#!/bin/bash
# 无风工具箱 - 测试脚本合集
# 对齐 kejilion v4.5.1 测试脚本结构

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'; BOLD='\033[1m'

# 自动安装缺失依赖
install_if_missing() {
  for pkg in "$@"; do
    if ! command -v "$pkg" &>/dev/null; then
      if command -v apt &>/dev/null; then apt install -y -qq "$pkg" 2>/dev/null
      elif command -v yum &>/dev/null; then yum install -y -q "$pkg" 2>/dev/null
      elif command -v dnf &>/dev/null; then dnf install -y -q "$pkg" 2>/dev/null
      fi
    fi
  done
}

while true; do
  clear
  echo -e "${CYAN}${BOLD}测试脚本合集${NC}"
  echo -e "${CYAN}------------------------${NC}"
  echo -e "${CYAN}IP及解锁状态检测${NC}"
  echo -e "1.   ChatGPT 解锁状态检测"
  echo -e "2.   Region 流媒体解锁测试"
  echo -e "3.   yeahwu 流媒体解锁检测"
  echo -e "4.   xykt IP质量体检脚本 ${YELLOW}★${NC}"
  echo -e "${CYAN}------------------------${NC}"
  echo -e "${CYAN}网络线路测速${NC}"
  echo -e "11.  besttrace 三网回程延迟路由测试"
  echo -e "12.  mtr_trace 三网回程线路测试"
  echo -e "13.  Superspeed 三网测速"
  echo -e "14.  nxtrace 快速回程测试脚本"
  echo -e "15.  nxtrace 指定IP回程测试脚本"
  echo -e "16.  ludashi2020 三网线路测试"
  echo -e "17.  i-abc 多功能测速脚本"
  echo -e "18.  NetQuality 网络质量体检脚本 ${YELLOW}★${NC}"
  echo -e "${CYAN}------------------------${NC}"
  echo -e "${CYAN}硬件性能测试${NC}"
  echo -e "21.  yabs 性能测试"
  echo -e "22.  icu/gb5 CPU性能测试脚本"
  echo -e "${CYAN}------------------------${NC}"
  echo -e "${CYAN}综合性测试${NC}"
  echo -e "31.  bench 性能测试"
  echo -e "32.  spiritysdx 融合怪测评 ${YELLOW}★${NC}"
  echo -e "33.  nodequality 融合怪测评 ${YELLOW}★${NC}"
  echo -e "${CYAN}------------------------${NC}"
  echo -e "0.   返回主菜单"
  echo -e "${CYAN}------------------------${NC}"
  read -e -p "请输入你的选择: " sub_choice < /dev/tty

  case $sub_choice in
    1)
      clear
      bash <(curl -Ls https://cdn.jsdelivr.net/gh/missuo/OpenAI-Checker/openai.sh)
      ;;
    2)
      clear
      bash <(curl -L -s check.unlock.media)
      ;;
    3)
      clear
      install_if_missing wget
      wget -qO- https://github.com/yeahwu/check/raw/main/check.sh | bash
      ;;
    4)
      clear
      bash <(curl -Ls IP.Check.Place)
      ;;
    11)
      clear
      install_if_missing wget
      wget -qO- git.io/besttrace | bash
      ;;
    12)
      clear
      curl https://raw.githubusercontent.com/zhucaidan/mtr_trace/main/mtr_trace.sh | bash
      ;;
    13)
      clear
      bash <(curl -Lso- https://git.io/superspeed_uxh)
      ;;
    14)
      clear
      curl nxtrace.org/nt | bash
      nexttrace --fast-trace --tcp
      ;;
    15)
      clear
      echo "可参考的IP列表"
      echo "------------------------"
      echo "北京电信: 219.141.136.12"
      echo "北京联通: 202.106.50.1"
      echo "北京移动: 221.179.155.161"
      echo "上海电信: 202.96.209.133"
      echo "上海联通: 210.22.97.1"
      echo "上海移动: 211.136.112.200"
      echo "广州电信: 58.60.188.222"
      echo "广州联通: 210.21.196.6"
      echo "广州移动: 120.196.165.24"
      echo "成都电信: 61.139.2.69"
      echo "成都联通: 119.6.6.6"
      echo "成都移动: 211.137.96.205"
      echo "湖南电信: 36.111.200.100"
      echo "湖南联通: 42.48.16.100"
      echo "湖南移动: 39.134.254.6"
      echo "------------------------"
      read -e -p "输入一个指定IP: " testip < /dev/tty
      curl nxtrace.org/nt | bash
      nexttrace $testip
      ;;
    16)
      clear
      curl https://raw.githubusercontent.com/ludashi2020/backtrace/main/install.sh -sSf | sh
      ;;
    17)
      clear
      bash <(curl -sL https://raw.githubusercontent.com/i-abc/Speedtest/main/speedtest.sh)
      ;;
    18)
      clear
      bash <(curl -sL Net.Check.Place)
      ;;
    21)
      clear
      curl -sL yabs.sh | bash -s -- -i -5
      ;;
    22)
      clear
      bash <(curl -sL https://github.com/i-abc/GB5/raw/main/gb5-test.sh)
      ;;
    31)
      clear
      curl -Lso- bench.sh | bash
      ;;
    32)
      clear
      curl -L https://github.com/spiritLHLS/ecs/raw/main/ecs.sh -o ecs.sh && chmod +x ecs.sh && bash ecs.sh
      rm -f ecs.sh 2>/dev/null
      ;;
    33)
      clear
      bash <(curl -sL https://run.NodeQuality.com)
      ;;
    0) break ;;
    *) echo -e "${RED}无效的输入!${NC}" ;;
  esac
  echo ""
  read -p "按回车键继续..." < /dev/tty
done
