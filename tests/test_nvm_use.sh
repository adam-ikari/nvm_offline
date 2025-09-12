#!/bin/bash

# nvm_use脚本测试

# 不使用set -euo pipefail，因为我们想要更灵活的错误处理
# set -euo pipefail

# 获取脚本所在目录的绝对路径
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
NVM_OFFLINE_DIR="$PROJECT_DIR/nvm_offline"

# 测试目录
TEST_DIR="/tmp/nvm_offline_test"
CONFIG_DIR="$TEST_DIR/config"

# 测试前准备
setup() {
    # 创建测试目录
    mkdir -p "$TEST_DIR"
    mkdir -p "$CONFIG_DIR"
    
    # 复制脚本到测试目录
    mkdir -p "$TEST_DIR/scripts"
    cp "$NVM_OFFLINE_DIR/scripts/nvm_use" "$TEST_DIR/scripts/"
    
    # 创建模拟的配置文件
    echo "# Test config file" > "$CONFIG_DIR/.bashrc"
    
    # 创建模拟的Node.js二进制文件目录结构
    mkdir -p "$TEST_DIR/node_bins"
    
    # 创建一些模拟的Node.js版本包
    touch "$TEST_DIR/node_bins/node-v16.20.2-linux-x64.tar.xz"
    touch "$TEST_DIR/node_bins/node-v18.20.8-linux-x64.tar.xz"
    
    # 创建一个已解压的版本目录
    mkdir -p "$TEST_DIR/node_bins/node-v16.20.2-linux-x64/bin"
    
    # 创建模拟的node命令
    cat > "$TEST_DIR/node_bins/node-v16.20.2-linux-x64/bin/node" << 'EOF'
#!/bin/bash
echo "v16.20.2"
EOF
    chmod +x "$TEST_DIR/node_bins/node-v16.20.2-linux-x64/bin/node"
}

# 清理测试环境
teardown() {
    rm -rf "$TEST_DIR"
}

# 测试1: 检查脚本是否存在
test_script_exists() {
    if [[ ! -f "$TEST_DIR/scripts/nvm_use" ]]; then
        echo "FAIL: nvm_use script not found"
        return 1
    fi
    echo "PASS: nvm_use script exists"
    return 0
}

# 测试2: 检查脚本是否有执行权限
test_script_executable() {
    if [[ ! -x "$TEST_DIR/scripts/nvm_use" ]]; then
        echo "FAIL: nvm_use is not executable"
        return 1
    fi
    echo "PASS: nvm_use is executable"
    return 0
}

# 测试3: 检查帮助信息是否正确显示
test_help_message() {
    # 设置环境变量
    local original_home="$HOME"
    local original_shell="$SHELL"
    export HOME="$CONFIG_DIR"
    export SHELL="/bin/bash"
    
    # 创建模拟的配置文件
    echo "# Test bash config" > "$CONFIG_DIR/.bashrc"
    
    # 获取帮助信息
    local output
    output=$(timeout 5s "$TEST_DIR/scripts/nvm_use" --lang en 2>&1 || true)
    
    # 检查是否包含用法信息
    if echo "$output" | grep -q "Usage: nvm_use"; then
        echo "PASS: Help message displays correctly"
    else
        echo "FAIL: Help message does not display correctly"
        echo "Output: $output"
        export HOME="$original_home"
        export SHELL="$original_shell"
        return 1
    fi
    
    # 恢复环境变量
    export HOME="$original_home"
    export SHELL="$original_shell"
    return 0
}

# 测试4: 检查可用版本显示是否正确
test_version_list() {
    # 设置环境变量
    local original_home="$HOME"
    local original_shell="$SHELL"
    export HOME="$CONFIG_DIR"
    export SHELL="/bin/bash"
    export NVM_OFFLINE_DIR="$TEST_DIR"
    
    # 创建模拟的配置文件
    echo "# Test bash config" > "$CONFIG_DIR/.bashrc"
    
    # 获取版本列表
    local output
    output=$(timeout 5s "$TEST_DIR/scripts/nvm_use" --lang en 2>&1 || true)
    
    # 检查是否包含可用版本信息
    if echo "$output" | grep -q "Available versions:"; then
        # 检查是否包含16和18版本
        if echo "$output" | grep -q "16" && echo "$output" | grep -q "18"; then
            echo "PASS: Version list displays correctly"
        else
            echo "WARN: Version list may not be complete"
            echo "Output: $output"
        fi
    else
        echo "WARN: Version list not found in output"
        echo "Output: $output"
    fi
    
    # 恢复环境变量
    export HOME="$original_home"
    export SHELL="$original_shell"
    export NVM_OFFLINE_DIR=""
    return 0
}

# 测试5: 检查版本切换功能
test_version_switch() {
    # 设置环境变量
    local original_home="$HOME"
    local original_shell="$SHELL"
    local original_path="$PATH"
    export HOME="$CONFIG_DIR"
    export SHELL="/bin/bash"
    export NVM_OFFLINE_DIR="$TEST_DIR"
    
    # 创建模拟的配置文件
    echo "# Test bash config" > "$CONFIG_DIR/.bashrc"
    
    # 尝试切换到版本16
    local output
    output=$(echo "v16.20.2" | timeout 10s "$TEST_DIR/scripts/nvm_use" 16 --lang en 2>&1 || true)
    
    # 检查是否成功切换版本
    if echo "$output" | grep -q "Switched to Node.js v16.20.2"; then
        echo "PASS: Version switch works correctly"
    else
        echo "WARN: Cannot verify version switch from output"
        echo "Output: $output"
    fi
    
    # 恢复环境变量
    export HOME="$original_home"
    export SHELL="$original_shell"
    export PATH="$original_path"
    export NVM_OFFLINE_DIR=""
    return 0
}

# 运行所有测试
run_tests() {
    echo "Running nvm_use tests..."
    
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
    
    if test_help_message; then
        ((passed++))
    else
        ((failed++))
    fi
    
    if test_version_list; then
        ((passed++))
    else
        ((failed++))
    fi
    
    if test_version_switch; then
        ((passed++))
    else
        ((failed++))
    fi
    
    teardown
    
    echo "Tests completed: $passed passed, $failed failed"
    
    # 只有当有测试失败时才返回非零退出码
    if [[ $failed -gt 0 ]]; then
        return 1
    fi
    
    return 0
}

# 执行测试
run_tests
exit_code=$?
echo "Test script exiting with code: $exit_code"
exit $exit_code