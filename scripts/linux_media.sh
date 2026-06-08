#!/bin/bash
# 无风工具箱 - 影视媒体

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
      1) echo -e "${YELLOW}⏳ 停止并移除旧容器...${NC}"
         docker stop "$name" 2>/dev/null; docker rm "$name" 2>/dev/null; docker rmi "$img" 2>/dev/null
         echo -e "${YELLOW}⏳ 拉取最新镜像...${NC}"
         docker pull "$img"
         echo "------------------------"
         eval "$run_cmd"
         echo -e "${GREEN}✅ 更新完成，端口: $port${NC}" ;;
      2) docker stop "$name" 2>/dev/null; docker rm "$name" 2>/dev/null; echo -e "${GREEN}✅ 已卸载${NC}" ;;
      3) docker restart "$name" 2>/dev/null; echo -e "${GREEN}✅ 已重启${NC}" ;;
    esac
  else
    echo -e "状态: ${RED}未安装${NC}"
    echo "1. 安装  0. 返回"
    read -e -p "选择: " c < /dev/tty
    if [ "$c" = "1" ]; then
      command -v docker &>/dev/null || { echo -e "${YELLOW}⏳ 安装 Docker...${NC}"; curl -fsSL https://get.docker.com | sh; systemctl enable docker; systemctl start docker; }
      echo -e "${YELLOW}⏳ 拉取镜像 ${img}...${NC}"
      docker pull "$img"
      echo "------------------------"
      echo -e "${YELLOW}⏳ 创建并启动容器...${NC}"
      eval "$run_cmd"
      echo "------------------------"
      local ip=$(curl -s --max-time 3 ifconfig.me 2>/dev/null || echo "IP")
      echo -e "${GREEN}✅ 安装完成！访问: http://${ip}:${port}${NC}"
    fi
  fi
}


while true; do
  clear
  echo -e "${CYAN}${BOLD}影视媒体${NC}"
  echo -e "${CYAN}------------------------${NC}"
  echo -e "1.   无风影视(MoonTV) ${YELLOW}★${NC}"
  echo -e "2.   Jellyfin媒体管理"
  echo -e "3.   Emby多媒体系统"
  echo -e "4.   Navidrome音乐服务"
  echo -e "5.   小雅Alist全家桶"
  echo -e "${CYAN}------------------------${NC}"
  echo -e "6.   Plex媒体服务器"
  echo -e "7.   Bililive直播录制"
  echo -e "8.   MoviePilot自动追剧 ${YELLOW}★${NC}"
  echo -e "9.   Jackett索引器"
  echo -e "${CYAN}------------------------${NC}"
  echo -e "0.   返回主菜单"
  echo -e "${CYAN}------------------------${NC}"
  read -e -p "请输入你的选择: " choice < /dev/tty

  case "$choice" in
    1)
      clear
      bash <(curl -sL https://raw.githubusercontent.com/xyf0104/MoonTVPlus/main/install.sh)
      ;;
    2) clear; docker_app "jellyfin" "jellyfin/jellyfin:latest" "8096" "Jellyfin媒体管理" \
       "mkdir -p /home/docker/jellyfin/{config,cache,media} && docker run -d --name jellyfin -p 8096:8096 -v /home/docker/jellyfin/config:/config -v /home/docker/jellyfin/cache:/cache -v /home/docker/jellyfin/media:/media --restart always jellyfin/jellyfin:latest" ;;
    3) clear; docker_app "emby" "emby/embyserver:latest" "8920" "Emby多媒体系统" \
       "mkdir -p /home/docker/emby/{config,media} && docker run -d --name emby -p 8920:8096 -v /home/docker/emby/config:/config -v /home/docker/emby/media:/media --restart always emby/embyserver:latest" ;;
    4) clear; docker_app "navidrome" "deluan/navidrome:latest" "4533" "Navidrome音乐服务" \
       "mkdir -p /home/docker/navidrome/{data,music} && docker run -d --name navidrome -p 4533:4533 -v /home/docker/navidrome/data:/data -v /home/docker/navidrome/music:/music --restart always deluan/navidrome:latest" ;;
    5)
      clear
      echo -e "${CYAN}小雅Alist全家桶${NC}"
      bash -c "$(curl http://docker.xiaoya.pro/update_new.sh)" -s
      ;;
    6) clear; docker_app "plex" "lscr.io/linuxserver/plex:latest" "32400" "Plex媒体服务器" \
       "mkdir -p /home/docker/plex/{config,media} && docker run -d --name plex --net host -v /home/docker/plex/config:/config -v /home/docker/plex/media:/media -e PUID=1000 -e PGID=1000 --restart always lscr.io/linuxserver/plex:latest" ;;
    7) clear; docker_app "bililive" "ghcr.io/hr3lxphr6j/bililive-go:latest" "8880" "Bililive直播录制" \
       "mkdir -p /home/docker/bililive/{config,output} && docker run -d --name bililive -p 8880:8080 -v /home/docker/bililive/config:/etc/bililive-go -v /home/docker/bililive/output:/srv/bililive --restart always ghcr.io/hr3lxphr6j/bililive-go:latest" ;;
    8) clear; docker_app "moviepilot" "jxxghp/moviepilot:latest" "3030" "MoviePilot自动追剧" \
       "mkdir -p /home/docker/moviepilot/{config,media} && docker run -d --name moviepilot -p 3030:3000 -v /home/docker/moviepilot/config:/config -v /home/docker/moviepilot/media:/media -e SUPERUSER=admin -e API_TOKEN=moviepilot --restart always jxxghp/moviepilot:latest" ;;
    9) clear; docker_app "jackett" "lscr.io/linuxserver/jackett:latest" "9117" "Jackett索引器" \
       "mkdir -p /home/docker/jackett/config && docker run -d --name jackett -p 9117:9117 -v /home/docker/jackett/config:/config -e PUID=1000 -e PGID=1000 --restart always lscr.io/linuxserver/jackett:latest" ;;
    0) break ;;
    *) echo -e "${RED}无效的输入!${NC}" ;;
  esac
  echo ""
  read -p "按回车键继续..." < /dev/tty
done
