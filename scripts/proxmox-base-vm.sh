#!/bin/bash

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root. Use sudo."
   exit 1
fi

# Display Banner
echo "############################################################"
echo "#                                                          #"
echo "#         Base Install Script for Proxmox VM               #"
echo "#                                                          #"
echo "#               Last Updated: 2025-10-12                   #"
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
#--- Packages Installation
#----------------------------------------------------------------------------
echo -n "Updating and upgrading packages, and installing essentials..."
{
    apt update && apt upgrade -y && apt install -y \
        curl vim wget tree htop git screen python3-pip nfs-common nfs-kernel-server cifs-utils bc \
        apt-transport-https gnupg sudo unzip zip \
        unattended-upgrades apt-listchanges dnsutils cron net-tools tcpdump btop qemu-guest-agent
    systemctl start qemu-guest-agent
} &> /dev/null &
show_spinner $!
if [[ $? -eq 0 ]]; then
    echo -e "        \xE2\x9C\x94 done"
else
    echo -e "        \xE2\x9D\x8C Error: Package installation failed."
    exit 1
fi

#----------------------------------------------------------------------------
#--- Unattended Upgrades
#----------------------------------------------------------------------------
echo -n "Configuring unattended upgrades..."
{
    dpkg-reconfigure -f noninteractive unattended-upgrades
} &> /dev/null &
show_spinner $!
if [[ $? -eq 0 ]]; then
    echo -e "        \xE2\x9C\x94 done"
else
    echo -e "        \xE2\x9D\x8C Error: Failed to configure unattended upgrades."
    exit 1
fi

#----------------------------------------------------------------------------
#--- Date and Timezone
#----------------------------------------------------------------------------
echo -n "Setting timezone to Europe/Vienna..."
{
    timedatectl set-timezone Europe/Vienna && date
} &> /dev/null &
show_spinner $!
if [[ $? -eq 0 ]]; then
    echo -e "        \xE2\x9C\x94 done"
else
    echo -e "        \xE2\x9D\x8C Error: Failed to set timezone."
    exit 1
fi

#----------------------------------------------------------------------------
#--- Vim Configuration
#----------------------------------------------------------------------------
echo -n "Configuring Vim settings..."
{
    cat << 'EOF' > /root/.vimrc
let &t_SI .= "\<Esc>[?2004h"
let &t_EI .= "\<Esc>[?2004l"
inoremap <special> <expr> <Esc>[200~ XTermPasteBegin()
function! XTermPasteBegin()
  set pastetoggle=<Esc>[201~
  set paste
  return ""
endfunction
set backspace=indent,eol,start  " more powerful backspacing
syntax on
EOF
} &> /dev/null &
show_spinner $!
if [[ $? -eq 0 ]]; then
    echo -e "        \xE2\x9C\x94 done"
else
    echo -e "        \xE2\x9D\x8C Error: Failed to configure Vim."
    exit 1
fi

#----------------------------------------------------------------------------
#--- Final Verification
#----------------------------------------------------------------------------
echo -n "Verifying installation and configuration..."
{
    command -v vim &> /dev/null && command -v curl &> /dev/null && [[ -f /root/.vimrc ]]
} &> /dev/null &
show_spinner $!
if [[ $? -eq 0 ]]; then
    echo -e "        \xE2\x9C\x94 done"
else
    echo -e "        \xE2\x9D\x8C Error: Verification failed. Please check the logs."
    exit 1
fi
echo ""
echo "Base install completed successfully!"
