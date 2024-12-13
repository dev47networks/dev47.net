#!/bin/bash

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root. Use sudo."
   exit 1
fi

# Display Banner
echo "############################################################"
echo "#                                                          #"
echo "#              Install Docker for Proxmox VM               #"
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
#--- Install Docker
#----------------------------------------------------------------------------
echo -n "Installing Docker..."
{
    curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh && rm -rf get-docker.sh
} &> /dev/null &
show_spinner $!
if [[ $? -eq 0 ]]; then
    echo -e "        \xE2\x9C\x94 done"
else
    echo -e "        \xE2\x9D\x8C Error: Failed to install Docker."
    exit 1
fi

#----------------------------------------------------------------------------
#--- Verify Docker Installation
#----------------------------------------------------------------------------
echo -n "Verifying Docker installation..."
{
    docker ps &> /dev/null
} &> /dev/null &
show_spinner $!
if [[ $? -eq 0 ]]; then
    echo -e "        \xE2\x9C\x94 done"
else
    echo -e "        \xE2\x9D\x8C Error: Docker installation verification failed."
    exit 1
fi

#----------------------------------------------------------------------------
#--- Install dops
#----------------------------------------------------------------------------
echo -n "Installing better-docker-ps (dops)..."
{
    sudo wget "https://github.com/Mikescher/better-docker-ps/releases/latest/download/dops_linux-amd64-static" -O "/usr/local/bin/dops" && sudo chmod +x "/usr/local/bin/dops"
} &> /dev/null &
show_spinner $!
if [[ $? -eq 0 ]]; then
    echo -e "        \xE2\x9C\x94 done"
else
    echo -e "        \xE2\x9D\x8C Error: Failed to install dops."
    exit 1
fi

#----------------------------------------------------------------------------
#--- Verify dops Installation
#----------------------------------------------------------------------------
echo -n "Verifying dops installation..."
{
    dops -a &> /dev/null
} &> /dev/null &
show_spinner $!
if [[ $? -eq 0 ]]; then
    echo -e "        \xE2\x9C\x94 done"
else
    echo -e "        \xE2\x9D\x8C Error: dops installation verification failed."
    exit 1
fi

#----------------------------------------------------------------------------
#--- Enable Docker API
#----------------------------------------------------------------------------
echo -n "Enabling Docker API..."
{
    echo '{"hosts": ["tcp://0.0.0.0:2375", "unix:///var/run/docker.sock"]}' > /etc/docker/daemon.json

    mkdir -p /etc/systemd/system/docker.service.d/
    cat << 'EOF' > /etc/systemd/system/docker.service.d/override.conf
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd
EOF

    systemctl daemon-reload && systemctl restart docker.service
} &> /dev/null &
show_spinner $!
if [[ $? -eq 0 ]]; then
    echo -e "        \xE2\x9C\x94 done"
else
    echo -e "        \xE2\x9D\x8C Error: Failed to enable Docker API."
    exit 1
fi

#----------------------------------------------------------------------------
#--- Final Verification
#----------------------------------------------------------------------------
echo -n "Verifying Docker API..."
{
    curl -s http://localhost:2375/version &> /dev/null
} &> /dev/null &
show_spinner $!
if [[ $? -eq 0 ]]; then
    echo -e "        \xE2\x9C\x94 done"
else
    echo -e "        \xE2\x9D\x8C Error: Docker API verification failed."
    exit 1
fi
echo ""
echo "Docker configuration completed successfully!"