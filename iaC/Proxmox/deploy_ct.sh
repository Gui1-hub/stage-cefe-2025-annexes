#!/usr/bin/env bash
# create_ct_simple.sh — Création simple d’un conteneur LXC sur Proxmox VE

# Variables de configuration
CTID=210
HOSTNAME="ct-ubuntu"
TEMPLATE="ubuntu-24.04-standard_24.04-1_amd64.tar.zst"   # déjà téléchargé
ROOTFS_STORAGE="local-lvm"
DISK_SIZE="8G"
CORES=2
MEMORY=1024
SWAP=512
BRIDGE="vmbr0"
IPCONF="dhcp"             # ou "192.168.10.20/24,gw=192.168.10.1"
OSTYPE="ubuntu"

# Vérification du template
TEMPLATE_PATH="/var/lib/vz/template/cache/${TEMPLATE}"
if [[ ! -f "$TEMPLATE_PATH" ]]; then
  echo "Template introuvable : $TEMPLATE_PATH"
  exit 1
fi

# Vérification que l'ID n'existe pas déjà
if pct status "$CTID" &>/dev/null; then
  echo "Un conteneur avec l'ID $CTID existe déjà."
  exit 1
fi

# Création du conteneur
pct create "$CTID" "$TEMPLATE_PATH" \
  --hostname "$HOSTNAME" \
  --storage "$ROOTFS_STORAGE" \
  --rootfs "${ROOTFS_STORAGE}:${DISK_SIZE}" \
  --cores "$CORES" \
  --memory "$MEMORY" \
  --swap "$SWAP" \
  --net0 "name=eth0,bridge=${BRIDGE},ip=${IPCONF}" \
  --ostype "$OSTYPE" \
  --unprivileged 1 \
  --onboot 1

# Démarrage
pct start "$CTID"

echo "Conteneur #$CTID ($HOSTNAME) créé et démarré."