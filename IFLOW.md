# iFlow CLI Context

## Project Overview
This directory is intended for offline NVM (Node Version Manager) related activities. The purpose is to provide a context for iFlow CLI to assist with software engineering tasks related to NVM.

## Project Structure
- `IFLOW.md`: This file, which serves as the primary context for iFlow CLI interactions.
- `nvm_offline/`: Main directory containing offline NVM implementation
  - `node_bins/`: Pre-downloaded Node.js binary packages for versions 16, 18, 20, and 22
  - `scripts/`: Installation and version switching scripts
    - `install.sh`: Installation script for setting up the offline NVM environment
    - `nvm_use`: Script for switching between Node.js versions
- `nvm_offline_package.tar.gz`: Compressed package containing the entire offline NVM setup
- `test_env/`: Testing environment directory with a duplicate setup for validation

## Key Components

### Installation
The offline NVM environment is installed using the `install.sh` script located in `nvm_offline/scripts/`. This script:
1. Creates a directory at `$HOME/.nvm_offline`
2. Copies Node.js binary packages and scripts to this directory
3. Sets up environment variables in `~/.bashrc`
4. Adds the scripts directory to the system PATH

### Version Switching
The `nvm_use` script allows switching between different Node.js versions:
- Supports versions 16, 18, 20, and 22
- Automatically extracts the Node.js binary package if not already extracted
- Updates the PATH environment variable to point to the selected version
- Validates the version switch by running `node --version`

## Pre-installed Tools
Each Node.js version package includes the following tools:
- `node`: The Node.js runtime
- `npm`: Node Package Manager (included with Node.js)
- `npx`: Node Package Executor (included with Node.js)
- `corepack`: Package manager manager (included with Node.js) that allows you to install and manage:
  - `yarn`: Modern JavaScript package manager
  - `pnpm`: Fast, disk space efficient package manager

To use yarn or pnpm with corepack:
1. Enable corepack for a specific package manager:
   - For yarn: `corepack enable yarn`
   - For pnpm: `corepack enable pnpm`
2. After enabling, you can use the package manager commands normally:
   - For yarn: `yarn init`, `yarn add`, etc.
   - For pnpm: `pnpm init`, `pnpm add`, etc.

## Usage
This directory is used to set up an environment for iFlow CLI to assist with tasks related to managing Node.js versions offline. The offline NVM implementation allows developers to:
1. Install multiple Node.js versions without internet connectivity
2. Switch between different Node.js versions using simple commands
3. Maintain a consistent development environment across different machines
4. Use pre-installed package managers like yarn and pnpm via corepack

To use the offline NVM:
1. Run the `install.sh` script to set up the environment
2. Source `~/.bashrc` or open a new terminal to load environment variables
3. Use `nvm_use <version>` to switch between Node.js versions (16, 18, 20, or 22)
4. Enable yarn or pnpm using corepack when needed