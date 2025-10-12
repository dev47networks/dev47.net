#!/bin/bash

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root. Use sudo."
   exit 1
fi

# Display Banner
echo "############################################################"
echo "#                                                          #"
echo "#                  Install Node Exporter                   #"
echo "#                                                          #"
echo "#                 Last Updated: 2025-05-29                 #"
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
VERSION="1.9.1"
DOWNLOAD_URL="https://github.com/prometheus/node_exporter/releases/download/v${VERSION}/node_exporter-${VERSION}.linux-amd64.tar.gz"
INSTALL_DIR="/opt/node_exporter-${VERSION}"
SERVICE_FILE="/etc/systemd/system/node_exporter.service"

#----------------------------------------------------------------------------
#--- Update System and Install Dependencies
#----------------------------------------------------------------------------
echo -n "Updating system and installing dependencies..."
{
    apt update && apt install -y curl tar
} &> /dev/null &
show_spinner $!
if [[ $? -eq 0 ]]; then
    echo -e "        \xE2\x9C\x94 done"
else
    echo -e "        \xE2\x9D\x8C Error: Failed to install dependencies."
    exit 1
fi

#----------------------------------------------------------------------------
#--- Download Node Exporter
#----------------------------------------------------------------------------
echo -n "Downloading Node Exporter v${VERSION}..."
{
    curl -LO ${DOWNLOAD_URL}
} &> /dev/null &
show_spinner $!
if [[ $? -eq 0 ]]; then
    echo -e "        \xE2\x9C\x94 done"
else
    echo -e "        \xE2\x9D\x8C Error: Failed to download Node Exporter."
    exit 1
fi

#----------------------------------------------------------------------------
#--- Extract Node Exporter
#----------------------------------------------------------------------------
echo -n "Extracting Node Exporter..."
{
    tar -xvzf node_exporter-${VERSION}.linux-amd64.tar.gz -C /opt && mv /opt/node_exporter-${VERSION}.linux-amd64 ${INSTALL_DIR}
} &> /dev/null &
show_spinner $!
if [[ $? -eq 0 ]]; then
    echo -e "        \xE2\x9C\x94 done"
else
    echo -e "        \xE2\x9D\x8C Error: Failed to extract Node Exporter."
    exit 1
fi

#----------------------------------------------------------------------------
#--- Create Systemd Service File
#----------------------------------------------------------------------------
echo -n "Creating Node Exporter service file..."
{
    cat > ${SERVICE_FILE} <<EOF
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=root
ExecStart=${INSTALL_DIR}/node_exporter
Restart=always

[Install]
WantedBy=multi-user.target
EOF
} &> /dev/null &
show_spinner $!
if [[ $? -eq 0 ]]; then
    echo -e "        \xE2\x9C\x94 done"
else
    echo -e "        \xE2\x9D\x8C Error: Failed to create service file."
    exit 1
fi

#----------------------------------------------------------------------------
#--- Enable and Start Service
#----------------------------------------------------------------------------
echo -n "Enabling and starting Node Exporter service..."
{
    systemctl daemon-reload && systemctl enable node_exporter && systemctl start node_exporter
} &> /dev/null &
show_spinner $!
if [[ $? -eq 0 ]]; then
    echo -e "        \xE2\x9C\x94 done"
else
    echo -e "        \xE2\x9D\x8C Error: Failed to enable/start service."
    exit 1
fi

#----------------------------------------------------------------------------
#--- Verify Node Exporter Service
#----------------------------------------------------------------------------
echo -n "Verifying Node Exporter service status..."
{
    systemctl is-active --quiet node_exporter
} &> /dev/null &
show_spinner $!
if [[ $? -eq 0 ]]; then
    echo -e "        \xE2\x9C\x94 running"
else
    echo -e "        \xE2\x9D\x8C Error: Node Exporter service is not running."
    exit 1
fi

#----------------------------------------------------------------------------
#--- Cleanup
#----------------------------------------------------------------------------
echo -n "Cleaning up downloaded files..."
{
    rm node_exporter-${VERSION}.linux-amd64.tar.gz
} &> /dev/null &
show_spinner $!
if [[ $? -eq 0 ]]; then
    echo -e "        \xE2\x9C\x94 done"
else
    echo -e "        \xE2\x9D\x8C Warning: Cleanup failed."
fi

#----------------------------------------------------------------------------
#--- Final Message
#----------------------------------------------------------------------------
echo ""
echo "Node Exporter has been successfully installed and is accessible at:"
echo "  http://<server-ip>:9100/metrics"
echo ""