```bash
#!/usr/bin/env bash

# Copyright (C) 2018 Harsh 'MSF Jarvis' Shandilya
# Copyright (C) 2018 Akhil Narang
# SPDX-License-Identifier: GPL-3.0-only
#
# Modernized AOSP Build Environment Setup
#
# Supported:
#   Ubuntu 22.04+
#   Debian 12+
#
# Intended for modern AOSP / Android platform builds.
# Legacy Android versions may require additional packages.

set -euo pipefail

echo "========================================"
echo "  AOSP Build Environment Setup"
echo "========================================"

# ------------------------------------------------------------
# Check OS
# ------------------------------------------------------------

if ! command -v lsb_release >/dev/null 2>&1; then
    echo "Installing lsb-release..."
    sudo apt-get update
    sudo apt-get install -y lsb-release
fi

OS_ID="$(. /etc/os-release && echo "${ID}")"
OS_VERSION="$(. /etc/os-release && echo "${VERSION_ID}")"

echo "Detected OS: ${OS_ID} ${OS_VERSION}"

case "${OS_ID}" in
    ubuntu)
        case "${OS_VERSION}" in
            22.04|24.04|25.04|25.10|26.04)
                ;;
            *)
                echo "WARNING: Ubuntu ${OS_VERSION} is not specifically tested."
                echo "Continuing anyway..."
                ;;
        esac
        ;;

    debian)
        case "${OS_VERSION}" in
            12|13)
                ;;
            *)
                echo "WARNING: Debian ${OS_VERSION} is not specifically tested."
                echo "Continuing anyway..."
                ;;
        esac
        ;;

    *)
        echo "WARNING: This script was designed for Ubuntu/Debian."
        echo "Detected: ${OS_ID}"
        echo "Continuing anyway..."
        ;;
esac

# ------------------------------------------------------------
# Update package repositories
# ------------------------------------------------------------

echo
echo "Updating package repositories..."

sudo apt-get update

# ------------------------------------------------------------
# Base tools
# ------------------------------------------------------------

echo
echo "Installing base development tools..."

sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
    apt-utils \
    ca-certificates \
    software-properties-common \
    build-essential \
    git \
    git-lfs \
    curl \
    wget \
    rsync \
    unzip \
    zip \
    tar \
    xz-utils \
    bzip2 \
    lzip \
    gzip \
    patch \
    pkg-config

# ------------------------------------------------------------
# AOSP build dependencies
# ------------------------------------------------------------

echo
echo "Installing AOSP build dependencies..."

sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
    adb \
    fastboot \
    autoconf \
    automake \
    bc \
    bison \
    ccache \
    clang \
    cmake \
    flex \
    g++ \
    gawk \
    gcc \
    gperf \
    imagemagick \
    lib32ncurses-dev \
    lib32z1-dev \
    libc6-dev \
    libcap-dev \
    libexpat1-dev \
    libgmp-dev \
    liblz4-dev \
    liblzma-dev \
    libmpc-dev \
    libmpfr-dev \
    libncurses-dev \
    libsdl2-dev \
    libssl-dev \
    libtool \
    libxml2 \
    libxml2-utils \
    libxml-simple-perl \
    libswitch-perl \
    lzop \
    maven \
    ncurses-dev \
    pngcrush \
    pngquant \
    python3 \
    python3-pip \
    python3-venv \
    re2c \
    schedtool \
    squashfs-tools \
    subversion \
    texinfo \
    xsltproc \
    zlib1g-dev

# ------------------------------------------------------------
# Optional utilities
# ------------------------------------------------------------

echo
echo "Installing useful development utilities..."

sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
    htop \
    ncftp \
    w3m \
    patchelf \
    expat \
    libexpat1-dev

# ------------------------------------------------------------
# Git LFS
# ------------------------------------------------------------

echo
echo "Initializing Git LFS..."

git lfs install

# ------------------------------------------------------------
# GitHub CLI
# ------------------------------------------------------------

echo
echo "Installing GitHub CLI..."

if ! command -v gh >/dev/null 2>&1; then
    sudo mkdir -p -m 755 /etc/apt/keyrings

    curl -fsSL \
        https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg \
        > /dev/null

    sudo chmod go+r \
        /etc/apt/keyrings/githubcli-archive-keyring.gpg

    echo \
        "deb [arch=$(dpkg --print-architecture) \
        signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] \
        https://cli.github.com/packages stable main" \
        | sudo tee /etc/apt/sources.list.d/github-cli.list \
        > /dev/null

    sudo apt-get update
    sudo apt-get install -y gh
else
    echo "GitHub CLI already installed."
fi

# ------------------------------------------------------------
# Android udev rules
# ------------------------------------------------------------

echo
echo "Installing Android udev rules..."

sudo curl -fsSL \
    -o /etc/udev/rules.d/51-android.rules \
    https://raw.githubusercontent.com/M0Rf30/android-udev-rules/master/51-android.rules

sudo chmod 644 /etc/udev/rules.d/51-android.rules
sudo chown root:root /etc/udev/rules.d/51-android.rules

sudo udevadm control --reload-rules
sudo udevadm trigger

# ------------------------------------------------------------
# Configure ccache
# ------------------------------------------------------------

echo
echo "Configuring ccache..."

if command
```
