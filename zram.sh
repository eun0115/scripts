#!/bin/bash

# Detect distro type
if command -v apt >/dev/null 2>&1; then
    DISTRO="debian"
elif command -v pacman >/dev/null 2>&1; then
    DISTRO="arch"
else
    echo "Unsupported distro"
    exit 1
fi

# Install necessary packages
if [ "$DISTRO" = "debian" ]; then
    sudo apt update
    sudo apt install -y zram-config
elif [ "$DISTRO" = "arch" ]; then
    sudo pacman -Syu --noconfirm zram-generator
fi

# Disable swap entry in /etc/fstab
sudo sed -i '/swap/ s/^#*/#/' /etc/fstab

# Create common config files
echo "zram" | sudo tee /etc/modules-load.d/zram.conf
echo "options zram num_devices=1" | sudo tee /etc/modprobe.d/zram.conf
echo 'KERNEL=="zram0", ATTR{disksize}="65536M", TAG+="systemd"' | sudo tee /etc/udev/rules.d/99-zram.rules

# Create systemd service only for Debian
if [ "$DISTRO" = "debian" ]; then
    sudo tee /etc/systemd/system/zram.service > /dev/null <<EOF
[Unit]
Description=Swap with zram
After=multi-user.target

[Service]
Type=oneshot
RemainAfterExit=true
ExecStartPre=/sbin/mkswap /dev/zram0
ExecStart=/sbin/swapon /dev/zram0
ExecStop=/sbin/swapoff /dev/zram0

[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl enable zram
else
    # Arch system with zram-generator: create config file
    sudo mkdir -p /etc/systemd/zram-generator.conf.d
    sudo tee /etc/systemd/zram-generator.conf.d/zram.conf > /dev/null <<EOF
[zram0]
zram-size = 65536M
EOF

    sudo systemctl daemon-reexec
    sudo systemctl start /dev/zram0
    sudo systemctl status /dev/zram0
fi
