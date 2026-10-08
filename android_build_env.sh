```bash
#!/usr/bin/env bash

# Copyright (C) 2026 Gian Paolo Estacio
# SPDX-License-Identifier: GPL-3.0-only
#
# Universal AOSP Build Environment Setup
#
# Package-manager based rather than distro based.
#
# Supported package managers:
#   apt
#   apt-get
#   nala
#   pacman
#   paru
#   yay
#   dnf
#   yum
#   zypper
#   apk
#   emerge
#   xbps-install
#   nix-env
#   nix
#   urpmi
#   slackpkg
#   eopkg
#   swupd
#   brew
#
# The script detects the first usable package manager and
# installs the closest available AOSP dependencies.
#
# Legacy Android versions may require additional packages.

set -euo pipefail

# ============================================================
# Configuration
# ============================================================

CCACHE_SIZE="${CCACHE_SIZE:-50G}"

ANDROID_UDEV_URL="https://raw.githubusercontent.com/M0Rf30/android-udev-rules/master/51-android.rules"

SCRIPT_NAME="$(basename "$0")"

echo "========================================"
echo " Universal AOSP Build Environment Setup"
echo "========================================"
echo

# ============================================================
# sudo
# ============================================================

if [ "${EUID}" -eq 0 ]; then
    SUDO=""
else
    if ! command -v sudo >/dev/null 2>&1; then
        echo "ERROR: sudo is required."
        exit 1
    fi

    SUDO="sudo"
fi

# ============================================================
# OS information
# ============================================================

if [ -f /etc/os-release ]; then
    . /etc/os-release
else
    ID="unknown"
    VERSION_ID="unknown"
    PRETTY_NAME="Unknown Linux"
fi

echo "Operating system:"
echo "  ${PRETTY_NAME:-${ID:-unknown}}"
echo

# ============================================================
# Detect package manager
# ============================================================

PACKAGE_MANAGER=""

detect_package_manager() {

    # Debian / Ubuntu
    if command -v apt-get >/dev/null 2>&1; then
        PACKAGE_MANAGER="apt-get"
        return
    fi

    # Nala
    if command -v nala >/dev/null 2>&1; then
        PACKAGE_MANAGER="nala"
        return
    fi

    # Arch / pacman
    if command -v pacman >/dev/null 2>&1; then
        PACKAGE_MANAGER="pacman"
        return
    fi

    # paru
    if command -v paru >/dev/null 2>&1; then
        PACKAGE_MANAGER="paru"
        return
    fi

    # yay
    if command -v yay >/dev/null 2>&1; then
        PACKAGE_MANAGER="yay"
        return
    fi

    # Fedora / RHEL
    if command -v dnf >/dev/null 2>&1; then
        PACKAGE_MANAGER="dnf"
        return
    fi

    # Legacy RHEL / CentOS
    if command -v yum >/dev/null 2>&1; then
        PACKAGE_MANAGER="yum"
        return
    fi

    # openSUSE / SUSE
    if command -v zypper >/dev/null 2>&1; then
        PACKAGE_MANAGER="zypper"
        return
    fi

    # Alpine
    if command -v apk >/dev/null 2>&1; then
        PACKAGE_MANAGER="apk"
        return
    fi

    # Gentoo
    if command -v emerge >/dev/null 2>&1; then
        PACKAGE_MANAGER="emerge"
        return
    fi

    # Void Linux
    if command -v xbps-install >/dev/null 2>&1; then
        PACKAGE_MANAGER="xbps"
        return
    fi

    # NixOS / Nix
    if command -v nix >/dev/null 2>&1; then
        PACKAGE_MANAGER="nix"
        return
    fi

    if command -v nix-env >/dev/null 2>&1; then
        PACKAGE_MANAGER="nix-env"
        return
    fi

    # Mageia / Mandriva
    if command -v urpmi >/dev/null 2>&1; then
        PACKAGE_MANAGER="urpmi"
        return
    fi

    # Slackware
    if command -v slackpkg >/dev/null 2>&1; then
        PACKAGE_MANAGER="slackpkg"
        return
    fi

    # Solus
    if command -v eopkg >/dev/null 2>&1; then
        PACKAGE_MANAGER="eopkg"
        return
    fi

    # Clear Linux
    if command -v swupd >/dev/null 2>&1; then
        PACKAGE_MANAGER="swupd"
        return
    fi

    # Homebrew / Linuxbrew
    if command -v brew >/dev/null 2>&1; then
        PACKAGE_MANAGER="brew"
        return
    fi
}

detect_package_manager

if [ -z "${PACKAGE_MANAGER}" ]; then
    echo "ERROR: No supported package manager detected."
    echo
    echo "Supported:"
    echo "  apt-get"
    echo "  nala"
    echo "  pacman"
    echo "  paru"
    echo "  yay"
    echo "  dnf"
    echo "  yum"
    echo "  zypper"
    echo "  apk"
    echo "  emerge"
    echo "  xbps-install"
    echo "  nix"
    echo "  urpmi"
    echo "  slackpkg"
    echo "  eopkg"
    echo "  swupd"
    echo "  brew"
    exit 1
fi

echo "Detected package manager:"
echo "  ${PACKAGE_MANAGER}"
echo

# ============================================================
# Package installation helper
# ============================================================

install_packages() {

    case "${PACKAGE_MANAGER}" in

        apt-get)

            ${SUDO} apt-get update

            ${SUDO} DEBIAN_FRONTEND=noninteractive \
                apt-get install -y "$@"

            ;;

        nala)

            ${SUDO} nala update
            ${SUDO} nala install -y "$@"

            ;;

        pacman)

            ${SUDO} pacman -Sy --needed --noconfirm "$@"

            ;;

        paru)

            paru -S --needed --noconfirm "$@"

            ;;

        yay)

            yay -S --needed --noconfirm "$@"

            ;;

        dnf)

            ${SUDO} dnf install -y "$@"

            ;;

        yum)

            ${SUDO} yum install -y "$@"

            ;;

        zypper)

            ${SUDO} zypper --non-interactive install "$@"

            ;;

        apk)

            ${SUDO} apk add "$@"

            ;;

        emerge)

            ${SUDO} emerge --ask=n "$@"

            ;;

        xbps)

            ${SUDO} xbps-install -Sy "$@"

            ;;

        nix)

            echo "Nix detected."
            echo "Using nix profile install."

            nix profile install "$@"

            ;;

        nix-env)

            nix-env -iA "$@"

            ;;

        urpmi)

            ${SUDO} urpmi --auto "$@"

            ;;

        slackpkg)

            ${SUDO} slackpkg install "$@"

            ;;

        eopkg)

            ${SUDO} eopkg install -y "$@"

            ;;

        swupd)

            ${SUDO} swupd bundle-add "$@"

            ;;

        brew)

            brew install "$@"

            ;;

    esac
}

# ============================================================
# Update repositories
# ============================================================

echo "========================================"
echo " Updating package repositories"
echo "========================================"

case "${PACKAGE_MANAGER}" in

    apt-get)
        ${SUDO} apt-get update
        ;;

    nala)
        ${SUDO} nala update
        ;;

    pacman|paru|yay)
        ${SUDO} pacman -Sy --noconfirm
        ;;

    dnf)
        ${SUDO} dnf makecache
        ;;

    yum)
        ${SUDO} yum makecache
        ;;

    zypper)
        ${SUDO} zypper refresh
        ;;

    apk)
        ${SUDO} apk update
        ;;

    xbps)
        ${SUDO} xbps-install -S
        ;;

    emerge)
        ${SUDO} emerge --sync
        ;;

    eopkg)
        ${SUDO} eopkg update-repo
        ;;

    swupd)
        ${SUDO} swupd update
        ;;

esac

# ============================================================
# Package mappings
# ============================================================

echo
echo "========================================"
echo " Installing AOSP dependencies"
echo "========================================"

case "${PACKAGE_MANAGER}" in

# ------------------------------------------------------------
# Debian / Ubuntu
# ------------------------------------------------------------

apt-get|nala)

    install_packages \
        ca-certificates \
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
        gzip \
        lzip \
        patch \
        pkg-config \
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
        libc6-dev \
        libcap-dev \
        libexpat1-dev \
        libgmp-dev \
        liblz4-dev \
        liblzma-dev \
        libmpc-dev \
        libmpfr-dev \
        libncurses-dev \
        libssl-dev \
        libtool \
        libxml2 \
        libxml2-utils \
        lzop \
        maven \
        ncurses-dev \
        pngcrush \
        pngquant \
        python3 \
        python3-pip \
        python3-venv \
        re2c \
        squashfs-tools \
        subversion \
        texinfo \
        xsltproc \
        zlib1g-dev \
        openjdk-17-jdk \
        htop \
        patchelf

    ;;

# ------------------------------------------------------------
# Arch
# ------------------------------------------------------------

pacman|paru|yay)

    install_packages \
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
        pkgconf \
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
        glibc \
        lib32-glibc \
        ncurses \
        lib32-ncurses \
        libcap \
        expat \
        gmp \
        lz4 \
        libmpc \
        mpfr \
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
        squashfs-tools \
        subversion \
        texinfo \
        libxslt \
        zlib \
        jdk17-openjdk \
        htop \
        patchelf

    ;;

# ------------------------------------------------------------
# Fedora / RHEL
# ------------------------------------------------------------

dnf|yum)

    install_packages \
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
        pkgconf \
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
        squashfs-tools \
        subversion \
        texinfo \
        libxslt \
        zlib-devel \
        java-17-openjdk-devel \
        htop \
        patchelf

    ;;

# ------------------------------------------------------------
# openSUSE
# ------------------------------------------------------------

zypper)

    install_packages \
        git \
        git-lfs \
        curl \
        wget \
        rsync \
        unzip \
        zip \
        tar \
        xz \
        gcc \
        gcc-c++ \
        make \
        autoconf \
        automake \
        bc \
        bison \
        ccache \
        clang \
        cmake \
        flex \
        gawk \
        gperf \
        ncurses-devel \
        openssl-devel \
        libxml2-devel \
        liblz4-devel \
        libexpat-devel \
        python3 \
        python3-pip \
        java-17-openjdk-devel \
        maven \
        squashfs

    ;;

# ------------------------------------------------------------
# Alpine
# ------------------------------------------------------------

apk)

    install_packages \
        build-base \
        bash \
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
        pkgconf \
        linux-headers \
        adb \
        autoconf \
        automake \
        bc \
        bison \
        ccache \
        clang \
        cmake \
        flex \
        gawk \
        gcc \
        g++ \
        ncurses-dev \
        openssl-dev \
        libxml2-dev \
        expat-dev \
        lz4-dev \
        python3 \
        py3-pip \
        openjdk17 \
        maven \
        squashfs-tools

    ;;

# ------------------------------------------------------------
# Gentoo
# ------------------------------------------------------------

emerge)

    install_packages \
        dev-vcs/git \
        dev-util/ccache \
        sys-devel/clang \
        sys-devel/gcc \
        sys-devel/make \
        dev-build/cmake \
        dev-lang/python \
        dev-java/openjdk \
        dev-java/maven \
        dev-util/pkgconf \
        sys-libs/ncurses \
        dev-libs/openssl \
        dev-libs/libxml2 \
        dev-libs/expat \
        app-arch/xz-utils \
        app-arch/bzip2 \
        app-arch/gzip \
        app-arch/lz4 \
        app-arch/zstd

    ;;

# ------------------------------------------------------------
# Void Linux
# ------------------------------------------------------------

xbps)

    install_packages \
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
        pkg-config \
        ccache \
        clang \
        cmake \
        gcc \
        gawk \
        ncurses-devel \
        openssl-devel \
        libxml2-devel \
        python3 \
        python3-pip \
        openjdk17 \
        maven

    ;;

# ------------------------------------------------------------
# Solus
# ------------------------------------------------------------

eopkg)

    install_packages \
        system.devel \
        git \
        git-lfs \
        curl \
        wget \
        rsync \
        unzip \
        zip \
        ccache \
        clang \
        cmake \
        gcc \
        ncurses-devel \
        openssl-devel \
        python3 \
        openjdk-17 \
        maven

    ;;

# ------------------------------------------------------------
# Mageia / Mandriva
# ------------------------------------------------------------

urpmi)

    install_packages \
        git \
        git-lfs \
        curl \
        wget \
        rsync \
        unzip \
        zip \
        gcc \
        gcc-c++ \
        make \
        clang \
        cmake \
        ccache \
        autoconf \
        automake \
        bc \
        bison \
        flex \
        python3 \
        java-17-openjdk-devel \
        maven \
        ncurses-devel \
        openssl-devel \
        libxml2-devel

    ;;

# ------------------------------------------------------------
# Slackware
# ------------------------------------------------------------

slackpkg)

    install_packages \
        git \
        gcc \
        gcc-g++ \
        make \
        autoconf \
        automake \
        cmake \
        clang \
        python3 \
        openjdk \
        maven \
        ccache \
        ncurses \
        openssl

    ;;

# ------------------------------------------------------------
# Clear Linux
# ------------------------------------------------------------

swupd)

    install_packages \
        development-tools \
        dev-utils \
        git \
        python-basic \
        java-basic

    ;;

# ------------------------------------------------------------
# Nix
# ------------------------------------------------------------

nix|nix-env)

    echo
    echo "Nix detected."
    echo
    echo "AOSP dependencies on Nix are handled differently from"
    echo "traditional package managers."
    echo
    echo "Installing common development packages..."

    if command -v nix >/dev/null 2>&1; then

        nix profile install \
            nixpkgs#git \
            nixpkgs#git-lfs \
            nixpkgs#curl \
            nixpkgs#wget \
            nixpkgs#rsync \
            nixpkgs#unzip \
            nixpkgs#zip \
            nixpkgs#ccache \
            nixpkgs#clang \
            nixpkgs#cmake \
            nixpkgs#gcc \
            nixpkgs#python3 \
            nixpkgs#jdk17 \
            nixpkgs#maven

    fi

    ;;

# ------------------------------------------------------------
# Homebrew
# ------------------------------------------------------------

brew)

    install_packages \
        git \
        git-lfs \
        curl \
        wget \
        rsync \
        unzip \
        zip \
        ccache \
        clang \
        cmake \
        gcc \
        python \
        openjdk@17 \
        maven

    ;;

esac

# ============================================================
# Git LFS
# ============================================================

echo
echo "========================================"
echo " Configuring Git LFS"
echo "========================================"

if command -v git-lfs >/dev/null 2>&1; then
    git lfs install
    echo "Git LFS initialized."
else
    echo "WARNING: git-lfs not found."
fi

# ============================================================
# ccache
# ============================================================

echo
echo "========================================"
echo " Configuring ccache"
echo "========================================"

if command -v ccache >/dev/null 2>&1; then

    mkdir -p "${HOME}/.cache/ccache"

    ccache --set-config="cache_dir=${HOME}/.cache/ccache"
    ccache --set-config="max_size=${CCACHE_SIZE}"

    echo "Cache directory:"
    ccache --get-config=cache_dir

    echo "Maximum cache size:"
    ccache --get-config=max_size

else

    echo "WARNING: ccache is not installed."

fi

# ============================================================
# Android udev rules
# ============================================================

echo
echo "========================================"
echo " Installing Android udev rules"
echo "========================================"

if [ -d /etc/udev/rules.d ]; then

    ${SUDO} curl -fsSL \
        -o /etc/udev/rules.d/51-android.rules \
        "${ANDROID_UDEV_URL}"

    ${SUDO} chmod 644 \
        /etc/udev/rules.d/51-android.rules

    ${SUDO} chown root:root \
        /etc/udev/rules.d/51-android.rules

    if command -v udevadm >/dev/null 2>&1; then
        ${SUDO} udevadm control --reload-rules
        ${SUDO} udevadm trigger
    fi

    echo "Android udev rules installed."

else

    echo "udev is not available."
    echo "Skipping Android udev rules."

fi

# ============================================================
# GitHub CLI
# ============================================================

echo
echo "========================================"
echo " Installing GitHub CLI"
echo "========================================"

if command -v gh >/dev/null 2>&1; then

    echo "GitHub CLI already installed."

else

    case "${PACKAGE_MANAGER}" in

        apt-get)

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

        nala)

            ${SUDO} nala install -y gh || \
                echo "WARNING: Could not install GitHub CLI through Nala."

            ;;

        pacman|paru|yay)

            install_packages github-cli

            ;;

        dnf)

            install_packages gh

            ;;

        yum)

            echo "GitHub CLI may require the official GitHub repository on old yum systems."
            ;;

        zypper)

            install_packages gh || true

            ;;

        brew)

            install_packages gh

            ;;

        *)

            echo "Skipping GitHub CLI for ${PACKAGE_MANAGER}."

            ;;

    esac

fi

# ============================================================
# Android repo tool
# ============================================================

echo
echo "========================================"
echo " Installing Android repo tool"
echo "========================================"

mkdir -p "${HOME}/bin"

if [ -x "${HOME}/bin/repo" ]; then

    echo "repo already exists."

else

    curl -fLo \
        "${HOME}/bin/repo" \
        https://storage.googleapis.com/git-repo-downloads/repo

    chmod a+x "${HOME}/bin/repo"

    echo "repo installed."

fi

# ============================================================
# Shell environment
# ============================================================

echo
echo "========================================"
echo " Configuring shell environment"
echo "========================================"

BASHRC="${HOME}/.bashrc"

add_bashrc() {

    local LINE="$1"

    if ! grep -Fqx "${LINE}" "${BASHRC}" 2>/dev/null; then
        echo "${LINE}" >> "${BASHRC}"
    fi
}

add_bashrc ""
add_bashrc "# Android / AOSP build environment"
add_bashrc 'export PATH="${HOME}/bin:${HOME}/.local/bin:${PATH}"'
add_bashrc 'export USE_CCACHE=1'
add_bashrc 'export CCACHE_EXEC="$(command -v ccache 2>/dev/null || true)"'

# ============================================================
# Verification
# ============================================================

echo
echo "========================================"
echo " Verifying installation"
echo "========================================"

TOOLS=(
    git
    curl
    wget
    python3
    gcc
    clang
    cmake
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

        printf "  [OK]   %-12s %s\n" \
            "${TOOL}" \
            "$(command -v "${TOOL}")"

    else

        printf "  [MISS] %-12s not found\n" \
            "${TOOL}"

        FAILED=1

    fi

done

# ============================================================
# Version information
# ============================================================

echo
echo "========================================"
echo " Version Information"
echo "========================================"

command -v git >/dev/null 2>&1 && git --version || true
command -v python3 >/dev/null 2>&1 && python3 --version || true
command -v gcc >/dev/null 2>&1 && gcc --version | head -n 1 || true
command -v clang >/dev/null 2>&1 && clang --version | head -n 1 || true
command -v ccache >/dev/null 2>&1 && ccache --version | head -n 1 || true
command -v java >/dev/null 2>&1 && java -version 2>&1 | head -n 1 || true
command -v adb >/dev/null 2>&1 && adb version | head -n 1 || true
command -v fastboot >/dev/null 2>&1 && fastboot --version | head -n 1 || true
command -v gh >/dev/null 2>&1 && gh --version | head -n 1 || true

# ============================================================
# Summary
# ============================================================

echo
echo "========================================"
echo " Setup Complete"
echo "========================================"

echo
echo "Package manager:"
echo "  ${PACKAGE_MANAGER}"

echo
echo "ccache:"
echo "  ${HOME}/.cache/ccache"
echo "  Size: ${CCACHE_SIZE}"

echo
echo "repo:"
echo "  ${HOME}/bin/repo"

echo
echo "Run:"
echo
echo "  source ~/.bashrc"
echo

if [ "${FAILED}" -eq 0 ]; then
    echo "All required tools were detected."
else
    echo "Some tools were not detected."
    echo "This may be normal on package managers with different"
    echo "package naming or limited Android tooling."
fi

echo
echo "AOSP environment setup finished."
```
