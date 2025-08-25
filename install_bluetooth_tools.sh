#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Store the script's working directory
WORKING_DIR="$(pwd)"

echo "Updating apt repositories..."
sudo apt-get update
sudo apt-get -y upgrade

echo "Installing dependencies from apt..."
sudo apt install -y bluez-tools bluez-hcidump libbluetooth-dev \
                     git gcc python3-pip python3-setuptools \
                     python3-pydbus python3-venv

echo "Cloning and installing pybluez from source..."
git clone https://github.com/pybluez/pybluez.git
cd pybluez
# No need for sudo here if the entire script is run with sudo
python3 setup.py install
cd ..
rm -rf pybluez

echo "Cloning BlueZ repository and building bdaddr tool..."
git clone --depth=1 https://github.com/bluez/bluez.git
gcc -o bdaddr bluez/tools/bdaddr.c bluez/src/oui.c -I bluez -lbluetooth
sudo mv bdaddr /usr/local/bin/
rm -rf bluez

echo "Cloning BlueDucky repository..."
# This will now clone into the current working directory
git clone https://github.com/palacita135/BlueDucky.git

cd BlueDucky

echo "Creating Python virtual environment..."
# Use the correct path for the virtual environment and its dependencies
python3 -m venv venv

echo "Installing BlueDucky Python dependencies in virtual environment..."
# Run pip from within the virtual environment
./venv/bin/pip install -r requirements.txt || ./venv/bin/pip install --break-system-packages -r requirements.txt

echo "Bringing up bluetooth interface..."
sudo hciconfig hci0 up

echo "Running BlueDucky..."
# Run the script using the virtual environment's Python interpreter
./venv/bin/python3 BlueDucky.py
