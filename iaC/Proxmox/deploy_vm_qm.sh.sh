#!/usr/bin/env bash
# Script de création automatique d'une VM sur Proxmox VE avec qm
# Charge ses variables depuis un fichier séparé

# Charger les variables
source ./vm.conf

# Vérification rapide
if qm status "$VMID" &>/dev/null; then
  echo "Erreur : une VM avec l'ID $VMID existe déjà." >&2
  exit 1
fi

# Étape 1 : Création de la VM de base
qm create $VMID \
  --name $VMNAME \
  --memory $RAM \
  --cores $CORES \
  --net0 virtio,bridge=$BRIDGE

# Étape 2 : Ajout d’un disque virtuel
qm set $VMID --scsi0 ${STORAGE}:${DISK_SIZE}

# Étape 3 : Montage de l’ISO d’installation
qm set $VMID --ide2 ${ISO_STORAGE}:iso/${ISO},media=cdrom

# Étape 4 : Définition de l’ordre de boot (ISO puis disque)
qm set $VMID --boot order=ide2;scsi0

# Étape 5 : Démarrage de la VM
qm start $VMID

echo "VM $VMNAME (ID: $VMID) créée et démarrée avec succès."
