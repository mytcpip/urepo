#!/bin/bash
# All information comes from the official PROXMOX website
# https://pve.proxmox.com/wiki/Package_Repositories
# Upgrade Enterprise repositories to No-Subscription
# Valid for PROXMOX version 9

# Check if the pveversion command exists
if ! command -v pveversion &> /dev/null; then
    echo "Error: Proxmox does not appear to be installed on this system."
    exit 1
fi

PVE_MAJOR_VERSION=$(pveversion | cut -d'/' -f2 | cut -d'.' -f1)

# Validar si la versión es la 9
if [ "$PVE_MAJOR_VERSION" -ne 9 ]; then
    echo "The Proxmox version is NOT version 9."
    exit 1
fi

# Define the file paths
ENTERPRISE_FILE="/etc/apt/sources.list.d/pve-enterprise.sources"
CEPH_FILE="/etc/apt/sources.list.d/ceph.sources"

# Check if both files do NOT exist
if [[ ! -f "$ENTERPRISE_FILE" || ! -f "$CEPH_FILE" ]]; then
    echo "Error: Critical configuration files are missing from /etc/apt/sources.list.d/"
    echo "Ensure that pve-enterprise.sources and ceph.sources are present."
    exit 1
fi

sed -i '/^[^#]/ s/^/#/' "$ENTERPRISE_FILE"

# Define the file paths
FICHERO="/etc/apt/sources.list.d/proxmox.sources"

# Create or overwrite the file with the new content
cat <<EOF > "$FICHERO"
Types: deb
URIs: http://download.proxmox.com/debian/pve
Suites: trixie
Components: pve-no-subscription
Signed-By: /usr/share/keyrings/proxmox-archive-keyring.gpg
EOF

# Change permissions to make it readable by the system (optional but recommended)
chmod 644 "$FICHERO"
echo "The $FILE file has been successfully created/initialized for Proxmox 9 (Trixie)."

# Define the file paths
FICHERO_CEPH="/etc/apt/sources.list.d/ceph.sources"

# Create/Overwrite the file with the requested content

cat <<EOF > "$FICHERO_CEPH"
# Types: deb
# URIs: https://enterprise.proxmox.com/debian/ceph-squid
# Suites: trixie
# Components: enterprise
# Signed-By: /usr/share/keyrings/proxmox-archive-keyring.gpg

Types: deb
URIs: http://download.proxmox.com/debian/ceph-squid
Suites: trixie
Components: no-subscription
Signed-By: /usr/share/keyrings/proxmox-archive-keyring.gpg
EOF

# Adjust permissions for system security
chmod 644 "$FICHERO_CEPH"

echo "The $FICHERO_CEPH file has been configured correctly."

# We removed the "no subscription activated" message that appears when starting up.

FILE="/usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js"
EXTENSION=".bak.$(date +%d%m%y%H%M%S)"

cp "$FILE" "$FILE.bak.$EXTENSION"
echo "Backing proxmoxlib.js file in proxmoxlib.js.$EXTENSION"
sed -i "s/res\.data\.status\.toLowerCase() !== 'active'/res.data.status.toLowerCase() === 'active'/g" "$FILE"
echo "Banner No-Subscription deleted"
echo

exit 0
