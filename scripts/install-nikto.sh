#!/bin/bash

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root. Use sudo." 
   exit 1
fi

# Display Banner
echo "############################################################"
echo "#                                                          #"
echo "#             Nikto Installation Script                    #"
echo "#                                                          #"
echo "#    This script installs Nikto from source on your        #"
echo "#    system. Ensure you run this script as root.           #"
echo "#                                                          #"
echo "#    Last Updated: 2024-12-13                              #"
echo "############################################################"
echo ""

echo "Starting system setup..."

# Update packages
echo "Updating system packages..."
apt update && apt upgrade -y

# Install required packages
echo "Installing required packages..."
apt install -y git tree htop perl libnet-ssleay-perl openssl libauthen-pam-perl libio-pty-perl

# Clone the Nikto repository
echo "Cloning the Nikto repository..."
git clone https://github.com/sullo/nikto /tmp/nikto

# Set up environment
echo "Setting up environment..."
ln -s /tmp/nikto/program/nikto.pl /usr/local/bin/nikto
ln -s /tmp/nikto/program/nikto.conf.default /etc/nikto.conf

# Verify installation
echo "Verifying Nikto installation..."
if command -v nikto &> /dev/null; then
   echo "Nikto binary is accessible."
else
   echo ""
   echo "Error: Nikto binary not found in PATH."
   echo ""
   exit 1
fi

# Check if configuration file exists
if [[ -f /etc/nikto.conf ]]; then
   echo "Nikto configuration file is in place."
else
   echo ""
   echo "Error: Nikto configuration file is missing."
   echo ""
   exit 1
fi

# Check if Nikto runs correctly
echo "Testing Nikto execution..."
nikto --version &> /dev/null
if [[ $? -eq 0 ]]; then
   echo ""
   echo "Nikto successfully installed and operational. Usage: nikto -h <HOST:PORT>"
   echo ""
else
   echo ""
   echo "Error: Nikto installation appears to have issues."
   echo ""
   exit 1
fi