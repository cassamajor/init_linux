#!/usr/bin/env bash

# LUKS Rename
dmsetup rename $GUID sda1_crypt
update-initramfs -c -t -k all
update-grub

# Update System and Install Linux headers
apt update && apt full-upgrade -y
apt install build-essential linux-headers-$(uname -r) -y

# Regen SSH Keys
cd /etc/ssh/
sudo sed -i s/'HashKnownHosts yes'/'HashKnownHosts no'/g ssh_config
mkdir default_kali_keys
mv ssh_host_* default_kali_keys/
dpkg-reconfigure openssh-server
# md5sum ssh_host_*; md5sum default_kali_keys/*

# Set Swappiness
echo "vm.swappiness=1" | sudo tee -a /etc/sysctl.conf

# Skip Grub
sed -i.bkp s"/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0\nGRUB_HIDDEN_TIMEOUT=0\nGRUB_HIDDEN_TIMEOUT_QUIET=true/" /etc/default/grub
update-grub

# Git Init
apt install git -y
git config --global user.name "Desired-Username"
git config --global user.email "desired@email.com"
git config --global core.excludesfile $HOME/.gitignore

# Install Password Store
apt install pass -y
gpg2 --quick-gen-key --yes "Desired-Username <desired@email.com>"
pass init "desired@email.com"
pass git init

# Export and Import Password Store
# gpg2 --export-secret-keys > secret.gpg
# gpg2 --import /path/to/secret.gpg

# Configuration Files
echo -e "set tabstop=2\nset expandtab\nset autoindent" | sudo tee /etc/vim/vimrc.local
echo '-w "\n"' | tee ~/.curlrc > /dev/null
echo -e '\n# Enable proxy for BurpSuite\nexport CHROMIUM_FLAGS="$CHROMIUM_FLAGS --proxy-server=127.0.0.1:8080"\n\n# Enable incognito mode\nexport CHROMIUM_FLAGS="$CHROMIUM_FLAGS --incognito"' | sudo tee -a /etc/chromium.d/default-flags

# Aliases and Functions
echo "alias activate='source venv/bin/activate'" >> ~/.bash_aliases
echo "alias global_activate='source /home/code/virtenv3/bin/activate'" >> ~/.bash_aliases
echo "alias ipify='curl -L api.ipify.org'" >> ~/.bash_aliases
echo "alias pbcopy='xclip -selection clipboard'" >> ~/.bash_aliases
echo "alias pbpaste='xclip -selection clipboard -o'" >> ~/.bash_aliases
echo "alias update='sudo apt update && sudo apt full-upgrade -y'" >> ~/.bash_aliases
echo "alias remove='sudo apt autoremove -y'" >> ~/.bash_aliases
echo "alias backup='sudo ~/disk.sh'" >> ~/.bash_aliases
echo "alias dvwa='sudo systemctl start docker && docker run --rm -it -p 80:80 vulnerables/web-dvwa'" >> ~/.bash_aliases
echo "alias ll='ls -1A'" >> ~/.bash_aliases
echo 'lk() { builtin cd "$*" && ls -1; }' >> ~/.bash_aliases
echo 'dl() { aria2c -c -x 8 "$*"; }' >> ~/.bash_aliases
echo -e "HISTSIZE=-1\nHISTFILESIZE=-1" >> ~/.bashrc
source ~/.bashrc

# ExFAT compatibility, Debugging Tools, and Additional Packages
apt install exfat-utils exfat-fuse -y
apt install lshw inxi htop -y
apt install gedit-plugins xorriso aria2 ffmpeg -y
apt install hexchat -y
apt install chromium -y
apt install ncdu -y

# Install VMware
wget https://www.vmware.com/go/getworkstation-linux -O ~/Downloads/VMware-Workstation-Latest.bundle
chmod +x ~/Downloads/VMware-Workstation-Latest.bundle
sudo ~/Downloads/VMware-Workstation-Latest.bundle --console
# sudo vmware-installer -u vmware-workstation

# Install Docker
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
echo 'deb https://download.docker.com/linux/debian stretch stable' | sudo tee /etc/apt/sources.list.d/docker.list
apt-get update
sudo apt install docker-ce -y
sudo gpasswd -a "${USER}" docker

# Install Nvidia Graphics Card
echo -e "blacklist nouveau\noptions nouveau modeset=0\nalias nouveau off" | sudo tee /etc/modprobe.d/blacklist-nouveau.conf
update-initramfs -u

sudo apt install nvidia-driver nvidia-xconfig ocl-icd-libopencl1 nvidia-cuda-toolkit mesa-utils -y

echo 'Section "ServerLayout"
    Identifier "layout"
    Screen 0 "nvidia"
    Inactive "intel"
EndSection

Section "Device"
    Identifier "nvidia"
    Driver "nvidia"
    BusID "PCI:1:0:0"
EndSection

Section "Screen"
    Identifier "nvidia"
    Device "nvidia"
    Option "AllowEmptyInitialConfiguration"
EndSection

Section "Device"
    Identifier "intel"
    Driver "modesetting"
EndSection

Section "Screen"
    Identifier "intel"
    Device "intel"
EndSection' | sudo tee /etc/X11/xorg.conf

for nvidia in /usr/share/gdm/greeter/autostart/optimus.desktop /etc/xdg/autostart/optimus.desktop; do echo '[Desktop Entry]
Type=Application
Name=Optimus
Exec=sh -c "xrandr --setprovideroutputsource modesetting NVIDIA-0; xrandr --auto"
NoDisplay=true
X-GNOME-Autostart-Phase=DisplayServer' | sudo tee $nvidia; done

sudo sed -i s'/GRUB_CMDLINE_LINUX_DEFAULT="quiet"/GRUB_CMDLINE_LINUX_DEFAULT="quiet nvidia-drm.modeset=1"/' /etc/default/grub

update-grub
