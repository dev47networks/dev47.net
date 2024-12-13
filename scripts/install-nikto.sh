#!/bin/bash

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root. Use sudo."
   exit 1
fi

# Display Banner
echo "############################################################"
echo "#                                                          #"
echo "#               Nikto Installation Script                  #"
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
echo -n "Updating and upgrading system packages..."
{
    apt update && apt upgrade -y
} &> /dev/null &
show_spinner $!
if [[ $? -eq 0 ]]; then
    echo -e "        \xE2\x9C\x94 done"
else
    echo -e "        \xE2\x9D\x8C Error: Failed to update and upgrade packages."
    exit 1
fi

#----------------------------------------------------------------------------
#--- Install Required Packages
#----------------------------------------------------------------------------
echo -n "Installing required packages..."
{
    apt install -y git tree htop perl libnet-ssleay-perl openssl libauthen-pam-perl libio-pty-perl
} &> /dev/null &
show_spinner $!
if [[ $? -eq 0 ]]; then
    echo -e "        \xE2\x9C\x94 done"
else
    echo -e "        \xE2\x9D\x8C Error: Failed to install required packages."
    exit 1
fi

#----------------------------------------------------------------------------
#--- Clone Nikto Repository
#----------------------------------------------------------------------------
echo -n "Cloning the Nikto repository..."
{
    git clone https://github.com/sullo/nikto /tmp/nikto
} &> /dev/null &
show_spinner $!
if [[ $? -eq 0 ]]; then
    echo -e "        \xE2\x9C\x94 done"
else
    echo -e "        \xE2\x9D\x8C Error: Failed to clone the Nikto repository."
    exit 1
fi

#----------------------------------------------------------------------------
#--- Set Up Environment
#----------------------------------------------------------------------------
echo -n "Setting up environment, default conf is at '/etc/nikto.conf' ..."
{
    ln -s /tmp/nikto/program/nikto.pl /usr/local/bin/nikto
    ln -s /tmp/nikto/program/nikto.conf.default /etc/nikto.conf
} &> /dev/null &
show_spinner $!
if [[ $? -eq 0 ]]; then
    echo -e "        \xE2\x9C\x94 done"
else
    echo -e "        \xE2\x9D\x8C Error: Failed to set up the environment."
    exit 1
fi

#----------------------------------------------------------------------------
#--- Verify Nikto Installation
#----------------------------------------------------------------------------
echo -n "Verifying Nikto installation..."
{
    command -v nikto &> /dev/null
} &> /dev/null &
show_spinner $!
if [[ $? -eq 0 ]]; then
    echo -e "        \xE2\x9C\x94 done"
else
    echo -e "        \xE2\x9D\x8C Error: Nikto binary not found in PATH."
    exit 1
fi

#----------------------------------------------------------------------------
#--- Check Nikto Configuration File
#----------------------------------------------------------------------------
echo -n "Checking Nikto configuration file..."
{
    [[ -f /etc/nikto.conf ]]
} &> /dev/null &
show_spinner $!
if [[ $? -eq 0 ]]; then
    echo -e "        \xE2\x9C\x94 done"
else
    echo -e "        \xE2\x9D\x8C Error: Nikto configuration file is missing."
    exit 1
fi

#----------------------------------------------------------------------------
#--- Test Nikto Execution
#----------------------------------------------------------------------------
echo -n "Testing Nikto execution..."
{
    nikto --version &> /dev/null
} &> /dev/null &
show_spinner $!
if [[ $? -eq 0 ]]; then
    echo -e "        \xE2\x9C\x94 done"
else
    echo -e "        \xE2\x9D\x8C Error: Nikto installation appears to have issues."
    exit 1
fi
echo ""
echo "Nikto successfully installed and operational. Usage: nikto -h <HOST:PORT>"