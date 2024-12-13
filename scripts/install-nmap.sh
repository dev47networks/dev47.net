#!/bin/bash

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root. Use sudo."
   exit 1
fi

# Display Banner
echo "############################################################"
echo "#                                                          #"
echo "#                 Nmap Installation Script                 #"
echo "#                                                          #"
echo "#                 Last Updated: 2024-12-13                 #"
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
#--- Update System and Install Nmap
#----------------------------------------------------------------------------
echo -n "Updating package lists and installing Nmap..."
{
    apt update && apt install -y nmap
} &> /dev/null &
show_spinner $!
if [[ $? -eq 0 ]]; then
    echo -e "        \xE2\x9C\x94 done"
else
    echo -e "        \xE2\x9D\x8C Error: Failed to install Nmap."
    exit 1
fi

#----------------------------------------------------------------------------
#--- Verify Nmap Installation
#----------------------------------------------------------------------------
echo -n "Verifying Nmap installation..."
{
    command -v nmap &> /dev/null
} &> /dev/null &
show_spinner $!
if [[ $? -eq 0 ]]; then
    echo -e "        \xE2\x9C\x94 done"
else
    echo -e "        \xE2\x9D\x8C Error: Nmap installation verification failed."
    exit 1
fi

#----------------------------------------------------------------------------
#--- Final Message
#----------------------------------------------------------------------------
echo ""
echo "Nmap installation completed successfully!"