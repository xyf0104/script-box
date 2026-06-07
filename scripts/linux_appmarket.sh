#!/bin/bash
# 无风工具箱 - 应用市场

CYAN='\033[0;36m'; GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; NC='\033[0m'; BOLD='\033[1m'

docker_app() {
  local name=$1 img=$2 port=$3 desc=$4 run_cmd=$5
  echo -e "${CYAN}${BOLD}$name${NC}"
  echo "$desc"
  echo "------------------------"
  if docker ps -a --format '{{.Names}}' 2>/dev/null | grep -q "^${name}$"; then
    local status=$(docker inspect -f '{{.State.Status}}' "$name" 2>/dev/null)
    echo -e "状态: ${GREEN}已安装 ($status)${NC}"
    echo ""
    echo "1. 更新    2. 卸载    3. 重启    0. 返回"
    read -e -p "选择: " c < /dev/tty
    case "$c" in
      1) docker stop "$name" 2>/dev/null; docker rm "$name" 2>/dev/null; docker rmi "$img" 2>/dev/null
         eval "$run_cmd"; echo -e "${GREEN}✅ 已更新${NC}" ;;
      2) docker stop "$name" 2>/dev/null; docker rm "$name" 2>/dev/null
         echo -e "${GREEN}✅ 已卸载${NC}" ;;
      3) docker restart "$name" 2>/dev/null; echo -e "${GREEN}✅ 已重启${NC}" ;;
    esac
  else
    echo -e "状态: ${RED}未安装${NC}"
    echo ""
    echo "1. 安装    0. 返回"
    read -e -p "选择: " c < /dev/tty
    if [ "$c" = "1" ]; then
      if ! command -v docker &>/dev/null; then
        echo "正在安装Docker..."; curl -fsSL https://get.docker.com | sh
        systemctl enable docker; systemctl start docker
      fi
      eval "$run_cmd"
      echo -e "${GREEN}✅ 已安装，访问端口: $port${NC}"
    fi
  fi
}

while true; do
  clear
  echo -e "${CYAN}${BOLD}应用市场${NC}"
  echo -e "${CYAN}------------------------${NC}"
  echo -e "1.   宝塔面板官方版                    2.   aaPanel宝塔国际版"
  echo -e "3.   1Panel新一代管理面板               4.   NginxProxyManager可视化面板"
  echo -e "5.   OpenList多存储文件列表             6.   Ubuntu远程桌面网页版"
  echo -e "7.   哪吒探针VPS监控面板                8.   QB离线BT磁力下载面板"
  echo -e "9.   Poste.io邮件服务器                 10.  RocketChat聊天系统"
  echo -e "${CYAN}------------------------${NC}"
  echo -e "11.  禅道项目管理                       12.  青龙面板定时任务"
  echo -e "13.  Cloudreve网盘 ${YELLOW}★${NC}                   14.  简单图床"
  echo -e "15.  Emby多媒体管理                     16.  Speedtest测速面板"
  echo -e "17.  AdGuardHome去广告                  18.  OnlyOffice在线办公"
  echo -e "19.  雷池WAF防火墙                      20.  Portainer容器管理"
  echo -e "${CYAN}------------------------${NC}"
  echo -e "21.  VScode网页版                       22.  UptimeKuma监控工具"
  echo -e "23.  Memos备忘录                        24.  Webtop远程桌面 ${YELLOW}★${NC}"
  echo -e "25.  Nextcloud网盘                      26.  QD-Today定时任务"
  echo -e "27.  Dockge容器堆栈管理                 28.  LibreSpeed测速"
  echo -e "29.  Searxng聚合搜索 ${YELLOW}★${NC}                 30.  PhotoPrism相册"
  echo -e "${CYAN}------------------------${NC}"
  echo -e "31.  StirlingPDF工具                    32.  DrawIO在线图表 ${YELLOW}★${NC}"
  echo -e "33.  Sun-Panel导航面板                  34.  Pingvin-Share文件分享"
  echo -e "35.  极简朋友圈                         36.  LobeChat聊天聚合"
  echo -e "37.  MyIP工具箱 ${YELLOW}★${NC}                      38.  小雅Alist全家桶"
  echo -e "${CYAN}------------------------${NC}"
  echo -e "0.   返回主菜单"
  echo -e "${CYAN}------------------------${NC}"
  read -e -p "请输入你的选择: " choice < /dev/tty

  case "$choice" in
    1) clear; if [ -f /usr/bin/curl ];then curl -sSO https://download.bt.cn/install/install_panel.sh;else wget -O install_panel.sh https://download.bt.cn/install/install_panel.sh;fi;bash install_panel.sh ed8484bec ;;
    2) clear; URL="https://www.aapanel.com/script/install_7.0_en.sh"; if [ -f /usr/bin/curl ];then curl -ksSO "$URL";else wget --no-check-certificate -O install_7.0_en.sh "$URL";fi;bash install_7.0_en.sh aapanel ;;
    3) clear; bash -c "$(curl -sSL https://resource.fit2cloud.com/1panel/package/v2/quick_start.sh)" ;;
    4) clear; docker_app "npm" "jc21/nginx-proxy-manager:latest" "81" "Nginx反向代理管理面板 | 初始: admin@example.com / changeme" \
       "docker run -d --name npm -p 80:80 -p 81:81 -p 443:443 -v /home/docker/npm/data:/data -v /home/docker/npm/letsencrypt:/etc/letsencrypt --restart always jc21/nginx-proxy-manager:latest" ;;
    5) clear; docker_app "openlist" "openlistteam/openlist:latest-aria2" "5244" "多存储文件列表程序" \
       "mkdir -p /home/docker/openlist && docker run -d --name openlist -p 5244:5244 -v /home/docker/openlist:/opt/openlist/data --restart always openlistteam/openlist:latest-aria2 && docker exec openlist ./openlist admin random" ;;
    6) clear; docker_app "webtop-ubuntu" "lscr.io/linuxserver/webtop:ubuntu-kde" "3006" "Ubuntu远程桌面网页版" \
       "docker run -d --name webtop-ubuntu -p 3006:3000 -v /home/docker/webtop:/config -e PUID=1000 -e PGID=1000 --restart always --shm-size=1gb lscr.io/linuxserver/webtop:ubuntu-kde" ;;
    7) clear; curl -L https://raw.githubusercontent.com/naiba/nezha/master/script/install.sh -o nezha.sh && chmod +x nezha.sh && bash nezha.sh ;;
    8) clear; docker_app "qbittorrent" "lscr.io/linuxserver/qbittorrent:latest" "8081" "QB离线BT磁力下载" \
       "docker run -d --name qbittorrent -p 8081:8080 -p 6881:6881 -p 6881:6881/udp -v /home/docker/qb/config:/config -v /home/docker/qb/downloads:/downloads -e PUID=1000 -e PGID=1000 --restart always lscr.io/linuxserver/qbittorrent:latest" ;;
    9) clear; docker_app "poste" "analogic/poste.io" "8280" "邮件服务器" \
       "docker run -d --name poste -p 8280:80 -p 25:25 -p 110:110 -p 143:143 -p 465:465 -p 587:587 -p 993:993 -p 995:995 -v /home/docker/poste:/data --restart always analogic/poste.io" ;;
    10) clear; docker_app "rocketchat" "registry.rocket.chat/rocketchat/rocket.chat:latest" "3100" "多人聊天系统" \
       "docker run -d --name rocketchat -p 3100:3000 -v /home/docker/rocketchat:/app/uploads --restart always registry.rocket.chat/rocketchat/rocket.chat:latest" ;;
    11) clear; docker_app "zentao" "easysoft/zentao:latest" "8084" "禅道项目管理" \
       "docker run -d --name zentao -p 8084:80 -v /home/docker/zentao:/data --restart always easysoft/zentao:latest" ;;
    12) clear; docker_app "qinglong" "whyour/qinglong:latest" "5700" "青龙面板定时任务" \
       "docker run -d --name qinglong -p 5700:5700 -v /home/docker/qinglong:/ql/data --restart always whyour/qinglong:latest" ;;
    13) clear; docker_app "cloudreve" "cloudreve/cloudreve:latest" "5212" "Cloudreve网盘" \
       "mkdir -p /home/docker/cloudreve/{uploads,avatar,config,db} && docker run -d --name cloudreve -p 5212:5212 -v /home/docker/cloudreve/uploads:/cloudreve/uploads -v /home/docker/cloudreve/config:/cloudreve/config -v /home/docker/cloudreve/db:/cloudreve/db -v /home/docker/cloudreve/avatar:/cloudreve/avatar --restart always cloudreve/cloudreve:latest" ;;
    14) clear; docker_app "easyimage" "ddsderek/easyimage:latest" "8085" "简单图床" \
       "docker run -d --name easyimage -p 8085:80 -v /home/docker/easyimage:/app/web/config --restart always ddsderek/easyimage:latest" ;;
    15) clear; docker_app "emby" "emby/embyserver:latest" "8920" "Emby多媒体管理" \
       "docker run -d --name emby -p 8920:8096 -v /home/docker/emby/config:/config -v /home/docker/emby/media:/media --restart always emby/embyserver:latest" ;;
    16) clear; docker_app "speedtest" "ghcr.io/librespeed/speedtest:latest" "6681" "Speedtest测速面板" \
       "docker run -d --name speedtest -p 6681:80 --restart always ghcr.io/librespeed/speedtest:latest" ;;
    17) clear; docker_app "adguardhome" "adguard/adguardhome:latest" "3000" "AdGuardHome去广告" \
       "docker run -d --name adguardhome -p 3000:3000 -p 53:53/tcp -p 53:53/udp -v /home/docker/adguard/work:/opt/adguardhome/work -v /home/docker/adguard/conf:/opt/adguardhome/conf --restart always adguard/adguardhome:latest" ;;
    18) clear; docker_app "onlyoffice" "onlyoffice/documentserver:latest" "8082" "OnlyOffice在线办公" \
       "docker run -d --name onlyoffice -p 8082:80 -v /home/docker/onlyoffice:/var/www/onlyoffice/Data --restart always onlyoffice/documentserver:latest" ;;
    19) clear; bash -c "$(curl -fsSLk https://waf-ce.chaitin.cn/release/latest/setup.sh)" ;;
    20) clear; docker_app "portainer" "portainer/portainer-ce:latest" "9000" "Portainer容器管理" \
       "docker volume create portainer_data && docker run -d --name portainer -p 9000:9000 -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data --restart always portainer/portainer-ce:latest" ;;
    21) clear; docker_app "code-server" "lscr.io/linuxserver/code-server:latest" "8443" "VScode网页版" \
       "docker run -d --name code-server -p 8443:8443 -v /home/docker/code-server:/config -e PUID=1000 -e PGID=1000 --restart always lscr.io/linuxserver/code-server:latest" ;;
    22) clear; docker_app "uptime-kuma" "louislam/uptime-kuma:latest" "3001" "UptimeKuma监控" \
       "docker run -d --name uptime-kuma -p 3001:3001 -v /home/docker/uptime-kuma:/app/data --restart always louislam/uptime-kuma:latest" ;;
    23) clear; docker_app "memos" "neosmemo/memos:stable" "5230" "Memos备忘录" \
       "docker run -d --name memos -p 5230:5230 -v /home/docker/memos:/var/opt/memos --restart always neosmemo/memos:stable" ;;
    24) clear; docker_app "webtop" "lscr.io/linuxserver/webtop:ubuntu-kde" "3006" "Webtop远程桌面" \
       "docker run -d --name webtop -p 3006:3000 -v /home/docker/webtop:/config -e PUID=1000 -e PGID=1000 --shm-size=1gb --restart always lscr.io/linuxserver/webtop:ubuntu-kde" ;;
    25) clear; docker_app "nextcloud" "nextcloud:latest" "8989" "Nextcloud网盘" \
       "docker run -d --name nextcloud -p 8989:80 -v /home/docker/nextcloud:/var/www/html --restart always nextcloud:latest" ;;
    26) clear; docker_app "qd-today" "qdtoday/qd:latest" "8923" "QD-Today定时任务" \
       "docker run -d --name qd-today -p 8923:80 -v /home/docker/qd-today:/usr/src/app/config --restart always qdtoday/qd:latest" ;;
    27) clear; docker_app "dockge" "louislam/dockge:latest" "5001" "Dockge容器堆栈管理" \
       "mkdir -p /opt/stacks /opt/dockge && docker run -d --name dockge -p 5001:5001 -v /var/run/docker.sock:/var/run/docker.sock -v /opt/dockge:/app/data -v /opt/stacks:/opt/stacks -e DOCKGE_STACKS_DIR=/opt/stacks --restart always louislam/dockge:latest" ;;
    28) clear; docker_app "librespeed" "lscr.io/linuxserver/librespeed:latest" "6680" "LibreSpeed测速" \
       "docker run -d --name librespeed -p 6680:80 --restart always lscr.io/linuxserver/librespeed:latest" ;;
    29) clear; docker_app "searxng" "searxng/searxng:latest" "8880" "Searxng聚合搜索" \
       "docker run -d --name searxng -p 8880:8080 -v /home/docker/searxng:/etc/searxng --restart always searxng/searxng:latest" ;;
    30) clear; docker_app "photoprism" "photoprism/photoprism:latest" "2342" "PhotoPrism相册" \
       "docker run -d --name photoprism -p 2342:2342 -v /home/docker/photoprism/storage:/photoprism/storage -v /home/docker/photoprism/originals:/photoprism/originals -e PHOTOPRISM_ADMIN_PASSWORD=admin --restart always photoprism/photoprism:latest" ;;
    31) clear; docker_app "stirlingpdf" "frooodle/s-pdf:latest" "8088" "StirlingPDF工具" \
       "docker run -d --name stirlingpdf -p 8088:8080 -v /home/docker/stirlingpdf:/usr/share/tessdata --restart always frooodle/s-pdf:latest" ;;
    32) clear; docker_app "drawio" "jgraph/drawio:latest" "8686" "DrawIO在线图表" \
       "docker run -d --name drawio -p 8686:8080 --restart always jgraph/drawio:latest" ;;
    33) clear; docker_app "sun-panel" "hslr/sun-panel:latest" "3002" "Sun-Panel导航面板" \
       "docker run -d --name sun-panel -p 3002:3002 -v /home/docker/sun-panel:/app/conf --restart always hslr/sun-panel:latest" ;;
    34) clear; docker_app "pingvin-share" "stonith404/pingvin-share:latest" "3050" "Pingvin文件分享" \
       "docker run -d --name pingvin-share -p 3050:3000 -v /home/docker/pingvin:/opt/app/backend/data --restart always stonith404/pingvin-share:latest" ;;
    35) clear; docker_app "moments" "mblog/moments:latest" "8781" "极简朋友圈" \
       "docker run -d --name moments -p 8781:3000 -v /home/docker/moments:/app/data --restart always mblog/moments:latest" ;;
    36) clear; docker_app "lobe-chat" "lobehub/lobe-chat:latest" "3210" "LobeChat聊天聚合" \
       "docker run -d --name lobe-chat -p 3210:3210 --restart always lobehub/lobe-chat:latest" ;;
    37) clear; docker_app "myip" "ghcr.io/jason5ng32/myip:latest" "18966" "MyIP工具箱" \
       "docker run -d --name myip -p 18966:18966 --restart always ghcr.io/jason5ng32/myip:latest" ;;
    38) clear; bash -c "$(curl http://docker.xiaoya.pro/update_new.sh)" -s ;;
    0) break ;;
    *) echo -e "${RED}无效的输入!${NC}" ;;
  esac
  echo ""
  read -p "按回车键继续..." < /dev/tty
done
