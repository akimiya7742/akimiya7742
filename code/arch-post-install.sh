#!/bin/bash

set -e

echo "==> Updating system"
sudo pacman -Syu --noconfirm

echo "==> Installing base packages"
sudo pacman -S --noconfirm \
    base-devel git gcc mpv vlc ffmpeg clang \
    flatpak ttf-jetbrains-mono-nerd noto-fonts-cjk \
    kio-admin ntfs-3g fuse3

# 1. Setup Chaotic-AUR Keys & Repo
echo "==> Adding Chaotic-AUR"
# It is often safer to trust the signed package directly if keyservers fail
sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign-key 3056513887B78AEB
sudo pacman --noconfirm -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
sudo pacman --noconfirm -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'

# Append to pacman.conf if not already there
if ! grep -q "\[chaotic-aur\]" /etc/pacman.conf; then
    printf '\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist\n' | sudo tee -a /etc/pacman.conf
fi

sudo pacman -Syu --noconfirm

# 2. Install Yay (AUR Helper)
echo "==> Installing yay"
if ! command -v yay &> /dev/null; then
    git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
    cd /tmp/yay-bin
    makepkg -si --noconfirm
    cd -
else
    echo "yay already installed"
fi

# 3. Install Main Apps (Now available via Chaotic-AUR binaries)
echo "==> Installing Apps & Input Method"
sudo pacman -S --noconfirm \
    visual-studio-code-bin \
    google-chrome \
    fcitx5 fcitx5-configtool fcitx5-qt fcitx5-gtk fcitx5-bamboo

echo "==> Enabling Flathub"
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

echo "==> Done! Reboot to apply all changes."
