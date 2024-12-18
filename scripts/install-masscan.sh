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
echo "#               Last Updated: 2024-12-13                   #"
echo "#                                                          #"
echo "############################################################"
echo ""

# Function to show a loading spinner
show_spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

#----------------------------------------------------------------------------
#--- Update and Upgrade Packages
#----------------------------------------------------------------------------
echo -n "Updating system packages..."
{
    apt update && apt upgrade -y
} &> /dev/null &
show_spinner $!
if [[ $? -eq 0 ]]; then
    echo -e "        \xE2\x9C\x94 done"
else
    echo -e "        \xE2\x9D\x8C Error: Failed to update system packages."
    exit 1
fi

#----------------------------------------------------------------------------
#--- Install Required Dependencies
#----------------------------------------------------------------------------
echo -n "Installing required dependencies for Masscan..."
{
    apt install -y git gcc make libpcap-dev
} &> /dev/null &
show_spinner $!
if [[ $? -eq 0 ]]; then
    echo -e "        \xE2\x9C\x94 done"
else
    echo -e "        \xE2\x9D\x8C Error: Failed to install required dependencies."
    exit 1
fi

#----------------------------------------------------------------------------
#--- Clone Masscan Repository
#----------------------------------------------------------------------------
echo -n "Cloning the Masscan repository..."
{
    git clone https://github.com/robertdavidgraham/masscan /tmp/masscan
} &> /dev/null &
show_spinner $!
if [[ $? -eq 0 ]]; then
    echo -e "        \xE2\x9C\x94 done"
else
    echo -e "        \xE2\x9D\x8C Error: Failed to clone the Masscan repository."
    exit 1
fi

#----------------------------------------------------------------------------
#--- Build Masscan from Source
#----------------------------------------------------------------------------
echo -n "Building Masscan from source..."
{
    cd /tmp/masscan
    make -j$(nproc)
} &> /dev/null &
show_spinner $!
if [[ $? -eq 0 ]]; then
    echo -e "        \xE2\x9C\x94 done"
else
    echo -e "        \xE2\x9D\x8C Error: Failed to build Masscan from source."
    exit 1
fi

#----------------------------------------------------------------------------
#--- Install Masscan
#----------------------------------------------------------------------------
echo -n "Installing Masscan..."
{
    cp /tmp/masscan/bin/masscan /usr/local/bin/masscan
} &> /dev/null &
show_spinner $!
if [[ $? -eq 0 ]]; then
    echo -e "        \xE2\x9C\x94 done"
else
    echo -e "        \xE2\x9D\x8C Error: Failed to install Masscan."
    exit 1
fi

#----------------------------------------------------------------------------
#--- Verify Masscan Installation
#----------------------------------------------------------------------------
echo -n "Verifying Masscan installation..."
{
    command -v masscan &> /dev/null
} &> /dev/null &
show_spinner $!
if [[ $? -eq 0 ]]; then
    echo -e "        \xE2\x9C\x94 done"
else
    echo -e "        \xE2\x9D\x8C Error: Masscan installation verification failed."
    exit 1
fi
echo ""
echo "Masscan installed and operational. Usage: masscan -p <PORT> <TARGET>"