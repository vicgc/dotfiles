#!/usr/bin/env bash

USE_SSD=true
SYS_DISK=sda

SYSFS_CONF=/etc/sysfs.conf
SYSCTL_LOCAL_CONF=/etc/sysctl.d/local.conf


echo "Include contrib and non-free packages"
sed -i 's/wheezy main$/wheezy main contrib non-free/' /etc/apt/sources.list

echo "Add 386 architecture dependencies"
dpkg --add-architecture i386
aptitude update
aptitude  -f install
# Upgrade system to latest state
aptitude  safe-upgrade

# Customizations for SSD
if [ $USE_SSD == true ]; then
    echo "Optimize SSD performance..."
    aptitude  install sysfsutils

    # Switch to `deadline` scheduler suitable for SSD.
    if ! grep -q "scheduler.*=.*deadline" ${SYSFS_CONF}; then
        echo "block/$SYS_DISK/queue/scheduler = deadline" >> ${SYSFS_CONF}
    fi

    # Tweak kernel parameters.
    if [ -f ${SYSCTL_LOCAL_CONF} ]; then
        sed -i '/^vm.swappiness/c\vm.swappiness=0' ${SYSCTL_LOCAL_CONF}
        sed -i '/^vm.vfs_cache_pressure/c\vm.vfs_cache_pressure=50' ${SYSCTL_LOCAL_CONF}
    else
        touch ${SYSCTL_LOCAL_CONF}
        echo "vm.swappiness=0" >> ${SYSCTL_LOCAL_CONF}
        echo "vm.vfs_cache_pressure=50" >> ${SYSCTL_LOCAL_CONF}
    fi

    # Mount var directories to tmpfs to keep them in RAM.
    if ! grep -q "/var/tmp" /etc/fstab; then
        echo "tmpfs /var/tmp    tmpfs   defaults,relatime,mode=1777 0 0" >> /etc/fstab
    fi
fi


echo "Install packages..."

# Core system graphics components
aptitude  install ntp
aptitude  install xserver-xorg xserver-xorg-input-synaptics xinit slim
aptitude  install xmonad libghc-xmonad-dev libghc-xmonad-contrib-dev xmobar
aptitude  install xcompmgr  # for transparency support
aptitude  install icc-profiles sampleicc-tools

# Sound
aptitude  install alsa paman pavucontrol

# Utils for better user experience
aptitude  install xxkb nitrogen stalonetray 
aptitude  install suckless-tools xbacklight moreutils
aptitude  install qt4-qtconfig gtk2-engines dmz-cursor-theme
aptitude  install libxft2 libxft-dev

# Network utils
aptitude  install x11vnc traceroute

aptitude  install network-manager network-manager-gnome network-manager-openvpn
# Let network manager to manage ifupdown
sed -i '/^managed=false/c\managed=true' /etc/NetworkNanager/NetworkManager.conf

aptitude  install pidgin iceweasel

# Preferred packages
aptitude  install mercurial git
aptitude  install tree htop tmux mc vifm rxvt-unicode scrot xclip
aptitude  install exuberant-ctags source-highlight checkinstall
aptitude  install openssh-client openssh-server

aptitude  install python-pip python3-all python2.7-dev python3-dev
pip install udiskie  # automount usb devices
pip install virtualenvwrapper
aptitude  install python-notify  # dependency for udiskie

# Multimedia
aptitude  install goldendict vlc x264
aptitude  install libnotify-bin notify-osd
aptitude  install fonts-liberation fonts-linuxlibertine
aptitude  install flashplugin-nonfree ttf-mscorefonts-installer