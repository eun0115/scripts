#!/usr/bin/env bash

# Copyright (C) 2026 Gian Paolo Estacio
# SPDX-License-Identifier: GPL-3.0-only
#
# Modern AOSP Build Environment Setup
#
# Supported:
#   Ubuntu 22.04+
#   Debian 12+
#   Linux Mint 22+
#   Arch Linux
#   Manjaro / EndeavourOS
#   Fedora
#
# Intended for modern AOSP / Android platform builds.
# Legacy Android versions may require additional packages.

set -euo pipefail

# ------------------------------------------------------------
# Configuration
# ------------------------------------------------------------

CCACHE_SIZE="${CCACHE_SIZE:-50G}"
ANDROID_UDEV_URL="https://raw.githubusercontent.com/M0Rf30/android-udev-rules/master/51-android.rules"

echo "========================================"
echo "  AOSP Build Environment Setup"
echo "========================================"
echo

# ------------------------------------------------------------
# Root / sudo check
# ------------------------------------------------------------

if [ "${EUID}" -eq 0 ]; then
    SUDO=""
else
    if ! command -v sudo >/dev/null 2>&1; then
        echo "ERROR: sudo is required."
        exit 1
    fi

    SUDO="sudo"
fi

# ------------------------------------------------------------
# Check OS
# ------------------------------------------------------------

if [ ! -f /etc/os-release ]; then
    echo "ERROR: /etc/os-release not found."
    exit 1
fi

. /etc/os-release

OS_ID="${ID}"
OS_VERSION="${VERSION_ID:-unknown}"

echo "Detected OS: ${PRETTY_NAME:-${OS_ID} ${OS_VERSION}}"

case "${OS_ID}" in

    ubuntu)
        PKG_MANAGER="apt"
        ;;

    linuxmint)
        PKG_MANAGER="apt"
        ;;

    debian)
        PKG_MANAGER="apt"
        ;;

    arch)
        PKG_MANAGER="pacman"
        ;;

    manjaro)
        PKG_MANAGER="pacman"
        ;;

    endeavouros)
        PKG_MANAGER="pacman"
        ;;

    fedora)
        PKG_MANAGER="dnf"
        ;;

    *)
        echo
        echo "ERROR: Unsupported distribution: ${OS_ID}"
        echo
        echo "Supported:"
        echo "  Ubuntu"
        echo "  Debian"
        echo "  Linux Mint"
        echo "  Arch Linux"
        echo "  Manjaro"
        echo "  EndeavourOS"
        echo "  Fedora"
        exit 1
        ;;

esac

echo "Package manager: ${PKG_MANAGER}"
echo

# ------------------------------------------------------------
# Version warnings
# ------------------------------------------------------------

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

    linuxmint)
        echo "Linux Mint detected."
        ;;

    fedora)
        echo "Fedora detected."
        ;;

    arch|manjaro|endeavouros)
        echo "Arch-based distribution detected."
        ;;

esac

# ------------------------------------------------------------
# Update package repositories
# ------------------------------------------------------------

echo
echo "========================================"
echo " Updating Package Repositories"
echo "========================================"

case "${PKG_MANAGER}" in

    apt)
        ${SUDO} apt-get update
        ;;

    pacman)
        ${SUDO} pacman -Sy --noconfirm
        ;;

    dnf)
        ${SUDO} dnf makecache
        ;;

esac

# ------------------------------------------------------------
# Base development tools
# ------------------------------------------------------------

echo
echo "========================================"
echo " Installing Base Development Tools"
echo "========================================"

case "${PKG_MANAGER}" in

    apt)

        ${SUDO} DEBIAN_FRONTEND=noninteractive apt-get install -y \
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

        ;;

    pacman)

        ${SUDO} pacman -S --needed --noconfirm \
            base-devel \
            git \
            git-lfs \
            curl \
            wget \
            rsync \
            unzip \
            zip \
            tar \
            xz \
            bzip2 \
            gzip \
            patch \
            pkgconf

        ;;

    dnf)

        ${SUDO} dnf install -y \
            ca-certificates \
            @development-tools \
            git \
            git-lfs \
            curl \
            wget \
            rsync \
            unzip \
            zip \
            tar \
            xz \
            bzip2 \
            gzip \
            patch \
            pkgconf

        ;;

esac

# ------------------------------------------------------------
# AOSP build dependencies
# ------------------------------------------------------------

echo
echo "========================================"
echo " Installing AOSP Dependencies"
echo "========================================"

case "${PKG_MANAGER}" in

    apt)

        ${SUDO} DEBIAN_FRONTEND=noninteractive apt-get install -y \
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

        ;;

    pacman)

        ${SUDO} pacman -S --needed --noconfirm \
            android-tools \
            autoconf \
            automake \
            bc \
            bison \
            ccache \
            clang \
            cmake \
            flex \
            gcc \
            gawk \
            gperf \
            imagemagick \
            lib32-glibc \
            lib32-ncurses \
            libcap \
            libexpat \
            gmp \
            lz4 \
            xz \
            libmpc \
            mpfr \
            ncurses \
            sdl2 \
            openssl \
            libtool \
            libxml2 \
            lzop \
            maven \
            pngcrush \
            pngquant \
            python \
            python-pip \
            python-virtualenv \
            re2c \
            schedtool \
            squashfs-tools \
            subversion \
            texinfo \
            libxslt \
            zlib

        ;;

    dnf)

        ${SUDO} dnf install -y \
            android-tools \
            autoconf \
            automake \
            bc \
            bison \
            ccache \
            clang \
            cmake \
            flex \
            gcc \
            gcc-c++ \
            gawk \
            gperf \
            ImageMagick \
            glibc-devel \
            glibc-devel.i686 \
            libcap-devel \
            expat-devel \
            gmp-devel \
            lz4-devel \
            xz-devel \
            libmpc-devel \
            mpfr-devel \
            ncurses-devel \
            SDL2-devel \
            openssl-devel \
            libtool \
            libxml2 \
            libxml2-devel \
            lzop \
            maven \
            ncurses-compat-libs \
            pngcrush \
            python3 \
            python3-pip \
            python3-devel \
            re2c \
            schedtool \
            squashfs-tools \
            subversion \
            texinfo \
            libxslt \
            zlib-devel

        ;;

esac

# ------------------------------------------------------------
# Optional utilities
# ------------------------------------------------------------

echo
echo "========================================"
echo " Installing Useful Utilities"
echo "========================================"

case "${PKG_MANAGER}" in

    apt)

        ${SUDO} DEBIAN_FRONTEND=noninteractive apt-get install -y \
            htop \
            ncftp \
            w3m \
            patchelf \
            expat \
            libexpat1-dev

        ;;

    pacman)

        ${SUDO} pacman -S --needed --noconfirm \
            htop \
            ncftp \
            w3m \
            patchelf \
            expat

        ;;

    dnf)

        ${SUDO} dnf install -y \
            htop \
            ncftp \
            w3m \
            patchelf \
            expat \
            expat-devel

        ;;

esac

# ------------------------------------------------------------
# Java / OpenJDK
# ------------------------------------------------------------

echo
echo "========================================"
echo " Installing Java"
echo "========================================"

case "${PKG_MANAGER}" in

    apt)

        ${SUDO} DEBIAN_FRONTEND=noninteractive apt-get install -y \
            openjdk-17-jdk

        ;;

    pacman)

        ${SUDO} pacman -S --needed --noconfirm \
            jdk17-openjdk

        ;;

    dnf)

        ${SUDO} dnf install -y \
            java-17-openjdk-devel

        ;;

esac

# ------------------------------------------------------------
# Python
# ------------------------------------------------------------

echo
echo "========================================"
echo " Checking Python"
echo "========================================"

if command -v python3 >/dev/null 2>&1; then
    echo "Python: $(python3 --version)"
else
    echo "ERROR: python3 was not installed correctly."
    exit 1
fi

if command -v pip3 >/dev/null 2>&1; then
    echo "pip: $(pip3 --version | head -n 1)"
fi

# ------------------------------------------------------------
# Git LFS
# ------------------------------------------------------------

echo
echo "========================================"
echo " Initializing Git LFS"
echo "========================================"

git lfs install

# ------------------------------------------------------------
# Configure Git
# ------------------------------------------------------------

echo
echo "========================================"
echo " Git Configuration"
echo "========================================"

if git config --global user.name >/dev/null 2>&1; then
    echo "Git user: $(git config --global user.name)"
else
    echo "Git user.name is not configured."
    echo "Configure it later with:"
    echo
    echo "  git config --global user.name \"Your Name\""
fi

if git config --global user.email >/dev/null 2>&1; then
    echo "Git email: $(git config --global user.email)"
else
    echo "Git user.email is not configured."
    echo "Configure it later with:"
    echo
    echo "  git config --global user.email \"you@example.com\""
fi

# ------------------------------------------------------------
# GitHub CLI
# ------------------------------------------------------------

echo
echo "========================================"
echo " Installing GitHub CLI"
echo "========================================"

if command -v gh >/dev/null 2>&1; then

    echo "GitHub CLI already installed:"
    gh --version | head -n 1

else

    case "${PKG_MANAGER}" in

        apt)

            ${SUDO} mkdir -p -m 755 /etc/apt/keyrings

            curl -fsSL \
                https://cli.github.com/packages/githubcli-archive-keyring.gpg \
                | ${SUDO} tee \
                    /etc/apt/keyrings/githubcli-archive-keyring.gpg \
                    >/dev/null

            ${SUDO} chmod go+r \
                /etc/apt/keyrings/githubcli-archive-keyring.gpg

            echo \
                "deb [arch=$(dpkg --print-architecture) \
                signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] \
                https://cli.github.com/packages stable main" \
                | ${SUDO} tee \
                    /etc/apt/sources.list.d/github-cli.list \
                    >/dev/null

            ${SUDO} apt-get update
            ${SUDO} apt-get install -y gh

            ;;

        pacman)

            ${SUDO} pacman -S --needed --noconfirm github-cli

            ;;

        dnf)

            ${SUDO} dnf install -y gh

            ;;

    esac

fi

# ------------------------------------------------------------
# Android udev rules
# ------------------------------------------------------------

echo
echo "========================================"
echo " Installing Android udev Rules"
echo "========================================"

${SUDO} curl -fsSL \
    -o /etc/udev/rules.d/51-android.rules \
    "${ANDROID_UDEV_URL}"

${SUDO} chmod 644 \
    /etc/udev/rules.d/51-android.rules

${SUDO} chown root:root \
    /etc/udev/rules.d/51-android.rules

${SUDO} udevadm control --reload-rules
${SUDO} udevadm trigger

echo "Android udev rules installed."

# ------------------------------------------------------------
# Configure ccache
# ------------------------------------------------------------

echo
echo "========================================"
echo " Configuring ccache"
echo "========================================"

if command -v ccache >/dev/null 2>&1; then

    mkdir -p "${HOME}/.cache/ccache"

    ccache --set-config=cache_dir="${HOME}/.cache/ccache"
    ccache --set-config=max_size="${CCACHE_SIZE}"

    echo "ccache directory:"
    ccache --get-config=cache_dir

    echo
    echo "ccache maximum size:"
    ccache --get-config=max_size

else

    echo "WARNING: ccache was not found."

fi

# ------------------------------------------------------------
# Environment configuration
# ------------------------------------------------------------

echo
echo "========================================"
echo " Configuring Build Environment"
echo "========================================"

BASHRC="${HOME}/.bashrc"

add_to_bashrc() {
    local line="$1"

    if ! grep -Fqx "${line}" "${BASHRC}" 2>/dev/null; then
        echo "${line}" >> "${BASHRC}"
    fi
}

add_to_bashrc ""
add_to_bashrc "# Android / AOSP build environment"
add_to_bashrc 'export USE_CCACHE=1'
add_to_bashrc 'export CCACHE_EXEC="$(command -v ccache 2>/dev/null || true)"'
add_to_bashrc 'export PATH="${HOME}/bin:${HOME}/.local/bin:${PATH}"'

# ------------------------------------------------------------
# Install repo
# ------------------------------------------------------------

echo
echo "========================================"
echo " Installing Android Repo Tool"
echo "========================================"

mkdir -p "${HOME}/bin"

if command -v repo >/dev/null 2>&1; then

    echo "repo already installed:"
    repo --version | head -n 1

elif [ -x "${HOME}/bin/repo" ]; then

    echo "repo already exists at ${HOME}/bin/repo"

else

    curl -fLo "${HOME}/bin/repo" \
        https://storage.googleapis.com/git-repo-downloads/repo

    chmod a+x "${HOME}/bin/repo"

    echo "repo installed to ${HOME}/bin/repo"

fi

# ------------------------------------------------------------
# Verify important tools
# ------------------------------------------------------------

echo
echo "========================================"
echo " Verifying Installation"
echo "========================================"

TOOLS=(
    git
    git-lfs
    curl
    wget
    python3
    gcc
    g++
    clang
    cmake
    make
    ccache
    adb
    fastboot
    repo
    gh
    java
)

FAILED=0

for TOOL in "${TOOLS[@]}"; do

    if command -v "${TOOL}" >/dev/null 2>&1; then
        printf "  [OK] %-12s %s\n" \
            "${TOOL}" \
            "$(command -v "${TOOL}")"
    else
        printf "  [FAIL] %-12s not found\n" \
            "${TOOL}"

        FAILED=1
    fi

done

# ------------------------------------------------------------
# Version information
# ------------------------------------------------------------

echo
echo "========================================"
echo " Tool Versions"
echo "========================================"

git --version || true
python3 --version || true
gcc --version | head -n 1 || true
clang --version | head -n 1 || true
java -version 2>&1 | head -n 1 || true
ccache --version | head -n 1 || true
adb version | head -n 1 || true
fastboot --version | head -n 1 || true
gh --version | head -n 1 || true

# ------------------------------------------------------------
# Finish
# ------------------------------------------------------------

echo
echo "========================================"

if [ "${FAILED}" -eq 0 ]; then
    echo " AOSP Environment Ready!"
else
    echo " AOSP Environment Installed"
    echo " Some optional tools were not found."
fi

echo "========================================"

echo
echo "Distribution:"
echo "  ${PRETTY_NAME:-${OS_ID}}"

echo
echo "ccache:"
echo "  ${HOME}/.cache/ccache"
echo "  Maximum size: ${CCACHE_SIZE}"

echo
echo "repo:"
echo "  ${HOME}/bin/repo"

echo
echo "IMPORTANT:"
echo "Reload your shell before building:"
echo
echo "  source ~/.bashrc"
echo

if [ "${FAILED}" -ne 0 ]; then
    echo "Review the [FAIL] entries above."
fi

echo
echo "AOSP setup complete."
