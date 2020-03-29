{% set linux_header = salt['cmd.shell']('echo $(uname -r)') %}

Upgrade to latest version:
  pkg.uptodate:
    - refresh: True

Update System and Install Linux headers:
  cmd.run:
    - name: apt-get update && apt-get full-upgrade -y
    - require:
        - pkg: Upgrade to latest version
  pkg.latest:
    - pkgs:
      - build-essential
      - linux-headers-{{ linux_header }}
    - require:
        - cmd: Update System and Install Linux headers

Install base packages:
  pkg.installed:
    - pkgs:
      - jq
      - docker.io
      - docker-compose
      - pass
      - mtr
      - iptraf-ng
      - ncdu
      - exfat-utils
      - exfat-fuse
      - lshw
      - inxi
      - htop
      - gedit-plugins
      - xorriso
      - aria2
      - ffmpeg
      - hexchat
      - chromium
      - flameshot
    - require:
      - pkg: Update System and Install Linux headers
  module.run:
    - name: pkg.autoremove
    - require:
      - pkg: Install base packages

Install Android Platform Tools:
  pkg.installed:
    - name: android-sdk-platform-tools
  archive.extracted:
    - name: /usr/lib/android-sdk/
    - source: https://dl.google.com/android/repository/platform-tools-latest-linux.zip
    - skip_verify: True
    - keep_source: False
    - overwrite: True
    - clean: True
    - require:
      - pkg: Install Android Platform Tools

Manage ~/.bash_aliases:
  file.managed:
    - name: ~/.bash_aliases
    - source: salt://files/bash_aliases
    - backup: minion
    - mode: 644

Initialize Git:
  file.managed:
    - name: ~/.gitconfig
    - contents: |
        [user]
        	email = email@address.com
        	name = Username
        [core]
        	excludesfile = ~/code/.gitignore

Set Vim Configuration File:
  file.managed:
    - name: /etc/vim/vimrc.local
    - contents: |
        set tabstop=2
        set expandtab
        set autoindent

Set Curl Configuration File:
  file.managed:
    - name: /.curlrc
    - contents: -w "\n"

Set Swappiness:
  file.append:
    - name: /etc/sysctl.conf
    - text: |

        vm.swappiness=1

Set Chromium Configuration File:
  file.append:
    - name: /etc/chromium.d/default-flags
    - text: |

        # Enable proxy for BurpSuite
        export CHROMIUM_FLAGS="$CHROMIUM_FLAGS --proxy-server=127.0.0.1:8080"

        # Enable incognito mode
        export CHROMIUM_FLAGS="$CHROMIUM_FLAGS --incognito"



#########################################################
######### ABOVE IS TESTED | BELOW IS UNTESTED ###########
#########################################################

# TODO: Refer to [live-build-config](https://www.kali.org/docs/development/live-build-a-custom-kali-iso/)
# TODO: AppImageKit to integrate Bitwarden w/ Gnome
# TODO: Add Wireguard config file from Router, configure + install
# TODO: Install Nvidia GPU
# TODO: Find config files for Gnome, Firefox, Terminator, Pycharm, and Hexchat
#  - https://askubuntu.com/questions/32631/how-to-configure-firefox-from-terminal


Create /etc/wireguard/ directory:
  file.directory:
    - name: /etc/wireguard/
    - user: root
    - group: root
    - dir_mode: 710
    - file_mode: 700
    - makedirs: True

Install WireGuard Package:
  pkg.installed:
    - name: wireguard
    - require:
        - file: Create /etc/wireguard/ directory
  file.managed:
    - name: /etc/wireguard/wg0.conf
    - source: salt://files/wg0.conf
    - require:
      - pkg: Install Wireguard Package

#{% set pycharm_version = salt['cmd.script']('salt://files/pycharm_latest.py') %}
Download Pycharm:
  cmd.script:
    - source: salt://files/pycharm_latest.py
    - runas: root
  archive.extracted:
    - name: /opt/
    - overwrite: True
    - clean: True
    - source: /tmp/pycharm-latest.tar.gz
    - require:
      - cmd: Download Pycharm

Initialize Password Store:
  git.latest:
  - name: fauxsys@boxed:/home/fauxsys/Pass.git
  - target: /root/.password-store
  - identity: /root/.ssh/ethernet

#gpg2 --quick-gen-key --yes "Fauxsys <fiber.cipher@gmail.com>"
#pass init "fiber.cipher@gmail.com"
#pass git init

# Export and Import Password Store
# gpg2 --export-secret-keys > secret.gpg
# gpg2 --import /path/to/secret.gpg


Regen SSH Keys:
  file.line:
    - name: /etc/ssh/ssh_config
    - mode: replace
    - match: HashKnownHosts yes
    - content: HashKnownHosts no

Regen SSH Keys 2:
  file.replace:
    - name: /etc/ssh/ssh_config
    - pattern: HashKnownHosts yes
    - repl: HashKnownHosts no


cd /etc/ssh/
sudo sed -i s/'HashKnownHosts yes'/'HashKnownHosts no'/g ssh_config
mkdir default_kali_keys
mv ssh_host_* default_kali_keys/
dpkg-reconfigure openssh-server
# md5sum ssh_host_*; md5sum default_kali_keys/*

# Need to replace not append
Set unlimited terminal history:
  file.append:
    - name: ~/.bashrc
    - text:
        -
        - HISTSIZE=-1
        - HISTFILESIZE=-1


Skip Grub:
  file.replace:
    - name: /etc/default/grub
    - pattern: GRUB_TIMEOUT=5
    - repl:
      - GRUB_TIMEOUT=0
      - GRUB_HIDDEN_TIMEOUT=0
      - GRUB_HIDDEN_TIMEOUT_QUIET=true
  cmd.run:
    - name: update-grub
    - require:
      - file: Skip Grub

Skip Grub 2:
  file.blockreplace:
    - name: /etc/default/grub
    - marker_start: GRUB_TIMEOUT=5
    - marker_end: GRUB_TIMEOUT=5
    - content:
        - GRUB_TIMEOUT=0
        - GRUB_HIDDEN_TIMEOUT=0
        - GRUB_HIDDEN_TIMEOUT_QUIET=true
  cmd.run:
    - name: update-grub
    - require:
      - file: Skip Grub 2

Skip Grub 3:
  file.line:
    - name: /etc/default/grub
    - marker_start: GRUB_TIMEOUT=5
    - marker_end: GRUB_TIMEOUT=5
    - content:
        - GRUB_TIMEOUT=0
        - GRUB_HIDDEN_TIMEOUT=0
        - GRUB_HIDDEN_TIMEOUT_QUIET=true
  cmd.run:
    - name: update-grub
    - require:
      - file: Skip Grub 2


sed -i.bkp s"/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0\nGRUB_HIDDEN_TIMEOUT=0\nGRUB_HIDDEN_TIMEOUT_QUIET=true/" /etc/default/grub
update-grub

Download Bitwarden:
  cmd.script:
    - source: salt://files/bitwarden_latest_v2.py

~/code/.gitignore
.idea
.DS_Store