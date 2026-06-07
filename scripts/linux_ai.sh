#!/bin/bash
# 无风工具箱 - AI工具

CYAN='\033[0;36m'; GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; NC='\033[0m'; BOLD='\033[1m'

docker_app() {
  local name=$1 img=$2 port=$3 desc=$4 run_cmd=$5
  echo -e "${CYAN}${BOLD}$desc${NC}"
  echo "------------------------"
  if docker ps -a --format '{{.Names}}' 2>/dev/null | grep -q "^${name}$"; then
    local status=$(docker inspect -f '{{.State.Status}}' "$name" 2>/dev/null)
    echo -e "状态: ${GREEN}已安装 ($status)${NC}  端口: $port"
    echo "1. 更新  2. 卸载  3. 重启  0. 返回"
    read -e -p "选择: " c < /dev/tty
    case "$c" in
      1) docker stop "$name" 2>/dev/null; docker rm "$name" 2>/dev/null; docker rmi "$img" 2>/dev/null; eval "$run_cmd"; echo -e "${GREEN}✅ 已更新${NC}" ;;
      2) docker stop "$name" 2>/dev/null; docker rm "$name" 2>/dev/null; echo -e "${GREEN}✅ 已卸载${NC}" ;;
      3) docker restart "$name" 2>/dev/null; echo -e "${GREEN}✅ 已重启${NC}" ;;
    esac
  else
    echo -e "状态: ${RED}未安装${NC}"
    echo "1. 安装  0. 返回"
    read -e -p "选择: " c < /dev/tty
    if [ "$c" = "1" ]; then
      command -v docker &>/dev/null || { curl -fsSL https://get.docker.com | sh; systemctl enable docker; systemctl start docker; }
      eval "$run_cmd"; echo -e "${GREEN}✅ 已安装，端口: $port${NC}"
    fi
  fi
}

while true; do
  clear
  echo -e "${CYAN}${BOLD}AI工具${NC}"
  echo -e "${CYAN}------------------------${NC}"
  echo -e "1.   安装Ollama本地大模型"
  echo -e "2.   OpenWebUI (AI对话界面)"
  echo -e "3.   LobeChat聊天聚合"
  echo -e "4.   Dify大模型知识库 ${YELLOW}★${NC}"
  echo -e "5.   NewAPI模型管理"
  echo -e "6.   Deepseek聊天AI大模型"
  echo -e "${CYAN}------------------------${NC}"
  echo -e "11.  管理Ollama模型"
  echo -e "12.  查看已安装AI服务状态"
  echo -e "${CYAN}------------------------${NC}"
  echo -e "0.   返回主菜单"
  echo -e "${CYAN}------------------------${NC}"
  read -e -p "请输入你的选择: " choice < /dev/tty

  case "$choice" in
    1)
      clear
      if command -v ollama &>/dev/null; then
        echo -e "${GREEN}Ollama 已安装: $(ollama --version 2>/dev/null)${NC}"
        echo "1. 更新  2. 卸载  0. 返回"
        read -e -p "选择: " c < /dev/tty
        case "$c" in
          1) curl -fsSL https://ollama.com/install.sh | sh ;;
          2) systemctl stop ollama 2>/dev/null; rm -f /usr/local/bin/ollama; echo -e "${GREEN}✅ 已卸载${NC}" ;;
        esac
      else
        echo "正在安装Ollama..."
        curl -fsSL https://ollama.com/install.sh | sh
        echo -e "${GREEN}✅ Ollama安装完成${NC}"
        echo "拉取模型: ollama pull llama3 / qwen2 / deepseek-r1"
      fi
      ;;
    2) clear; docker_app "open-webui" "ghcr.io/open-webui/open-webui:main" "3100" "OpenWebUI - AI对话界面" \
       "docker run -d --name open-webui -p 3100:8080 -v /home/docker/open-webui:/app/backend/data --add-host=host.docker.internal:host-gateway --restart always ghcr.io/open-webui/open-webui:main" ;;
    3) clear; docker_app "lobe-chat" "lobehub/lobe-chat:latest" "3210" "LobeChat聊天聚合" \
       "docker run -d --name lobe-chat -p 3210:3210 --restart always lobehub/lobe-chat:latest" ;;
    4)
      clear
      echo -e "${CYAN}Dify大模型知识库${NC}"
      if [ -d /home/docker/dify ]; then
        echo -e "状态: ${GREEN}已安装${NC}"
        echo "1. 更新  2. 卸载  3. 重启  0. 返回"
        read -e -p "选择: " c < /dev/tty
        case "$c" in
          1) cd /home/docker/dify/docker && docker compose pull && docker compose up -d ;;
          2) cd /home/docker/dify/docker && docker compose down; rm -rf /home/docker/dify; echo -e "${GREEN}✅ 已卸载${NC}" ;;
          3) cd /home/docker/dify/docker && docker compose restart ;;
        esac
      else
        echo "正在安装Dify..."
        git clone https://github.com/langgenius/dify.git /home/docker/dify
        cd /home/docker/dify/docker && cp .env.example .env && docker compose up -d
        echo -e "${GREEN}✅ Dify已安装，访问端口: 80${NC}"
      fi
      ;;
    5) clear; docker_app "new-api" "calciumion/new-api:latest" "3003" "NewAPI大模型资产管理" \
       "docker run -d --name new-api -p 3003:3000 -v /home/docker/new-api:/data --restart always calciumion/new-api:latest" ;;
    6)
      clear
      echo "Deepseek聊天AI大模型"
      if command -v ollama &>/dev/null; then
        echo "正在拉取 deepseek-r1 模型..."
        ollama pull deepseek-r1
        echo -e "${GREEN}✅ 运行: ollama run deepseek-r1${NC}"
      else
        echo -e "${RED}请先安装Ollama (选项1)${NC}"
      fi
      ;;
    11)
      clear
      echo -e "${CYAN}Ollama模型管理${NC}"
      if command -v ollama &>/dev/null; then
        echo "已安装模型:"
        ollama list 2>/dev/null
        echo ""
        echo "1. 拉取模型  2. 删除模型  3. 运行模型"
        read -e -p "选择: " c < /dev/tty
        case "$c" in
          1) read -e -p "模型名(如llama3/qwen2): " mn < /dev/tty; ollama pull "$mn" ;;
          2) read -e -p "模型名: " mn < /dev/tty; ollama rm "$mn" ;;
          3) read -e -p "模型名: " mn < /dev/tty; ollama run "$mn" < /dev/tty ;;
        esac
      else
        echo -e "${RED}Ollama未安装${NC}"
      fi
      ;;
    12)
      clear
      echo -e "${CYAN}AI服务状态${NC}"
      echo "------------------------"
      command -v ollama &>/dev/null && echo -e "Ollama: ${GREEN}已安装${NC} $(ollama --version 2>/dev/null)" || echo -e "Ollama: ${RED}未安装${NC}"
      for svc in open-webui lobe-chat new-api; do
        if docker ps --format '{{.Names}}' 2>/dev/null | grep -q "^${svc}$"; then
          echo -e "$svc: ${GREEN}运行中${NC}"
        elif docker ps -a --format '{{.Names}}' 2>/dev/null | grep -q "^${svc}$"; then
          echo -e "$svc: ${YELLOW}已停止${NC}"
        else
          echo -e "$svc: ${RED}未安装${NC}"
        fi
      done
      [ -d /home/docker/dify ] && echo -e "Dify: ${GREEN}已安装${NC}" || echo -e "Dify: ${RED}未安装${NC}"
      ;;
    0) break ;;
    *) echo -e "${RED}无效的输入!${NC}" ;;
  esac
  echo ""
  read -p "按回车键继续..." < /dev/tty
done
