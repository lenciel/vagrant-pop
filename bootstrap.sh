#!/bin/bash

PPA_REPOSITORIES=(
    'ppa:samrog131/ppa'
)

PKG_DEPENDENCIES=(
    'python-setuptools'
    'python-dev'
    'build-essential'
    'git'
    'g++'
    'gfortran'
    'libopenblas-dev'
    'liblapack-dev'
    'x11-apps'
)

# Enable multiverse.
sed -i "/^# deb.*multiverse/ s/^# //" /etc/apt/sources.list

if test ! $(which add-apt-repository)
    then
    apt-get install -y software-properties-common python-software-properties
fi

# Add apt repositories
for repo in "${PPA_REPOSITORIES[@]}"
do
    add-apt-repository -y $repo
done

apt-get update
apt-get install -y ffmpeg
sudo apt-add-repository --remove ppa:samrog131/ppa
sudo apt-get update
apt-get install -y ${PKG_DEPENDENCIES[@]}

# Fix for matplotlib bug #3029.
# See: https://github.com/matplotlib/matplotlib/issues/3029
if [ ! -f "/usr/include/freetype2/ft2build.h" ]; then
    ln -s /usr/include/freetype2/ft2build.h /usr/include/
fi

# Create a temporary 2Gb swap file so that we don't exaust the virtual
# machines's memory when compiling scipy.
if [ ! -f "/tmp/tmp_swap" ]; then
    dd if=/dev/zero of=/tmp/tmp_swap bs=1024 count=2097152
    mkswap /tmp/tmp_swap
    swapon /tmp/tmp_swap
fi

# Install OpenCV
pushd /tmp
    git clone https://github.com/lenciel/opencv-install-scripts
    pushd opencv-install-scripts/Ubuntu
        ./opencv_2.x_latest.sh
    popd
popd

# Install required python packages.
easy_install pip
pip install -r /vagrant/requirements.txt
