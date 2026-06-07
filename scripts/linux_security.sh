#!/bin/bash
# 无风工具箱 - 网络安全

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
  echo -e "${CYAN}${BOLD}网络安全${NC}"
  echo -e "${CYAN}------------------------${NC}"
  echo -e "1.   WARP管理"
  echo -e "2.   DDNS-Go动态DNS"
  echo -e "3.   FRP内网穿透(服务端) ${YELLOW}★${NC}"
  echo -e "4.   FRP内网穿透(客户端) ${YELLOW}★${NC}"
  echo -e "5.   Bitwarden密码管理"
  echo -e "6.   RustDesk远程桌面(服务端) ${YELLOW}★${NC}"
  echo -e "7.   RustDesk远程桌面(中继端) ${YELLOW}★${NC}"
  echo -e "8.   雷池WAF防火墙"
  echo -e "${CYAN}------------------------${NC}"
  echo -e "11.  fail2ban SSH防御"
  echo -e "12.  CrowdSec安全引擎"
  echo -e "13.  SSL证书管理"
  echo -e "${CYAN}------------------------${NC}"
  echo -e "0.   返回主菜单"
  echo -e "${CYAN}------------------------${NC}"
  read -e -p "请输入你的选择: " choice < /dev/tty

  case "$choice" in
    1)
      clear
      bash <(curl -sSL https://gitlab.com/fscarmen/warp/-/raw/main/menu.sh)
      ;;
    2) clear; docker_app "ddns-go" "jeessy/ddns-go:latest" "9876" "DDNS-Go动态DNS" \
       "docker run -d --name ddns-go --restart always --net host -v /home/docker/ddns-go:/root jeessy/ddns-go:latest" ;;
    3)
      clear
      echo -e "${CYAN}FRP内网穿透 - 服务端${NC}"
      if [ -d /home/docker/frps ]; then
        echo -e "状态: ${GREEN}已安装${NC}"
        echo "1. 查看配置  2. 重启  3. 卸载  0. 返回"
        read -e -p "选择: " c < /dev/tty
        case "$c" in
          1) cat /home/docker/frps/frps.toml 2>/dev/null ;;
          2) docker restart frps 2>/dev/null; echo -e "${GREEN}✅ 已重启${NC}" ;;
          3) docker stop frps 2>/dev/null; docker rm frps 2>/dev/null; rm -rf /home/docker/frps; echo -e "${GREEN}✅ 已卸载${NC}" ;;
        esac
      else
        read -e -p "设置绑定端口(默认7000): " bp < /dev/tty; bp=${bp:-7000}
        read -e -p "设置面板端口(默认7500): " dp < /dev/tty; dp=${dp:-7500}
        read -e -p "设置token: " token < /dev/tty; token=${token:-$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 16)}
        mkdir -p /home/docker/frps
        cat > /home/docker/frps/frps.toml << EOF
bindPort = $bp
webServer.addr = "0.0.0.0"
webServer.port = $dp
auth.token = "$token"
EOF
        docker run -d --name frps --restart always --net host -v /home/docker/frps/frps.toml:/etc/frp/frps.toml snowdreamtech/frps
        echo -e "${GREEN}✅ FRP服务端已安装${NC}"
        echo -e "绑定端口: $bp  面板: $dp  Token: $token"
      fi
      ;;
    4)
      clear
      echo -e "${CYAN}FRP内网穿透 - 客户端${NC}"
      if [ -d /home/docker/frpc ]; then
        echo -e "状态: ${GREEN}已安装${NC}"
        echo "1. 查看配置  2. 编辑配置  3. 重启  4. 卸载  0. 返回"
        read -e -p "选择: " c < /dev/tty
        case "$c" in
          1) cat /home/docker/frpc/frpc.toml 2>/dev/null ;;
          2) vim /home/docker/frpc/frpc.toml < /dev/tty; docker restart frpc ;;
          3) docker restart frpc 2>/dev/null ;;
          4) docker stop frpc 2>/dev/null; docker rm frpc 2>/dev/null; rm -rf /home/docker/frpc; echo -e "${GREEN}✅ 已卸载${NC}" ;;
        esac
      else
        read -e -p "服务端IP: " sip < /dev/tty
        read -e -p "服务端端口(默认7000): " sp < /dev/tty; sp=${sp:-7000}
        read -e -p "Token: " token < /dev/tty
        mkdir -p /home/docker/frpc
        cat > /home/docker/frpc/frpc.toml << EOF
serverAddr = "$sip"
serverPort = $sp
auth.token = "$token"

[[proxies]]
name = "ssh"
type = "tcp"
localIP = "127.0.0.1"
localPort = 22
remotePort = 6000
EOF
        echo -e "${YELLOW}请编辑配置添加更多代理:${NC}"
        vim /home/docker/frpc/frpc.toml < /dev/tty
        docker run -d --name frpc --restart always --net host -v /home/docker/frpc/frpc.toml:/etc/frp/frpc.toml snowdreamtech/frpc
        echo -e "${GREEN}✅ FRP客户端已安装${NC}"
      fi
      ;;
    5) clear; docker_app "vaultwarden" "vaultwarden/server:latest" "8200" "Bitwarden密码管理" \
       "docker run -d --name vaultwarden -p 8200:80 -v /home/docker/vaultwarden:/data --restart always vaultwarden/server:latest" ;;
    6) clear; docker_app "rustdesk-server" "rustdesk/rustdesk-server:latest" "21115-21119" "RustDesk远程桌面服务端" \
       "mkdir -p /home/docker/rustdesk && docker run -d --name rustdesk-server -p 21115:21115 -p 21116:21116 -p 21116:21116/udp -p 21117:21117 -p 21118:21118 -p 21119:21119 -v /home/docker/rustdesk:/root --restart always rustdesk/rustdesk-server:latest hbbs" ;;
    7) clear; docker_app "rustdesk-relay" "rustdesk/rustdesk-server:latest" "21117" "RustDesk远程桌面中继端" \
       "docker run -d --name rustdesk-relay -p 21117:21117 -p 21119:21119 -v /home/docker/rustdesk:/root --restart always rustdesk/rustdesk-server:latest hbbr" ;;
    8)
      clear
      bash -c "$(curl -fsSLk https://waf-ce.chaitin.cn/release/latest/setup.sh)"
      ;;
    11)
      clear
      echo -e "${CYAN}fail2ban SSH防御${NC}"
      echo "1. 安装  2. 查看状态  3. 查看封禁列表  4. 卸载"
      read -e -p "选择: " c < /dev/tty
      case "$c" in
        1) apt install -y fail2ban 2>/dev/null || yum install -y fail2ban 2>/dev/null
           systemctl enable fail2ban; systemctl start fail2ban; echo -e "${GREEN}✅ 已安装${NC}" ;;
        2) fail2ban-client status sshd 2>/dev/null ;;
        3) fail2ban-client status sshd 2>/dev/null | grep "Banned IP" ;;
        4) apt remove -y fail2ban 2>/dev/null; echo -e "${GREEN}✅ 已卸载${NC}" ;;
      esac
      ;;
    12) clear; docker_app "crowdsec" "crowdsecurity/crowdsec:latest" "8080" "CrowdSec安全引擎" \
       "docker run -d --name crowdsec -p 8080:8080 -v /home/docker/crowdsec/config:/etc/crowdsec -v /home/docker/crowdsec/data:/var/lib/crowdsec/data -v /var/log:/var/log:ro --restart always crowdsecurity/crowdsec:latest" ;;
    13)
      clear
      echo -e "${CYAN}SSL证书管理${NC}"
      echo "1. ACME.sh 申请证书"
      echo "2. 查看已有证书"
      read -e -p "选择: " c < /dev/tty
      case "$c" in
        1) bash <(curl -Ls https://raw.githubusercontent.com/yonggekkk/acme-yg/main/acme.sh) ;;
        2) ls -la /root/.acme.sh/ 2>/dev/null || echo "未安装acme.sh" ;;
      esac
      ;;
    0) break ;;
    *) echo -e "${RED}无效的输入!${NC}" ;;
  esac
  echo ""
  read -p "按回车键继续..." < /dev/tty
done
