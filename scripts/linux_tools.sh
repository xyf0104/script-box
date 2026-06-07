#!/bin/bash
# 无风工具箱 - 基础工具管理

CYAN='\033[0;36m'; GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; NC='\033[0m'; BOLD='\033[1m'

tools=(curl wget sudo socat htop iftop unzip tar tmux ffmpeg btop ranger ncdu fzf vim nano git)
tool_names=(
  "curl 下载工具 ★" "wget 下载工具 ★" "sudo 超级管理权限工具" "socat 通信连接工具"
  "htop 系统监控工具" "iftop 网络流量监控工具" "unzip ZIP压缩解压工具" "tar GZ压缩解压工具"
  "tmux 多路后台运行工具" "ffmpeg 视频编码直播推流工具"
  "btop 现代化监控工具 ★" "ranger 文件管理工具"
  "ncdu 磁盘占用查看工具" "fzf 全局搜索工具"
  "vim 文本编辑器" "nano 文本编辑器 ★" "git 版本控制系统"
)

game_tools=(cmatrix sl bastet nsnake ninvaders)
game_names=("黑客帝国屏保" "跑火车屏保" "俄罗斯方块小游戏" "贪吃蛇小游戏" "太空入侵者小游戏")

detect_pm() {
  for p in apt dnf yum pacman apk zypper; do command -v $p &>/dev/null && echo $p && return; done
  echo "unknown"
}
PM=$(detect_pm)

do_install() {
  case $PM in
    apt) apt install -y "$1" 2>/dev/null || { apt update -qq 2>/dev/null; apt install -y "$1"; } ;;
    dnf) dnf install -y "$1" ;; yum) yum install -y "$1" ;;
    pacman) pacman -S --noconfirm "$1" ;; apk) apk add "$1" ;; zypper) zypper install -y "$1" ;;
  esac
}

do_remove() {
  case $PM in
    apt) apt remove -y -qq "$1" ;; dnf) dnf remove -y -q "$1" ;; yum) yum remove -y -q "$1" ;;
    pacman) pacman -R --noconfirm "$1" ;; apk) apk del "$1" ;; zypper) zypper remove -y "$1" ;;
  esac
}

while true; do
  clear
  echo -e "${CYAN}${BOLD}基础工具${NC}"
  echo "📦 使用包管理器: $PM"
  echo -e "${CYAN}------------------------${NC}"

  # Show install status grid
  for ((i=0; i<${#tools[@]}; i+=2)); do
    left=""; right=""
    t1=${tools[$i]}; t2=${tools[$((i+1))]}
    if command -v "$t1" &>/dev/null; then left=$(printf "${GREEN}✅ %-12s 已安装${NC}" "$t1")
    else left=$(printf "${RED}❌ %-12s 未安装${NC}" "$t1"); fi
    if [ -n "$t2" ]; then
      if command -v "$t2" &>/dev/null; then right=$(printf "${GREEN}✅ %-12s 已安装${NC}" "$t2")
      else right=$(printf "${RED}❌ %-12s 未安装${NC}" "$t2"); fi
    fi
    printf "%-42b %b\n" "$left" "$right"
  done

  echo -e "${CYAN}------------------------${NC}"
  echo -e "1.   curl 下载工具 ${YELLOW}★${NC}                   2.   wget 下载工具 ${YELLOW}★${NC}"
  echo -e "3.   sudo 超级管理权限工具             4.   socat 通信连接工具"
  echo -e "5.   htop 系统监控工具                 6.   iftop 网络流量监控工具"
  echo -e "7.   unzip ZIP压缩解压工具             8.   tar GZ压缩解压工具"
  echo -e "9.   tmux 多路后台运行工具             10.  ffmpeg 视频编码直播推流工具"
  echo -e "${CYAN}------------------------${NC}"
  echo -e "11.  btop 现代化监控工具 ${YELLOW}★${NC}             12.  ranger 文件管理工具"
  echo -e "13.  ncdu 磁盘占用查看工具             14.  fzf 全局搜索工具"
  echo -e "15.  vim 文本编辑器                    16.  nano 文本编辑器 ${YELLOW}★${NC}"
  echo -e "17.  git 版本控制系统                  18.  opencode AI编程助手 ${YELLOW}★${NC}"
  echo -e "${CYAN}------------------------${NC}"
  echo -e "21.  黑客帝国屏保                      22.  跑火车屏保"
  echo -e "26.  俄罗斯方块小游戏                  27.  贪吃蛇小游戏"
  echo -e "28.  太空入侵者小游戏"
  echo -e "${CYAN}------------------------${NC}"
  echo -e "31.  全部安装                          32.  全部安装（不含屏保和游戏）${YELLOW}★${NC}"
  echo -e "33.  全部卸载"
  echo -e "${CYAN}------------------------${NC}"
  echo -e "41.  安装指定工具                      42.  卸载指定工具"
  echo -e "${CYAN}------------------------${NC}"
  echo -e "0.   返回主菜单"
  echo -e "${CYAN}------------------------${NC}"
  read -e -p "请输入你的选择: " choice < /dev/tty

  case "$choice" in
    [1-9]|1[0-7])
      idx=$((choice - 1))
      if [ $idx -lt ${#tools[@]} ]; then
        pkg=${tools[$idx]}
        if command -v "$pkg" &>/dev/null; then
          echo -e "${GREEN}✅ ${tool_names[$idx]} 已安装${NC}"
        else
          echo -e "正在安装 ${tool_names[$idx]} ..."
          echo "------------------------"
          do_install "$pkg"
          echo "------------------------"
          command -v "$pkg" &>/dev/null && echo -e "${GREEN}✅ 安装完成${NC}" || echo -e "${RED}❌ 安装失败${NC}"
        fi
      fi
      ;;
    18)
      clear
      echo "正在安装 opencode AI编程助手..."
      if command -v go &>/dev/null; then
        go install github.com/opencode-ai/opencode@latest 2>/dev/null && echo -e "${GREEN}✅ opencode 安装完成${NC}" || echo -e "${RED}❌ 安装失败${NC}"
      else
        echo "需要先安装 Go 语言环境"
        echo "安装命令: curl -fsSL https://go.dev/dl/go1.22.0.linux-amd64.tar.gz | tar -C /usr/local -xzf -"
      fi
      ;;
    21) do_install cmatrix &>/dev/null; echo -e "${GREEN}✅ cmatrix 已安装，输入 cmatrix 运行${NC}" ;;
    22) do_install sl &>/dev/null; echo -e "${GREEN}✅ sl 已安装，输入 sl 运行${NC}" ;;
    26) do_install bastet &>/dev/null; echo -e "${GREEN}✅ bastet 已安装，输入 bastet 运行${NC}" ;;
    27) do_install nsnake &>/dev/null; echo -e "${GREEN}✅ nsnake 已安装，输入 nsnake 运行${NC}" ;;
    28) do_install ninvaders &>/dev/null; echo -e "${GREEN}✅ ninvaders 已安装，输入 ninvaders 运行${NC}" ;;
    31)
      echo -e "${CYAN}正在安装全部工具（含屏保和游戏）...${NC}"
      for pkg in "${tools[@]}" "${game_tools[@]}"; do
        echo -ne "  安装 $pkg ..."
        do_install "$pkg" &>/dev/null
        command -v "$pkg" &>/dev/null && echo -e " ${GREEN}✅${NC}" || echo -e " ${RED}❌${NC}"
      done
      ;;
    32)
      echo -e "${CYAN}正在安装全部工具（不含屏保和游戏）...${NC}"
      for pkg in "${tools[@]}"; do
        echo -ne "  安装 $pkg ..."
        do_install "$pkg" &>/dev/null
        command -v "$pkg" &>/dev/null && echo -e " ${GREEN}✅${NC}" || echo -e " ${RED}❌${NC}"
      done
      ;;
    33)
      echo -e "${YELLOW}正在卸载全部工具...${NC}"
      for pkg in "${tools[@]}" "${game_tools[@]}"; do
        echo -ne "  卸载 $pkg ..."
        do_remove "$pkg" &>/dev/null
        ! command -v "$pkg" &>/dev/null && echo -e " ${GREEN}✅${NC}" || echo -e " ${RED}❌${NC}"
      done
      ;;
    41)
      read -e -p "输入要安装的工具名(空格分隔): " input < /dev/tty
      for t in $input; do
        do_install "$t" &>/dev/null && echo -e "${GREEN}✅ $t 安装完成${NC}" || echo -e "${RED}❌ $t 安装失败${NC}"
      done
      ;;
    42)
      read -e -p "输入要卸载的工具名(空格分隔): " input < /dev/tty
      for t in $input; do
        do_remove "$t" &>/dev/null && echo -e "${GREEN}✅ $t 卸载完成${NC}" || echo -e "${RED}❌ $t 卸载失败${NC}"
      done
      ;;
    0) break ;;
    *) echo -e "${RED}无效的输入!${NC}" ;;
  esac
  echo ""
  read -p "按回车键继续..." < /dev/tty
done
