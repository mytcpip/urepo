#!/bin/bash

# Check number of parameters
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <username> <password>"
    exit 1
fi

USER_NAME="$1"
PASSWORD="$2"
REALM="pve"
FULL_USER="${USER_NAME}@${REALM}"

# Check if script is executed as root
if [ "$EUID" -ne 0 ]; then
    echo "Error: This script must be run as root."
    exit 1
fi

# Check if user already exists
if pveum user list | awk '{print $1}' | grep -q "^${FULL_USER}$"; then
    echo "Error: User ${FULL_USER} already exists."
    exit 1
fi

# Create user
pveum user add "${FULL_USER}" --password "${PASSWORD}"
if [ "$?" -ne 0 ]; then
    echo "Error while creating the user."
    exit 1
fi

# Assign Administrator role at root path (/)
pveum aclmod / -user "${FULL_USER}" -role Administrator
if [ "$?" -ne 0 ]; then
    echo "Error while assigning Administrator role."
    exit 1
fi

echo "User ${FULL_USER} successfully created with Administrator role on the entire platform."
exit 0
