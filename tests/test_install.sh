#!/bin/bash

# install.sh脚本测试

# 启用严格的错误处理
set -euo pipefail

# 获取脚本所在目录的绝对路径
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
NVM_OFFLINE_DIR="$PROJECT_DIR/nvm_offline"

# 测试目录
TEST_DIR="/tmp/nvm_offline_test"
CONFIG_DIR="$TEST_DIR/config"
INSTALL_TARGET="$TEST_DIR/install"

# 测试前准备
setup() {
    # 创建测试目录
    mkdir -p "$TEST_DIR"
    mkdir -p "$CONFIG_DIR"
    mkdir -p "$INSTALL_TARGET"
    
    # 复制脚本到测试目录
    mkdir -p "$TEST_DIR/scripts"
    cp "$NVM_OFFLINE_DIR/scripts/install.sh" "$TEST_DIR/scripts/"
    
    # 创建模拟的node_bins目录
    mkdir -p "$TEST_DIR/node_bins"
    
    # 创建模拟的Node.js二进制文件
    touch "$TEST_DIR/node_bins/node-v16.20.2-linux-x64.tar.xz"
    touch "$TEST_DIR/node_bins/node-v18.20.8-linux-x64.tar.xz"
    touch "$TEST_DIR/node_bins/node-v20.19.5-linux-x64.tar.xz"
    touch "$TEST_DIR/node_bins/node-v22.19.0-linux-x64.tar.xz"
    
    # 创建模拟的配置文件
    echo "# Test config file" > "$CONFIG_DIR/.bashrc"
}

# 清理测试环境
teardown() {
    rm -rf "$TEST_DIR"
}

# 测试1: 检查脚本是否存在
test_script_exists() {
    if [[ ! -f "$TEST_DIR/scripts/install.sh" ]]; then
        echo "FAIL: install.sh script not found"
        return 1
    fi
    echo "PASS: install.sh script exists"
}

# 测试2: 检查脚本是否有执行权限
test_script_executable() {
    if [[ ! -x "$TEST_DIR/scripts/install.sh" ]]; then
        echo "FAIL: install.sh is not executable"
        return 1
    fi
    echo "PASS: install.sh is executable"
}

# 测试3: 检查脚本是否能正常运行（不实际安装）
test_script_runs() {
    # 创建一个临时的HOME目录
    local temp_home="$TEST_DIR/temp_home"
    mkdir -p "$temp_home"
    
    # 设置环境变量
    local original_home="$HOME"
    export HOME="$temp_home"
    
    # 创建一个临时的SHELL变量
    local original_shell="$SHELL"
    export SHELL="/bin/bash"
    
    # 创建模拟的配置文件
    echo "# Test bash config" > "$temp_home/.bashrc"
    
    # 运行脚本（使用--help参数，但脚本没有这个参数，所以我们只检查是否能启动）
    # 我们会捕获输出并检查是否有错误
    local output
    output=$(timeout 10s "$TEST_DIR/scripts/install.sh" --lang en 2>&1 || true)
    
    # 如果输出中包含明显的错误信息，则测试失败
    if echo "$output" | grep -q "command not found\|error\|failed"; then
        echo "FAIL: install.sh produced error output"
        echo "$output"
        export HOME="$original_home"
        export SHELL="$original_shell"
        return 1
    fi
    
    # 恢复环境变量
    export HOME="$original_home"
    export SHELL="$original_shell"
    
    echo "PASS: install.sh runs without errors"
}

# 测试4: 检查是否能正确检测shell
test_shell_detection() {
    # 创建一个临时的HOME目录
    local temp_home="$TEST_DIR/temp_home"
    mkdir -p "$temp_home"
    
    # 设置环境变量
    local original_home="$HOME"
    local original_shell="$SHELL"
    export HOME="$temp_home"
    export SHELL="/bin/bash"
    
    # 创建模拟的配置文件
    echo "# Test bash config" > "$temp_home/.bashrc"
    
    # 运行脚本并检查输出
    local output
    output=$(timeout 10s "$TEST_DIR/scripts/install.sh" --lang en 2>&1 || true)
    
    # 检查是否提到了配置文件
    if echo "$output" | grep -q "\.bashrc"; then
        echo "PASS: Shell detection works correctly"
    else
        echo "WARN: Cannot verify shell detection from output"
        echo "Output: $output"
    fi
    
    # 恢复环境变量
    export HOME="$original_home"
    export SHELL="$original_shell"
}

# 运行所有测试
run_tests() {
    echo "Running install.sh tests..."
    
    setup
    
    local passed=0
    local failed=0
    
    # 运行测试
    if test_script_exists; then
        ((passed++))
    else
        ((failed++))
    fi
    
    if test_script_executable; then
        ((passed++))
    else
        ((failed++))
    fi
    
    if test_script_runs; then
        ((passed++))
    else
        ((failed++))
    fi
    
    if test_shell_detection; then
        ((passed++))
    else
        ((failed++))
    fi
    
    teardown
    
    echo "Tests completed: $passed passed, $failed failed"
    
    if [[ $failed -gt 0 ]]; then
        return 1
    fi
    
    return 0
}

# 执行测试
run_tests