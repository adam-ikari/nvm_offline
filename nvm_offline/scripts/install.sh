#!/bin/bash

# NVM Offline Installer Script

# 启用严格的错误处理
set -euo pipefail

# 默认语言为中文
LANGUAGE="zh"

# 解析命令行参数
while [[ $# -gt 0 ]]; do
    case $1 in
        --lang)
            LANGUAGE="$2"
            shift 2
            ;;
        *)
            shift
            ;;
    esac
done

# 定义消息函数
msg() {
    case $LANGUAGE in
        en) echo "$1" ;;
        zh|*) echo "$2" ;;
    esac
}

# 检测当前使用的shell
detect_shell() {
    # 获取当前shell的路径
    local current_shell
    current_shell=$(ps -p $$ -o comm= 2>/dev/null) || current_shell=""
    
    # 如果无法通过ps获取，则尝试使用环境变量
    if [[ -z "$current_shell" ]]; then
        current_shell="$SHELL"
    fi
    
    # 提取shell名称（移除路径）
    local shell_name
    shell_name=$(basename "$current_shell")
    
    # 根据shell类型设置配置文件路径
    case "$shell_name" in
        bash)
            echo "$HOME/.bashrc"
            ;;
        zsh)
            echo "$HOME/.zshrc"
            ;;
        fish)
            echo "$HOME/.config/fish/config.fish"
            ;;
        *)
            # 默认使用bash配置文件
            echo "$HOME/.bashrc"
            ;;
    esac
}

# 安全地添加环境变量到配置文件
add_to_config() {
    local config_file="$1"
    local nvm_dir="$2"
    
    # 创建配置文件的目录（如果不存在）
    mkdir -p "$(dirname "$config_file")"
    
    # 创建临时文件
    local temp_file
    temp_file=$(mktemp)
    
    # 如果配置文件存在，先复制内容到临时文件
    if [[ -f "$config_file" ]]; then
        cp "$config_file" "$temp_file"
    fi
    
    # 检查是否已存在NVM_OFFLINE_DIR设置
    if ! grep -q "export NVM_OFFLINE_DIR=" "$temp_file" 2>/dev/null; then
        echo "export NVM_OFFLINE_DIR=\"$nvm_dir\"" >> "$temp_file"
    fi
    
    # 检查是否已存在PATH设置
    if ! grep -q "NVM_OFFLINE_DIR.*scripts" "$temp_file" 2>/dev/null; then
        echo "export PATH=\"\$NVM_OFFLINE_DIR/scripts:\$PATH\"" >> "$temp_file"
    fi
    
    # 原子性地移动临时文件到配置文件
    mv "$temp_file" "$config_file"
}

# 定义变量并加引号
INSTALL_DIR="$HOME/.nvm_offline"
CONFIG_FILE=$(detect_shell)

# 创建安装目录
if ! mkdir -p "$INSTALL_DIR"; then
    msg "Failed to create installation directory: $INSTALL_DIR" "创建安装目录失败: $INSTALL_DIR"
    exit 1
fi

# 复制Node.js二进制文件到安装目录
if ! cp -r node_bins "$INSTALL_DIR/"; then
    msg "Failed to copy Node.js binaries" "复制Node.js二进制文件失败"
    exit 1
fi

# 复制脚本到安装目录
if ! cp -r scripts "$INSTALL_DIR/"; then
    msg "Failed to copy scripts" "复制脚本失败"
    exit 1
fi

# 安全地设置环境变量
if ! add_to_config "$CONFIG_FILE" "$INSTALL_DIR"; then
    msg "Failed to update shell configuration file: $CONFIG_FILE" "更新shell配置文件失败: $CONFIG_FILE"
    exit 1
fi

# 显示完成消息
msg "NVM Offline installation completed!" "NVM Offline安装完成！"
msg "Configuration file used: $CONFIG_FILE" "使用的配置文件: $CONFIG_FILE"
msg "Please reload your shell configuration or reopen your terminal to load the environment variables." "请重新加载shell配置或重新打开终端以加载环境变量。"
msg "Then you can use the 'nvm_use <version>' command to switch Node.js versions." "然后可以使用 'nvm_use <version>' 命令切换Node.js版本。"
msg "To switch languages, use the --lang parameter or set the LANGUAGE environment variable to 'en' or 'zh'." "要切换语言，请使用--lang参数或将LANGUAGE环境变量设置为'en'或'zh'。"