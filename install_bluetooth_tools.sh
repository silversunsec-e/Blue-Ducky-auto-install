#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "Updating apt repositories..."
sudo apt-get update
sudo apt-get -y upgrade

echo "Installing dependencies from apt..."
sudo apt install -y bluez-tools bluez-hcidump libbluetooth-dev \
                    git gcc python3-pip python3-setuptools \
                    python3-pydbus

echo "Cloning and installing pybluez from source..."
git clone https://github.com/pybluez/pybluez.git
cd pybluez
sudo python3 setup.py install
cd ..
rm -rf pybluez

echo "Cloning BlueZ repository and building bdaddr tool..."
cd ~/
git clone --depth=1 https://github.com/bluez/bluez.git
gcc -o bdaddr ~/bluez/tools/bdaddr.c ~/bluez/src/oui.c -I ~/bluez -lbluetooth
sudo cp bdaddr /usr/local/bin/
rm -rf ~/bluez
rm bdaddr

echo "Installation complete!"
