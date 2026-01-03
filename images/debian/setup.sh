#! /bin/bash
set -uexo pipefail

export DEBIAN_FRONTEND=noninteractive

# change mirror
sed -i "s/deb.debian.org/${MIRROR}/g" /etc/apt/sources.list.d/debian.sources
sed -i 's/Components: main/Components: main contrib non-free/g' /etc/apt/sources.list.d/debian.sources
apt-get update -y
apt-get install -y tzdata locales
apt-get upgrade -y

# locale setting
echo 'en_US ISO-8859-1
en_US.UTF-8 UTF-8' > /etc/locale.gen && locale-gen
echo 'export LANG=en_US.UTF-8
export LC_MESSAGES=en_US' > /etc/profile.d/locale.sh
echo "LANG='en_US.UTF-8'" >>/etc/default/locale

# change timezone
ln -fs /usr/share/zoneinfo/$TZ /etc/localtime
dpkg-reconfigure locales tzdata

# change sh
ln -sf /bin/bash /bin/sh

# install package
PKG_LIST="sudo wget vim-tiny mtr-tiny telnet less \
iputils-ping netcat-traditional lsof procps \
iproute2 net-tools dnsutils rsync curl screen"
apt-get install -y $PKG_LIST
update-ca-certificates --fresh

# history setting
sed -r -i -e '/^[[:space:]]*(HISTFILESIZE|HISTCONTROL|HISTSIZE|HISTTIMEFORMAT)=/d' /etc/skel/.bashrc
echo 'export HISTFILESIZE=100000
export HISTCONTROL=ignoredups
export HISTSIZE=10000
export HISTTIMEFORMAT="[%Y-%m-%d %H:%M:%S]  "' > /etc/profile.d/history.sh

# limits setting
echo '*               soft    nofile          65535
*               hard    nofile          65535
root            soft    nofile          65535
root            hard    nofile          65535
root            soft    core            unlimited
root            hard    core            unlimited' > /etc/security/limits.conf

# editor setting
update-alternatives --set editor /usr/bin/vim.tiny >/dev/null
ln -s /usr/bin/vi /usr/bin/vim
echo 'runtime! debian.vim
set nocompatible
set background=dark
set laststatus=2
set showmode
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
set mouse=""
set nobackup
set backspace=indent,eol,start' > /etc/vim/vimrc.local

# clean
rm /etc/cron.daily/* && apt-get clean && rm -rf /var/lib/apt/lists/*
