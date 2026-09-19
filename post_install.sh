#!/usr/bin/env bash

echo "============================================="
echo " Starting Omarchy Post-Installation Setup   "
echo "============================================="

# 0. Создание системного снимка (Snapshot) перед изменениями
echo "--> Creating a system snapshot..."
if command -v timeshift &> /dev/null; then
    sudo timeshift --create --comments "Before Omarchy Auto-Install"
elif command -v snapper &> /dev/null; then
    sudo snapper create --description "Before Omarchy Auto-Install"
else
    echo "--> Warning: No snapshot tool found (timeshift/snapper). Skipping..."
fi

# 1. Update the system package database
echo "--> Updating system..."
sudo pacman -Syu --noconfirm

# 2. Install Firefox and your preferred tools
echo "--> Installing Firefox and essential apps..."
sudo pacman -S --noconfirm firefox git steam nano htop qbittorrent base-devel fastfetch virt-manager qemu-desktop libvirt dnsmasq iptables-nft \
    docker docker-compose

# 2.1 Activate background virtual machines and containers services
echo "--> Hardening and spinning up libvirtd and docker daemons..."
sudo systemctl enable --now libvirtd
sudo systemctl enable --now docker

# 2.2 ADDED: All required Qylock, Qt5, Qt6, and GStreamer dependencies
echo "--> Installing login screen theme dependencies..."
sudo pacman -S --noconfirm \
    sddm perl \
    qt5-declarative qt5-graphicaleffects qt5-quickcontrols2 qt5-multimedia \
    qt6-multimedia qt6-multimedia-ffmpeg \
    gst-plugins-base gst-plugins-good gst-plugins-bad gst-plugins-ugly


# 3. Интерактивная установка экрана входа Qylock
echo "--> Fetching Qylock themes from GitHub..."
cd /tmp || exit
rm -rf qylock
git clone https://github.com
cd qylock || exit
chmod +x sddm.sh

echo "----------------------------------------------------"
echo " [!] LAUNCHING QYLOCK INTERACTIVE INSTALLER"
echo "  1. Choose 'Qt6' when prompted."
echo "  2. Use arrow keys and SPACE to select 'winter'."
echo "  3. Press Enter, enter your password, and choose 'Yes' to activate."
echo "----------------------------------------------------"
read -p "Press [ENTER] to start the Qylock installer..."

# Запуск скрипта автора в интерактивном режиме
./sddm.sh

echo "----------------------------------------------------"
echo " [?] PASSTHROUGH CHECK"
echo " Make sure the Qylock installation finished successfully."
echo "----------------------------------------------------"
read -p "Press [ENTER] to continue with restoration of your personal configurations..."

# Inject your local session account permissions securely to avoid sudo rules
sudo usermod -aG libvirt $(whoami)
sudo usermod -aG docker $(whoami)

# 2.2 Install Custom AUR Packages via yay
echo "--> Installing apps from the AUR (Vesktop, Happ, Prism)..."
# Using -bin builds for complex apps ensures fast precompiled setups!
yay -S --noconfirm vesktop-bin happ-desktop-bin prismlauncher spotify



# 3. Apply your custom configurations
echo "--> Restoring custom dotfiles from GitHub..."
cd "$HOME" || exit
# Back up the fresh system's default config folder just in case
mv "$HOME/.config" "$HOME/.config.bak"

# Clone your configurations directly into ~/.config
git clone https://github.com/andrejrepryncev4-pixel/My-omarchy-configs.git "$HOME/.config"

# 4. Set Firefox as your default system browser and styling
echo "--> Setting default applications and styling..."
if command -v omarchy &> /dev/null; then
    omarchy default browser firefox
    
    echo "--> Activating the Nord theme layout..."
    omarchy layout set nord
    
    echo "--> Reloading Omarchy environment..."
    omarchy reinstall configs
else
    # Fallback standard Linux method if omarchy command is structural
    xdg-settings set default-web-browser firefox.desktop
fi

echo "============================================="
echo " Setup complete! Rebooting the system.  "
echo "============================================="

sudo reboot 
