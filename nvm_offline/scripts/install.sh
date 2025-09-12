#!/bin/bash

# NVM Offline Installer Script

# 定义变量
INSTALL_DIR="$HOME/.nvm_offline"

# 创建安装目录
mkdir -p $INSTALL_DIR

# 复制Node.js二进制文件到安装目录
cp -r node_bins $INSTALL_DIR/

# 复制脚本到安装目录
cp -r scripts $INSTALL_DIR/

# 设置环境变量
echo 'export NVM_OFFLINE_DIR="$HOME/.nvm_offline"' >> ~/.bashrc
echo 'export PATH="$NVM_OFFLINE_DIR/scripts:$PATH"' >> ~/.bashrc

# 使环境变量生效
source ~/.bashrc

echo "NVM Offline安装完成！"
echo "请运行 'source ~/.bashrc' 或重新打开终端以使环境变量生效。"
echo "然后可以使用 'nvm_use <version>' 命令切换Node.js版本。"