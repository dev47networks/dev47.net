#!/bin/bash

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root. Use sudo."
   exit 1
fi

# Display Banner
echo "############################################################"
echo "#                                                          #"
echo "#                   Remove Node Exporter                   #"
echo "#                                                          #"
echo "#                 Last Updated: 2025-01-01                 #"
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
#--- Variables
#----------------------------------------------------------------------------
VERSION="1.8.2"
INSTALL_DIR="/opt/node_exporter-${VERSION}"
SERVICE_FILE="/etc/systemd/system/node_exporter.service"


#----------------------------------------------------------------------------
#--- Stop and Disable Service
#----------------------------------------------------------------------------
echo -n "Enabling and starting Node Exporter service..."
{
    systemctl stop node_exporter && systemctl disable node_exporter && systemctl daemon-reload
} &> /dev/null &
show_spinner $!
if [[ $? -eq 0 ]]; then
    echo -e "        \xE2\x9C\x94 done"
else
    echo -e "        \xE2\x9D\x8C Error: Failed to stop/disable service."
    exit 1
fi

#----------------------------------------------------------------------------
#--- Remove Systemd Service file
#----------------------------------------------------------------------------
echo -n "Removing Node Exporter service file..."
{
    rm -rf ${SERVICE_FILE}
} &> /dev/null &
show_spinner $!
if [[ $? -eq 0 ]]; then
    echo -e "        \xE2\x9C\x94 done"
else
    echo -e "        \xE2\x9D\x8C Error: Failed to remove service file."
    exit 1
fi

#----------------------------------------------------------------------------
#--- Remove Node Exporter install directory
#----------------------------------------------------------------------------
echo -n "Removing Node Exporter install directory..."
{
    rm -rf ${INSTALL_DIR}
} &> /dev/null &
show_spinner $!
if [[ $? -eq 0 ]]; then
    echo -e "        \xE2\x9C\x94 done"
else
    echo -e "        \xE2\x9D\x8C Error: Failed to remove install directory."
    exit 1
fi


#----------------------------------------------------------------------------
#--- Final Message
#----------------------------------------------------------------------------
echo ""
echo "Node Exporter has been successfully removed!"
echo ""