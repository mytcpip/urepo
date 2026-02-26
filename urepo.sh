#!/bin/bash
# Toda la información sale de la página oficial de PROXMOX
# https://pve.proxmox.com/wiki/Package_Repositories
# Actualiza los repositorios de Enterprise a No-Subscription
# Valido para la versión 9 de PROXMOX
#

# Verificar si el comando pveversion existe
if ! command -v pveversion &> /dev/null; then
    echo "Error: Proxmox no parece estar instalado en este sistema."
    exit 1
fi

PVE_MAJOR_VERSION=$(pveversion | cut -d'/' -f2 | cut -d'.' -f1)

# Validar si la versión es la 9
if [ "$PVE_MAJOR_VERSION" -ne 9 ]; then
    echo "La versión de Proxmox NO es la 9."
    exit 1
fi

# Definir las rutas de los archivos
ENTERPRISE_FILE="/etc/apt/sources.list.d/pve-enterprise.sources"
CEPH_FILE="/etc/apt/sources.list.d/ceph.sources"

# Comprobar si NO existen ambos archivos
# -f verifica si el archivo existe y es un fichero regular
if [[ ! -f "$ENTERPRISE_FILE" || ! -f "$CEPH_FILE" ]]; then
    echo "Error: Faltan archivos de configuración críticos en /etc/apt/sources.list.d/"
    echo "Asegúrese de que pve-enterprise.sources y ceph.sources estén presentes."
    exit 1
fi

# Usamos sed para insertar # solo en líneas que NO empiezan por #
# La expresión ^[^#] busca cualquier línea donde el primer carácter no sea #
sed -i '/^[^#]/ s/^/#/' "$ENTERPRISE_FILE"

# Definir la ruta del archivo
FICHERO="/etc/apt/sources.list.d/proxmox.sources"

# Crear o sobrescribir el archivo con el nuevo contenido
# El uso de > asegura que si el archivo existía, se borre y se cree de nuevo
cat <<EOF > "$FICHERO"
Types: deb
URIs: http://download.proxmox.com/debian/pve
Suites: trixie
Components: pve-no-subscription
Signed-By: /usr/share/keyrings/proxmox-archive-keyring.gpg
EOF

# Cambiar permisos para que sea legible por el sistema (opcional pero recomendado)
chmod 644 "$FICHERO"
echo "El archivo $FICHERO ha sido creado/inicializado correctamente para Proxmox 9 (Trixie)."

# Definir la ruta del archivo
FICHERO_CEPH="/etc/apt/sources.list.d/ceph.sources"

# Crear/Sobrescribir el archivo con el contenido solicitado
# Nota: La versión 'squid' corresponde a la versión de Ceph para Proxmox 9 (Trixie)
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

# Ajustar permisos para seguridad del sistema
chmod 644 "$FICHERO_CEPH"

echo "El archivo $FICHERO_CEPH ha sido configurado correctamente."

# Quitamos el aviso de no tener subscription activada que aparece al iniciar.

FILE="/usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js"

cp "$FILE" "$FILE.bak"

sed -i "s/res\.data\.status\.toLowerCase() !== 'active'/res.data.status.toLowerCase() === 'active'/g" "$FILE"

echo "Reemplazo completado."

# Si existen, el script termina silenciosamente (exit 0)
exit 0
