#!/bin/bash
# ScriptBox - 一键部署脚本
set -e

echo "========== ScriptBox 安装 =========="

# 交互式输入账号密码
read -p "请输入管理员用户名: " SB_USERNAME < /dev/tty
while [ -z "$SB_USERNAME" ]; do
    read -p "用户名不能为空，请重新输入: " SB_USERNAME < /dev/tty
done

read -s -p "请输入管理员密码: " SB_PASSWORD < /dev/tty
echo
while [ -z "$SB_PASSWORD" ]; do
    read -s -p "密码不能为空，请重新输入: " SB_PASSWORD < /dev/tty
    echo
done

# 创建目录
mkdir -p /opt/script-box && cd /opt/script-box

# 克隆/更新代码
if [ -d ".git" ]; then
  git pull
else
  git clone https://github.com/xyf0104/script-box.git .
fi

# 写入环境变量
cat > .env << EOF
SB_USERNAME=${SB_USERNAME}
SB_PASSWORD=${SB_PASSWORD}
EOF
chmod 600 .env

# 构建并启动
docker compose build --no-cache
docker compose up -d

echo ""
echo "✅ ScriptBox 安装完成！"
echo "   管理面板: http://$(curl -s ifconfig.me):3080"
echo "   脚本入口: bash <(curl -sL $(curl -s ifconfig.me):3080/script)"
echo "   用户名: ${SB_USERNAME}"
