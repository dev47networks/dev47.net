#!/bin/bash

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root. Use sudo."
   exit 1
fi

# Display Banner
echo "############################################################"
echo "#                                                          #"
echo "#              Install Docker for Proxmox LXC              #"
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
    # Update and install prerequisites
    apt-get update && apt-get install -y ca-certificates curl

    # Create keyrings directory with correct permissions
    install -m 0755 -d /etc/apt/keyrings

    # Download Docker GPG key
    curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
    chmod a+r /etc/apt/keyrings/docker.asc

    # Add Docker repository to APT sources
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Update APT and install Docker packages
    apt-get update && apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
} &> /dev/null &
show_spinner $!
if [[ $? -eq 0 ]]; then
    echo -e "        \xE2\x9C\x94 done"
else
    echo -e "        \xE2\x9D\x8C Error: Failed to install Docker."
    exit 1
fi

#----------------------------------------------------------------------------
#--- Install dops
#----------------------------------------------------------------------------
echo -n "Installing better-docker-ps (dops)..."
{
    wget "https://github.com/Mikescher/better-docker-ps/releases/latest/download/dops_linux-amd64-static" -O "/usr/bin/dops" && chmod +x "/usr/bin/dops"
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
#--- Install Loki extension
#----------------------------------------------------------------------------
echo -n "Installing Loki extension..."
{
    docker plugin install grafana/loki-docker-driver:3.4.2-amd64 --alias loki --grant-all-permissions
} &> /dev/null &
show_spinner $!
if [[ $? -eq 0 ]]; then
    echo -e "        \xE2\x9C\x94 done"
else
    echo -e "        \xE2\x9D\x8C Error: Failed to install dops."
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