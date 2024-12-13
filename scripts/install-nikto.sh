#!/bin/bash

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root. Use sudo." 
   exit 1
fi

echo "Starting system setup..."

# Update packages
echo "Updating system packages..."
apt update && apt upgrade -y

# Install required packages
echo "Installing required packages..."
apt install -y git tree htop perl libnet-ssleay-perl openssl libauthen-pam-perl libio-pty-perl

# Clone the Nikto repository
echo "Cloning the Nikto repository..."
git clone https://github.com/sullo/nikto /root/nikto

echo "Setup environment..."
cp /root/nikto/program/nikto.pl /usr/local/bin/nikto
chmod +x /usr/local/bin/nikto

echo "Setup complete. Nikto is installed in /root/nikto."
echo "Usage: nikto -h <HOST:PORT>"