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

# Disable all swap entries in /etc/fstab
echo "[INFO] Disabling existing swap in /etc/fstab..."
sudo sed -i.bak '/\bswap\b/ s/^/#/' /etc/fstab

# Remove active swap
echo "[INFO] Disabling active swap (if any)..."
sudo swapoff -a

# Create common ZRAM config
echo "zram" | sudo tee /etc/modules-load.d/zram.conf
echo "options zram num_devices=1" | sudo tee /etc/modprobe.d/zram.conf
echo 'KERNEL=="zram0", ATTR{disksize}="65536M", TAG+="systemd"' | sudo tee /etc/udev/rules.d/99-zram.rules

# Debian-based: create manual systemd unit
if [ "$DISTRO" = "debian" ]; then
    echo "[INFO] Creating zram.service for Debian..."
    sudo tee /etc/systemd/system/zram.service > /dev/null <<EOF
[Unit]
Description=Swap with zram
After=multi-user.target

[Service]
Type=oneshot
RemainAfterExit=true
ExecStartPre=/sbin/modprobe zram
ExecStartPre=/sbin/mkswap /dev/zram0
ExecStart=/sbin/swapon --priority 32767 /dev/zram0
ExecStop=/sbin/swapoff /dev/zram0

[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl daemon-reload
    sudo systemctl enable --now zram.service

else
    # Arch-based: use zram-generator config
    echo "[INFO] Configuring zram-generator for Arch..."
    sudo mkdir -p /etc/systemd/zram-generator.conf.d
    sudo tee /etc/systemd/zram-generator.conf.d/zram.conf > /dev/null <<EOF
[zram0]
zram-size = 65536M
compression-algorithm = zstd
swap-priority = 32767
EOF

    sudo systemctl daemon-reexec
    sudo systemctl restart systemd-zram-setup@zram0.service
fi

echo "[✅] ZRAM-only swap setup complete."
