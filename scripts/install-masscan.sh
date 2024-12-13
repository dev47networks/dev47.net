#!/bin/bash

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root. Use sudo."
   exit 1
fi

# Display Banner
echo "############################################################"
echo "#                                                          #"
echo "#             Masscan Installation Script                  #"
echo "#                                                          #"
echo "#    This script installs Masscan from source on your      #"
echo "#    system. Ensure you run this script as root.           #"
echo "#                                                          #"
echo "#    Last Updated: 2024-12-13                              #"
echo "############################################################"
echo ""

echo "Starting Masscan setup..."

# Update packages
echo "Updating system packages..."
apt update && apt upgrade -y

# Install required packages
echo "Installing required dependencies for Masscan..."
apt install -y git gcc make libpcap-dev

# Clone the Masscan repository
echo "Cloning the Masscan repository..."
git clone https://github.com/robertdavidgraham/masscan /tmp/masscan

# Build Masscan
echo "Building Masscan from source..."
cd /tmp/masscan
make -j$(nproc)

# Install Masscan
echo "Installing Masscan..."
cp /tmp/masscan/bin/masscan /usr/local/bin/masscan

# Verify installation
if command -v masscan &> /dev/null; then
   echo ""
   echo "Masscan installation complete. Usage: masscan -p <PORT> <TARGET>"
   echo ""
else
   echo ""
   echo "Masscan installation failed."
   echo ""
   exit 1
fi