#!/usr/bin/env bash

echo "============================================="
echo " Starting Omarchy Post-Installation Setup   "
echo "============================================="

# 1. Update the system package database
echo "--> Updating system..."
sudo pacman -Syu --noconfirm

# 2. Install Firefox and your preferred tools
echo "--> Installing Firefox and essential apps..."
sudo pacman -S --noconfirm firefox git steam nano htop qbittorrent base-devel 

# 2.1 Install Custom AUR Packages via yay
echo "--> Installing apps from the AUR (Vesktop, Happ, Prism)..."
# Using -bin builds for complex apps ensures fast precompiled setups!
yay -S --noconfirm vesktop-bin happ-desktop-bin prismlauncher



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
