#!/bin/bash
# 无风工具箱 - Docker管理

CYAN='\033[0;36m'; GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; NC='\033[0m'; BOLD='\033[1m'

install_docker() {
  if command -v docker &>/dev/null; then
    echo -e "${GREEN}Docker 已安装，正在更新...${NC}"
    curl -fsSL https://get.docker.com | sh
  else
    echo -e "正在安装 Docker..."
    curl -fsSL https://get.docker.com | sh
  fi
  systemctl enable docker 2>/dev/null; systemctl start docker 2>/dev/null
  echo -e "${GREEN}Docker版本: $(docker --version 2>/dev/null)${NC}"
  echo -e "${GREEN}Compose版本: $(docker compose version 2>/dev/null)${NC}"
}

show_status() {
  echo -e "${CYAN}Docker全局状态${NC}"
  echo "------------------------"
  if ! command -v docker &>/dev/null; then
    echo -e "${RED}Docker 未安装${NC}"; return
  fi
  echo -e "Docker版本: $(docker --version 2>/dev/null | awk '{print $3}' | tr -d ',')"
  echo -e "Compose版本: $(docker compose version 2>/dev/null | awk '{print $NF}')"
  echo ""
  local running=$(docker ps -q 2>/dev/null | wc -l)
  local stopped=$(docker ps -aq --filter "status=exited" 2>/dev/null | wc -l)
  local total=$(docker ps -aq 2>/dev/null | wc -l)
  echo -e "容器: 运行 ${GREEN}$running${NC} / 停止 ${RED}$stopped${NC} / 总计 $total"
  echo -e "镜像: $(docker images -q 2>/dev/null | wc -l)"
  echo -e "网络: $(docker network ls -q 2>/dev/null | wc -l)"
  echo -e "数据卷: $(docker volume ls -q 2>/dev/null | wc -l)"
  echo ""
  docker system df 2>/dev/null
}

container_mgmt() {
  while true; do
    clear
    echo -e "${CYAN}Docker容器管理${NC}"
    echo "------------------------"
    docker ps -a --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Image}}\t{{.Ports}}" 2>/dev/null
    echo "------------------------"
    echo "1. 启动指定容器    2. 停止指定容器    3. 重启指定容器"
    echo "4. 删除指定容器    5. 查看容器日志    6. 进入容器终端"
    echo "7. 启动所有容器    8. 停止所有容器    9. 重启所有容器"
    echo "------------------------"
    echo "0. 返回"
    echo "------------------------"
    read -e -p "请输入你的选择: " c < /dev/tty
    case "$c" in
      1) read -e -p "容器名: " n < /dev/tty; docker start "$n" 2>/dev/null && echo -e "${GREEN}✅ 已启动${NC}" ;;
      2) read -e -p "容器名: " n < /dev/tty; docker stop "$n" 2>/dev/null && echo -e "${GREEN}✅ 已停止${NC}" ;;
      3) read -e -p "容器名: " n < /dev/tty; docker restart "$n" 2>/dev/null && echo -e "${GREEN}✅ 已重启${NC}" ;;
      4) read -e -p "容器名: " n < /dev/tty; docker stop "$n" 2>/dev/null; docker rm "$n" 2>/dev/null && echo -e "${GREEN}✅ 已删除${NC}" ;;
      5) read -e -p "容器名: " n < /dev/tty; docker logs --tail 50 "$n" 2>/dev/null ;;
      6) read -e -p "容器名: " n < /dev/tty; docker exec -it "$n" /bin/sh 2>/dev/null || docker exec -it "$n" /bin/bash 2>/dev/null ;;
      7) docker start $(docker ps -aq) 2>/dev/null; echo -e "${GREEN}✅ 已启动所有${NC}" ;;
      8) docker stop $(docker ps -q) 2>/dev/null; echo -e "${GREEN}✅ 已停止所有${NC}" ;;
      9) docker restart $(docker ps -aq) 2>/dev/null; echo -e "${GREEN}✅ 已重启所有${NC}" ;;
      0) break ;; *) echo "无效" ;;
    esac
    [ "$c" != "0" ] && read -p "按回车键继续..." < /dev/tty
  done
}

image_mgmt() {
  while true; do
    clear
    echo -e "${CYAN}Docker镜像管理${NC}"
    echo "------------------------"
    docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.ID}}" 2>/dev/null
    echo "------------------------"
    echo "1. 拉取镜像    2. 删除指定镜像    3. 删除所有未使用镜像"
    echo "------------------------"
    echo "0. 返回"
    echo "------------------------"
    read -e -p "请输入你的选择: " c < /dev/tty
    case "$c" in
      1) read -e -p "镜像名(如 nginx:latest): " n < /dev/tty; docker pull "$n" ;;
      2) read -e -p "镜像ID或名称: " n < /dev/tty; docker rmi "$n" 2>/dev/null && echo -e "${GREEN}✅ 已删除${NC}" ;;
      3) docker image prune -af 2>/dev/null; echo -e "${GREEN}✅ 已清理${NC}" ;;
      0) break ;; *) echo "无效" ;;
    esac
    [ "$c" != "0" ] && read -p "按回车键继续..." < /dev/tty
  done
}

network_mgmt() {
  while true; do
    clear
    echo -e "${CYAN}Docker网络管理${NC}"
    echo "------------------------"
    docker network ls 2>/dev/null
    echo "------------------------"
    echo "1. 创建网络    2. 容器加入网络    3. 容器退出网络    4. 删除网络"
    echo "------------------------"
    echo "0. 返回"
    echo "------------------------"
    read -e -p "请输入你的选择: " c < /dev/tty
    case "$c" in
      1) read -e -p "设置新网络名: " n < /dev/tty; docker network create "$n" ;;
      2) read -e -p "加入网络名: " net < /dev/tty; read -e -p "容器名(空格分隔): " names < /dev/tty
         for name in $names; do docker network connect "$net" "$name"; done ;;
      3) read -e -p "退出网络名: " net < /dev/tty; read -e -p "容器名(空格分隔): " names < /dev/tty
         for name in $names; do docker network disconnect "$net" "$name"; done ;;
      4) read -e -p "删除网络名: " n < /dev/tty; docker network rm "$n" ;;
      0) break ;; *) echo "无效" ;;
    esac
    [ "$c" != "0" ] && read -p "按回车键继续..." < /dev/tty
  done
}

volume_mgmt() {
  while true; do
    clear
    echo -e "${CYAN}Docker卷管理${NC}"
    echo "------------------------"
    docker volume ls 2>/dev/null
    echo "------------------------"
    echo "1. 创建卷    2. 删除指定卷    3. 清理未使用卷"
    echo "------------------------"
    echo "0. 返回"
    echo "------------------------"
    read -e -p "请输入你的选择: " c < /dev/tty
    case "$c" in
      1) read -e -p "设置新卷名: " n < /dev/tty; docker volume create "$n" ;;
      2) read -e -p "删除卷名(空格分隔): " names < /dev/tty
         for name in $names; do docker volume rm "$name"; done ;;
      3) docker volume prune -f 2>/dev/null; echo -e "${GREEN}✅ 已清理${NC}" ;;
      0) break ;; *) echo "无效" ;;
    esac
    [ "$c" != "0" ] && read -p "按回车键继续..." < /dev/tty
  done
}

while true; do
  clear
  echo -e "${CYAN}${BOLD}Docker管理${NC}"
  echo -e "${CYAN}------------------------${NC}"
  echo -e "1.   安装更新Docker环境 ${YELLOW}★${NC}"
  echo -e "${CYAN}------------------------${NC}"
  echo -e "2.   查看Docker全局状态 ${YELLOW}★${NC}"
  echo -e "${CYAN}------------------------${NC}"
  echo -e "3.   Docker容器管理 ${YELLOW}★${NC}"
  echo -e "4.   Docker镜像管理"
  echo -e "5.   Docker网络管理"
  echo -e "6.   Docker卷管理"
  echo -e "${CYAN}------------------------${NC}"
  echo -e "7.   清理无用的docker容器和镜像网络数据卷"
  echo -e "${CYAN}------------------------${NC}"
  echo -e "8.   更换Docker源"
  echo -e "9.   编辑daemon.json文件"
  echo -e "${CYAN}------------------------${NC}"
  echo -e "11.  开启Docker-ipv6访问"
  echo -e "12.  关闭Docker-ipv6访问"
  echo -e "${CYAN}------------------------${NC}"
  echo -e "20.  卸载Docker环境"
  echo -e "${CYAN}------------------------${NC}"
  echo -e "0.   返回主菜单"
  echo -e "${CYAN}------------------------${NC}"
  read -e -p "请输入你的选择: " choice < /dev/tty

  case "$choice" in
    1) install_docker ;;
    2) clear; show_status ;;
    3) container_mgmt; continue ;;
    4) image_mgmt; continue ;;
    5) network_mgmt; continue ;;
    6) volume_mgmt; continue ;;
    7)
      echo -e "${YELLOW}将清理: 停止的容器、未使用网络、悬空镜像和构建缓存${NC}"
      read -e -p "确认清理? [y/N]: " confirm < /dev/tty
      [[ "$confirm" =~ ^[Yy]$ ]] && docker system prune -af --volumes 2>/dev/null && echo -e "${GREEN}✅ 清理完成${NC}"
      ;;
    8)
      echo "常用Docker镜像源:"
      echo "1. 阿里云: https://mirrors.aliyun.com"
      echo "2. 腾讯云: https://mirror.ccs.tencentyun.com"
      echo "3. 官方源(默认)"
      read -e -p "选择: " src < /dev/tty
      case "$src" in
        1) mirror="https://mirrors.aliyun.com" ;;
        2) mirror="https://mirror.ccs.tencentyun.com" ;;
        *) mirror="" ;;
      esac
      if [ -n "$mirror" ]; then
        mkdir -p /etc/docker
        echo "{\"registry-mirrors\": [\"$mirror\"]}" > /etc/docker/daemon.json
        systemctl restart docker 2>/dev/null
        echo -e "${GREEN}✅ Docker源已更换${NC}"
      fi
      ;;
    9)
      mkdir -p /etc/docker
      [ ! -f /etc/docker/daemon.json ] && echo '{}' > /etc/docker/daemon.json
      vim /etc/docker/daemon.json < /dev/tty
      systemctl restart docker 2>/dev/null
      ;;
    11)
      mkdir -p /etc/docker
      cat > /etc/docker/daemon.json << 'EOF'
{"ipv6": true, "fixed-cidr-v6": "fd00::/80", "ip6tables": true, "experimental": true}
EOF
      systemctl restart docker 2>/dev/null
      echo -e "${GREEN}✅ Docker IPv6 已开启${NC}"
      ;;
    12)
      mkdir -p /etc/docker
      echo '{}' > /etc/docker/daemon.json
      systemctl restart docker 2>/dev/null
      echo -e "${GREEN}✅ Docker IPv6 已关闭${NC}"
      ;;
    20)
      echo -e "${RED}${BOLD}⚠ 警告: 将卸载Docker并删除所有数据!${NC}"
      read -e -p "确认卸载? 输入 YES: " confirm < /dev/tty
      if [ "$confirm" = "YES" ]; then
        docker stop $(docker ps -q) 2>/dev/null
        apt remove -y docker-ce docker-ce-cli containerd.io docker-compose-plugin 2>/dev/null
        dnf remove -y docker-ce docker-ce-cli containerd.io 2>/dev/null
        rm -rf /var/lib/docker /var/lib/containerd /etc/docker
        echo -e "${GREEN}✅ Docker 已卸载${NC}"
      fi
      ;;
    0) break ;;
    *) echo -e "${RED}无效的输入!${NC}" ;;
  esac
  echo ""
  read -p "按回车键继续..." < /dev/tty
done
