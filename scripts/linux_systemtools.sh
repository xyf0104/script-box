#!/bin/bash
# 无风工具箱 - 系统工具

CYAN='\033[0;36m'; GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; NC='\033[0m'; BOLD='\033[1m'

while true; do
  clear
  echo -e "${CYAN}${BOLD}系统工具${NC}"
  echo -e "${CYAN}------------------------${NC}"
  echo -e "1.   修改登录密码                       2.   用户密码登录模式"
  echo -e "3.   安装Python指定版本                 4.   开放所有端口"
  echo -e "5.   修改SSH连接端口                    6.   优化DNS地址"
  echo -e "7.   一键重装系统 ${YELLOW}★${NC}                    8.   禁用ROOT账户创建新账户"
  echo -e "9.   切换优先ipv4/ipv6                  10.  查看端口占用状态"
  echo -e "${CYAN}------------------------${NC}"
  echo -e "11.  修改虚拟内存大小                   12.  用户管理"
  echo -e "13.  用户/密码生成器                     14.  系统时区调整"
  echo -e "15.  防火墙高级管理器                   16.  修改主机名"
  echo -e "17.  切换系统更新源                     18.  定时任务管理"
  echo -e "${CYAN}------------------------${NC}"
  echo -e "21.  本机host解析                       22.  SSH防御程序"
  echo -e "23.  限流自动关机                       24.  用户密钥登录模式"
  echo -e "25.  修复OpenSSH高危漏洞                26.  Linux系统内核参数优化 ${YELLOW}★${NC}"
  echo -e "27.  病毒扫描工具 ${YELLOW}★${NC}                    28.  文件管理器"
  echo -e "${CYAN}------------------------${NC}"
  echo -e "31.  切换系统语言                       32.  命令行美化工具 ${YELLOW}★${NC}"
  echo -e "33.  设置系统回收站                     34.  系统备份与恢复"
  echo -e "35.  硬盘分区管理工具                   36.  命令行历史记录"
  echo -e "37.  系统日志管理工具 ${YELLOW}★${NC}                38.  系统变量管理工具"
  echo -e "${CYAN}------------------------${NC}"
  echo -e "41.  一条龙系统调优 ${YELLOW}★${NC}"
  echo -e "99.  重启服务器"
  echo -e "${CYAN}------------------------${NC}"
  echo -e "0.   返回主菜单"
  echo -e "${CYAN}------------------------${NC}"
  read -e -p "请输入你的选择: " choice < /dev/tty

  case "$choice" in
    1)
      read -e -p "请输入要修改密码的用户名(默认root): " TU < /dev/tty
      TU=${TU:-root}; passwd "$TU"
      ;;
    2)
      sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
      sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
      systemctl restart sshd 2>/dev/null || service sshd restart 2>/dev/null
      echo -e "${GREEN}✅ 已开启密码登录模式${NC}"
      ;;
    3)
      echo "Python版本管理"
      echo "------------------------"
      echo "当前Python: $(python3 --version 2>/dev/null || echo '未安装')"
      read -e -p "请输入Python版本号(如3.12): " PV < /dev/tty
      if [ -n "$PV" ]; then
        apt update && apt install -y software-properties-common 2>/dev/null
        add-apt-repository -y ppa:deadsnakes/ppa 2>/dev/null
        apt update && apt install -y python${PV} python${PV}-venv 2>/dev/null
        update-alternatives --install /usr/bin/python3 python3 /usr/bin/python${PV} 1 2>/dev/null
        echo -e "${GREEN}✅ Python ${PV} 安装完成${NC}"
      fi
      ;;
    4)
      iptables -P INPUT ACCEPT; iptables -P FORWARD ACCEPT; iptables -P OUTPUT ACCEPT
      iptables -F; iptables -X; iptables -Z
      iptables-save > /etc/iptables.rules 2>/dev/null
      echo -e "${GREEN}✅ 已开放所有端口${NC}"
      ;;
    5)
      echo "当前SSH端口: $(grep -E '^Port ' /etc/ssh/sshd_config 2>/dev/null | awk '{print $2}' || echo '22')"
      read -e -p "请输入新的SSH端口号: " NP < /dev/tty
      if [ -n "$NP" ]; then
        sed -i '/^#\?Port /d' /etc/ssh/sshd_config
        echo "Port $NP" >> /etc/ssh/sshd_config
        systemctl restart sshd 2>/dev/null || service sshd restart 2>/dev/null
        echo -e "${GREEN}✅ SSH端口已修改为 $NP${NC}"
      fi
      ;;
    6)
      echo "优化DNS地址"
      echo "1. 国内优化 (阿里+腾讯)"
      echo "2. 国外优化 (Google+Cloudflare)"
      read -e -p "选择: " dns_c < /dev/tty
      case "$dns_c" in
        1) echo -e "nameserver 223.5.5.5\nnameserver 119.29.29.29" > /etc/resolv.conf ;;
        2) echo -e "nameserver 8.8.8.8\nnameserver 1.1.1.1" > /etc/resolv.conf ;;
      esac
      echo -e "${GREEN}✅ DNS已优化${NC}"
      ;;
    7)
      clear
      bash <(curl -sSL https://raw.githubusercontent.com/leitbogioro/Tools/master/Linux_reinstall/InstallNET.sh)
      ;;
    8)
      read -e -p "输入新用户名: " NU < /dev/tty
      if [ -n "$NU" ]; then
        useradd -m -s /bin/bash "$NU"
        passwd "$NU"
        usermod -aG sudo "$NU" 2>/dev/null
        echo -e "${GREEN}✅ 用户 $NU 已创建${NC}"
      fi
      ;;
    9)
      echo "当前优先级:"
      cat /etc/gai.conf 2>/dev/null | grep -v "^#" | head -5
      echo ""
      echo "1. 优先IPv4    2. 优先IPv6    3. 恢复默认"
      read -e -p "选择: " ipc < /dev/tty
      case "$ipc" in
        1) echo "precedence ::ffff:0:0/96  100" >> /etc/gai.conf; echo -e "${GREEN}✅ 已设置优先IPv4${NC}" ;;
        2) sed -i '/precedence ::ffff:0:0\/96/d' /etc/gai.conf; echo -e "${GREEN}✅ 已设置优先IPv6${NC}" ;;
        3) sed -i '/precedence/d' /etc/gai.conf; echo -e "${GREEN}✅ 已恢复默认${NC}" ;;
      esac
      ;;
    10)
      echo -e "${CYAN}端口占用状态:${NC}"
      ss -tulnp 2>/dev/null || netstat -tulnp 2>/dev/null
      ;;
    11)
      echo "当前虚拟内存:"
      free -h | grep -i swap
      echo ""
      read -e -p "输入虚拟内存大小(MB, 输入0关闭): " SM < /dev/tty
      swapoff -a 2>/dev/null; rm -f /swapfile 2>/dev/null
      sed -i '/swapfile/d' /etc/fstab
      if [ "$SM" -gt 0 ] 2>/dev/null; then
        dd if=/dev/zero of=/swapfile bs=1M count=$SM 2>/dev/null
        chmod 600 /swapfile; mkswap /swapfile; swapon /swapfile
        echo '/swapfile none swap sw 0 0' >> /etc/fstab
        echo -e "${GREEN}✅ 虚拟内存已设置为 ${SM}MB${NC}"
      else
        echo -e "${GREEN}✅ 虚拟内存已关闭${NC}"
      fi
      ;;
    12)
      echo -e "${CYAN}用户列表:${NC}"
      awk -F: '$3>=1000{print $1" (UID:"$3")"}' /etc/passwd
      echo ""
      echo "1. 创建用户    2. 删除用户    3. 修改密码"
      read -e -p "选择: " uc < /dev/tty
      case "$uc" in
        1) read -e -p "用户名: " un < /dev/tty; useradd -m -s /bin/bash "$un" && passwd "$un" ;;
        2) read -e -p "用户名: " un < /dev/tty; userdel -r "$un" 2>/dev/null && echo -e "${GREEN}✅ 已删除${NC}" ;;
        3) read -e -p "用户名: " un < /dev/tty; passwd "$un" ;;
      esac
      ;;
    13)
      len=${1:-16}
      user="user$(tr -dc 'a-z0-9' < /dev/urandom | head -c 6)"
      pass=$(tr -dc 'A-Za-z0-9!@#$%' < /dev/urandom | head -c $len)
      echo -e "生成的用户名: ${GREEN}$user${NC}"
      echo -e "生成的密码:   ${GREEN}$pass${NC}"
      ;;
    14)
      echo "当前时区: $(timedatectl show --property=Timezone --value 2>/dev/null || cat /etc/timezone)"
      echo ""
      echo "常用时区:"
      echo "1. Asia/Shanghai    2. Asia/Tokyo    3. America/New_York"
      echo "4. Europe/London    5. UTC"
      read -e -p "选择或输入时区: " tz < /dev/tty
      case "$tz" in
        1) tz="Asia/Shanghai" ;; 2) tz="Asia/Tokyo" ;; 3) tz="America/New_York" ;;
        4) tz="Europe/London" ;; 5) tz="UTC" ;;
      esac
      timedatectl set-timezone "$tz" 2>/dev/null || ln -sf /usr/share/zoneinfo/$tz /etc/localtime
      echo -e "${GREEN}✅ 时区已设置为 $tz${NC}"
      ;;
    15)
      if command -v ufw &>/dev/null; then
        echo "UFW防火墙管理"
        echo "状态: $(ufw status | head -1)"
        echo "1. 开启  2. 关闭  3. 查看规则  4. 添加规则  5. 删除规则"
        read -e -p "选择: " fc < /dev/tty
        case "$fc" in
          1) ufw --force enable ;; 2) ufw disable ;; 3) ufw status numbered ;;
          4) read -e -p "端口号: " fp < /dev/tty; ufw allow "$fp" ;;
          5) ufw status numbered; read -e -p "删除规则编号: " fn < /dev/tty; ufw --force delete "$fn" ;;
        esac
      elif command -v firewall-cmd &>/dev/null; then
        firewall-cmd --list-all
      else
        echo "未检测到防火墙工具，安装ufw..."
        apt install -y ufw 2>/dev/null && echo -e "${GREEN}✅ ufw已安装${NC}"
      fi
      ;;
    16)
      echo "当前主机名: $(hostname)"
      read -e -p "输入新主机名: " nh < /dev/tty
      [ -n "$nh" ] && hostnamectl set-hostname "$nh" 2>/dev/null && echo -e "${GREEN}✅ 主机名已修改为 $nh${NC}"
      ;;
    17)
      echo "切换系统更新源"
      echo "1. 阿里云镜像    2. 腾讯云镜像    3. 清华镜像    4. 恢复默认"
      read -e -p "选择: " mc < /dev/tty
      if [ -f /etc/apt/sources.list ]; then
        cp /etc/apt/sources.list /etc/apt/sources.list.bak
        case "$mc" in
          1) sed -i 's|http://.*archive.ubuntu.com|http://mirrors.aliyun.com|g' /etc/apt/sources.list ;;
          2) sed -i 's|http://.*archive.ubuntu.com|http://mirrors.cloud.tencent.com|g' /etc/apt/sources.list ;;
          3) sed -i 's|http://.*archive.ubuntu.com|http://mirrors.tuna.tsinghua.edu.cn|g' /etc/apt/sources.list ;;
          4) [ -f /etc/apt/sources.list.bak ] && cp /etc/apt/sources.list.bak /etc/apt/sources.list ;;
        esac
        apt update
        echo -e "${GREEN}✅ 更新源已切换${NC}"
      fi
      ;;
    18)
      echo -e "${CYAN}定时任务管理${NC}"
      echo "当前定时任务:"
      crontab -l 2>/dev/null || echo "无"
      echo ""
      echo "1. 编辑定时任务    2. 查看任务    3. 清空所有任务"
      read -e -p "选择: " cc < /dev/tty
      case "$cc" in
        1) crontab -e ;; 2) crontab -l ;; 3) crontab -r && echo -e "${GREEN}✅ 已清空${NC}" ;;
      esac
      ;;
    21)
      echo "本机hosts文件:"
      cat /etc/hosts
      echo ""
      echo "1. 编辑hosts    2. 添加解析    3. 刷新DNS缓存"
      read -e -p "选择: " hc < /dev/tty
      case "$hc" in
        1) vim /etc/hosts < /dev/tty ;;
        2) read -e -p "IP地址: " hip < /dev/tty; read -e -p "域名: " hdn < /dev/tty
           echo "$hip $hdn" >> /etc/hosts && echo -e "${GREEN}✅ 已添加${NC}" ;;
        3) systemd-resolve --flush-caches 2>/dev/null; echo -e "${GREEN}✅ 已刷新${NC}" ;;
      esac
      ;;
    22)
      echo "SSH防御程序"
      echo "1. 安装fail2ban    2. 查看状态    3. 卸载"
      read -e -p "选择: " sc < /dev/tty
      case "$sc" in
        1) apt install -y fail2ban 2>/dev/null || yum install -y fail2ban 2>/dev/null
           systemctl enable fail2ban; systemctl start fail2ban
           echo -e "${GREEN}✅ fail2ban已安装并启动${NC}" ;;
        2) fail2ban-client status 2>/dev/null || echo "未安装" ;;
        3) apt remove -y fail2ban 2>/dev/null; echo -e "${GREEN}✅ 已卸载${NC}" ;;
      esac
      ;;
    23)
      echo "限流自动关机"
      echo "当前月流量: $(cat /proc/net/dev | awk 'NR>2{rx+=$2;tx+=$10}END{printf "%.2fGB\n",(rx+tx)/1024/1024/1024}')"
      read -e -p "设置流量上限(GB, 0=取消): " limit < /dev/tty
      if [ "$limit" -gt 0 ] 2>/dev/null; then
        echo "*/5 * * * * root bash -c 'used=\$(cat /proc/net/dev | awk \"NR>2{rx+=\\\$2;tx+=\\\$10}END{printf \\\"%.0f\\\",(rx+tx)/1024/1024/1024}\"); [ \$used -ge $limit ] && shutdown -h now'" > /etc/cron.d/traffic_limit
        echo -e "${GREEN}✅ 已设置 ${limit}GB 流量限制${NC}"
      else
        rm -f /etc/cron.d/traffic_limit
        echo -e "${GREEN}✅ 已取消限流${NC}"
      fi
      ;;
    24)
      echo "用户密钥登录模式"
      echo "1. 生成密钥对    2. 查看公钥    3. 禁用密码登录(仅密钥)"
      read -e -p "选择: " kc < /dev/tty
      case "$kc" in
        1) ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N "" < /dev/tty
           echo -e "${GREEN}✅ 密钥已生成${NC}" ;;
        2) cat ~/.ssh/*.pub 2>/dev/null || echo "无公钥" ;;
        3) sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
           systemctl restart sshd 2>/dev/null
           echo -e "${GREEN}✅ 已禁用密码登录${NC}" ;;
      esac
      ;;
    25)
      echo "修复OpenSSH高危漏洞 - 更新到最新版本"
      apt update && apt install -y --only-upgrade openssh-server 2>/dev/null
      echo -e "当前版本: $(ssh -V 2>&1)"
      echo -e "${GREEN}✅ OpenSSH已更新${NC}"
      ;;
    26)
      echo -e "${CYAN}Linux系统内核参数优化${NC}"
      cat > /etc/sysctl.d/99-optimize.conf << 'SYSEOF'
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
net.ipv4.tcp_fastopen=3
net.core.rmem_max=16777216
net.core.wmem_max=16777216
net.ipv4.tcp_rmem=4096 87380 16777216
net.ipv4.tcp_wmem=4096 65536 16777216
net.ipv4.tcp_max_syn_backlog=8192
net.core.somaxconn=32768
net.ipv4.tcp_slow_start_after_idle=0
net.ipv4.tcp_tw_reuse=1
net.ipv4.ip_local_port_range=1024 65535
fs.file-max=1000000
fs.inotify.max_user_instances=8192
SYSEOF
      sysctl -p /etc/sysctl.d/99-optimize.conf
      echo -e "${GREEN}✅ 内核参数已优化${NC}"
      ;;
    27)
      echo "病毒扫描工具"
      if ! command -v clamscan &>/dev/null; then
        echo "正在安装ClamAV..."
        apt install -y clamav 2>/dev/null || yum install -y clamav 2>/dev/null
        freshclam 2>/dev/null
      fi
      read -e -p "扫描路径(默认/): " sp < /dev/tty
      sp=${sp:-/}
      clamscan -r --infected "$sp" 2>/dev/null
      ;;
    28)
      if command -v ranger &>/dev/null; then ranger < /dev/tty
      elif command -v mc &>/dev/null; then mc < /dev/tty
      else
        echo "安装文件管理器..."
        apt install -y ranger 2>/dev/null && ranger < /dev/tty
      fi
      ;;
    31)
      echo "切换系统语言"
      echo "1. 中文    2. English    3. 日本語"
      read -e -p "选择: " lc < /dev/tty
      case "$lc" in
        1) localectl set-locale LANG=zh_CN.UTF-8 2>/dev/null ;;
        2) localectl set-locale LANG=en_US.UTF-8 2>/dev/null ;;
        3) localectl set-locale LANG=ja_JP.UTF-8 2>/dev/null ;;
      esac
      echo -e "${GREEN}✅ 语言已切换,重新登录生效${NC}"
      ;;
    32)
      clear
      bash <(curl -sL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh) --unattended < /dev/tty
      echo -e "${GREEN}✅ Oh My Zsh 已安装${NC}"
      ;;
    33)
      echo "设置系统回收站"
      mkdir -p ~/.trash
      if ! grep -q "trash" ~/.bashrc 2>/dev/null; then
        echo 'alias rm="mv -t ~/.trash"' >> ~/.bashrc
        echo 'alias trash-clean="rm -rf ~/.trash/*"' >> ~/.bashrc
        echo 'alias trash-list="ls ~/.trash"' >> ~/.bashrc
        source ~/.bashrc 2>/dev/null
        echo -e "${GREEN}✅ 回收站已设置 (rm=移入回收站, trash-clean=清空)${NC}"
      else
        echo "回收站已配置"
      fi
      ;;
    34)
      echo "系统备份与恢复"
      echo "1. 备份系统    2. 恢复系统"
      read -e -p "选择: " bc < /dev/tty
      case "$bc" in
        1) tar czpf /backup_$(date +%Y%m%d).tar.gz --exclude=/proc --exclude=/sys --exclude=/dev --exclude=/run --exclude=/tmp --exclude=/backup* / 2>/dev/null
           echo -e "${GREEN}✅ 备份完成: /backup_$(date +%Y%m%d).tar.gz${NC}" ;;
        2) read -e -p "备份文件路径: " bf < /dev/tty
           [ -f "$bf" ] && tar xzpf "$bf" -C / && echo -e "${GREEN}✅ 恢复完成${NC}" ;;
      esac
      ;;
    35)
      lsblk -f
      echo ""
      echo "1. fdisk分区    2. 格式化    3. 挂载"
      read -e -p "选择: " dc < /dev/tty
      case "$dc" in
        1) read -e -p "设备(如/dev/sdb): " dev < /dev/tty; fdisk "$dev" < /dev/tty ;;
        2) read -e -p "分区(如/dev/sdb1): " part < /dev/tty; mkfs.ext4 "$part" ;;
        3) read -e -p "分区: " part < /dev/tty; read -e -p "挂载点: " mp < /dev/tty
           mkdir -p "$mp"; mount "$part" "$mp"
           echo "$part $mp ext4 defaults 0 0" >> /etc/fstab ;;
      esac
      ;;
    36)
      echo -e "${CYAN}命令行历史记录 (最近50条):${NC}"
      history 50 2>/dev/null || cat ~/.bash_history 2>/dev/null | tail -50
      ;;
    37)
      echo -e "${CYAN}系统日志管理${NC}"
      echo "日志磁盘占用: $(journalctl --disk-usage 2>/dev/null)"
      echo ""
      echo "1. 查看系统日志    2. 查看启动日志    3. 清理日志"
      read -e -p "选择: " lc < /dev/tty
      case "$lc" in
        1) journalctl --no-pager -n 50 ;;
        2) journalctl -b --no-pager -n 30 ;;
        3) journalctl --vacuum-time=1d; echo -e "${GREEN}✅ 日志已清理(保留1天)${NC}" ;;
      esac
      ;;
    38)
      echo -e "${CYAN}系统变量:${NC}"
      env | head -30
      echo ""
      echo "1. 添加变量    2. 删除变量    3. 编辑profile"
      read -e -p "选择: " vc < /dev/tty
      case "$vc" in
        1) read -e -p "变量名=值: " vv < /dev/tty; echo "export $vv" >> /etc/profile; source /etc/profile ;;
        2) read -e -p "变量名: " vn < /dev/tty; sed -i "/$vn/d" /etc/profile ;;
        3) vim /etc/profile < /dev/tty ;;
      esac
      ;;
    41)
      echo -e "${CYAN}一条龙系统调优${NC}"
      echo "将执行: DNS优化 + 内核参数优化 + BBR开启 + 虚拟内存设置"
      read -e -p "确认执行? [y/N]: " confirm < /dev/tty
      if [[ "$confirm" =~ ^[Yy]$ ]]; then
        echo -e "nameserver 8.8.8.8\nnameserver 1.1.1.1" > /etc/resolv.conf
        echo -e "${GREEN}[1/4] DNS已优化${NC}"
        cat > /etc/sysctl.d/99-optimize.conf << 'EOF'
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
net.ipv4.tcp_fastopen=3
net.core.rmem_max=16777216
net.core.wmem_max=16777216
fs.file-max=1000000
EOF
        sysctl -p /etc/sysctl.d/99-optimize.conf > /dev/null 2>&1
        echo -e "${GREEN}[2/4] 内核参数已优化+BBR已开启${NC}"
        swapoff -a 2>/dev/null; rm -f /swapfile
        dd if=/dev/zero of=/swapfile bs=1M count=1024 2>/dev/null
        chmod 600 /swapfile; mkswap /swapfile; swapon /swapfile
        grep -q swapfile /etc/fstab || echo '/swapfile none swap sw 0 0' >> /etc/fstab
        echo -e "${GREEN}[3/4] 1GB虚拟内存已设置${NC}"
        apt update -qq && apt upgrade -y -qq 2>/dev/null
        echo -e "${GREEN}[4/4] 系统已更新${NC}"
        echo -e "${GREEN}${BOLD}✅ 一条龙调优完成！${NC}"
      fi
      ;;
    99)
      read -e -p "确认重启服务器? [y/N]: " confirm < /dev/tty
      [[ "$confirm" =~ ^[Yy]$ ]] && reboot
      ;;
    0) break ;;
    *) echo -e "${RED}无效的输入!${NC}" ;;
  esac
  echo ""
  read -p "按回车键继续..." < /dev/tty
done
