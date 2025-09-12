# 离线NVM工具包

## 项目概述
本项目提供了一套离线Node.js版本管理解决方案，允许开发者在没有网络连接的情况下安装和切换不同版本的Node.js。这对于网络受限的环境或需要在多台机器上保持一致开发环境的场景非常有用。

## 项目结构
- `nvm_offline/`: 主目录，包含离线NVM的实现
  - `node_bins/`: 预下载的Node.js二进制包（版本16、18、20和22）
  - `scripts/`: 安装和版本切换脚本
    - `install.sh`: 用于设置离线NVM环境的安装脚本
    - `nvm_use`: 用于在不同Node.js版本之间切换的脚本
- `nvm_offline_package.tar.gz`: 包含整个离线NVM设置的压缩包
- `test_env/`: 用于验证的测试环境目录，包含重复的设置

## 核心组件

### 安装
使用`nvm_offline/scripts/`中的`install.sh`脚本安装离线NVM环境。该脚本将：
1. 在`$HOME/.nvm_offline`创建目录
2. 将Node.js二进制包和脚本复制到该目录
3. 在`~/.bashrc`中设置环境变量
4. 将脚本目录添加到系统PATH

### 版本切换
`nvm_use`脚本允许在不同Node.js版本之间切换：
- 支持版本16、18、20和22
- 如果尚未解压，会自动解压相应的Node.js二进制包
- 更新PATH环境变量以指向选定的版本
- 通过运行`node --version`验证版本切换

## 预装工具
每个Node.js版本包都包含以下工具：
- `node`: Node.js运行时
- `npm`: Node包管理器（随Node.js一起提供）
- `npx`: Node包执行器（随Node.js一起提供）
- `corepack`: 包管理器管理器（随Node.js一起提供），可用于安装和管理：
  - `yarn`: 现代JavaScript包管理器
  - `pnpm`: 快速、节省磁盘空间的包管理器

使用corepack启用yarn或pnpm：
1. 为特定包管理器启用corepack：
   - 对于yarn: `corepack enable yarn`
   - 对于pnpm: `corepack enable pnpm`
2. 启用后，可以正常使用包管理器命令：
   - 对于yarn: `yarn init`, `yarn add`等
   - 对于pnpm: `pnpm init`, `pnpm add`等

## 使用方法
本项目用于设置离线Node.js版本管理环境。离线NVM实现允许开发者：
1. 在没有网络连接的情况下安装多个Node.js版本
2. 使用简单命令在不同Node.js版本之间切换
3. 在不同机器之间保持一致的开发环境
4. 通过corepack使用预装的包管理器如yarn和pnpm

使用离线NVM的步骤：
1. 运行`install.sh`脚本设置环境
2. 执行`source ~/.bashrc`或打开新终端以加载环境变量
3. 使用`nvm_use <version>`在Node.js版本（16、18、20或22）之间切换
4. 需要时使用corepack启用yarn或pnpm