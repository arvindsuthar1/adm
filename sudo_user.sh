#!/bin/bash

# Define Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
RESET='\033[0m'

# Function to display a message in color
echo_color() {
    echo -e "$1$2$RESET"
}

# Check if the script is running as root
if [ "$(id -u)" -ne 0 ]; then
    echo_color $RED "You must run this script as root or with sudo."
    exit 1
fi
# Check users in home directory 
ls /home/
# Prompt for the username
echo_color $CYAN "Enter the username for the new administrator:"
read -p "Username: " username

# Check if the username already exists
if id "$username" &>/dev/null; then
    echo_color $RED "User '$username' already exists."
    
    grep "NOPASSWD" /etc/sudoers.d/$username &>/dev/null; 
    if [ $? -eq 0 ]; then
    	echo_color $RED "User '$username' already in sudo. Exiting..."
    	exit 1
    else
    	echo "irs-tech  ALL=(ALL) NOPASSWD: /usr/bin/apt, /usr/bin/systemctl, /usr/bin/sed, /usr/bin/vi" | sudo tee /etc/sudoers.d/$username  > /dev/null
        echo_color $GREEN "User '$username' added successfully in sudo. Exiting..."
    exit 1
	fi
fi
# Prompt for the password
echo_color $CYAN "Enter the password for the new administrator:"
read -s -p "Password: " password
echo

# Create the user
echo_color $GREEN "Creating user '$username'..."
useradd -m -G sudo "$username"
if [ $? -eq 0 ]; then
    echo_color $GREEN "User '$username' created successfully."
else
    echo_color $RED "Failed to create user '$username'. Exiting..."
    exit 1
fi

# Set the password for the user
echo "$username:$password" | chpasswd
if [ $? -eq 0 ]; then
    echo_color $GREEN "Password for '$username' set successfully."
else
    echo_color $RED "Failed to set password for '$username'. Exiting..."
    exit 1
fi

# Enable sudo access for the user
echo_color $YELLOW "Granting sudo access to '$username'..."
usermod -aG sudo "$username"
if [ $? -eq 0 ]; then
    echo_color $GREEN "'$username' has been granted sudo privileges."
else
    echo_color $RED "Failed to grant sudo privileges to '$username'."
    exit 1
fi

echo_color $BLUE "Administrator user '$username' created and configured successfully!"

echo "irs-tech  ALL=(ALL) NOPASSWD: /usr/bin/apt, /usr/bin/systemctl, /usr/bin/sed, /usr/bin/vi" | sudo tee /etc/sudoers.d/irs-tech > /dev/null

