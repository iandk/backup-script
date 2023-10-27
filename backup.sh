#!/bin/bash

# --- Configurable Variables ---
DATE=$(date +%Y-%m-%d_%H-%M-%S)
BACKUP_DIR="/backup/${DATE}"
DIRS_TO_BACKUP=("/etc/bird")
FILES_TO_BACKUP=("/etc/network/interfaces" "/etc/sysctl.conf")
ARCHIVE_PATH="/backup/backup_${DATE}.tar.gz"
RCLONE_REMOTE="cloudflare"  # The name of the rclone remote you set up
RCLONE_PATH="backup/"  # The path on R2 where you want the backup stored, usually the name of the bucket
RETAIN_ARCHIVES=7  # Number of archives to retain

# --- Backup Section ---
mkdir -p "${BACKUP_DIR}"

for dir in "${DIRS_TO_BACKUP[@]}"; do
  if [[ -d "${dir}" ]]; then
    cp -r "${dir}" "${BACKUP_DIR}/"
  else
    echo "Warning: Directory ${dir} not found!"
  fi
done

for file in "${FILES_TO_BACKUP[@]}"; do
  if [[ -f "${file}" ]]; then
    cp "${file}" "${BACKUP_DIR}/"
  else
    echo "Warning: File ${file} not found!"
  fi
done

# Archive the backup directory
tar -czf "${ARCHIVE_PATH}" -C "/backup" "${DATE}"

# --- rclone Upload to rclone target ---
rclone copy "${ARCHIVE_PATH}" "${RCLONE_REMOTE}:${RCLONE_PATH}/"


# --- Prune older backups ---
# Fetch a list of existing backups from R2, sort them, and delete ones that exceed the retain count
PRUNED=false

# Store older backup files to be pruned in an array
OLD_BACKUPS=($(rclone ls "${RCLONE_REMOTE}:${RCLONE_PATH}/" | sort -r | awk 'NR>'${RETAIN_ARCHIVES}' {print $2}'))

# If there are any files in the OLD_BACKUPS array, set PRUNED to true and delete each file
if [ ${#OLD_BACKUPS[@]} -gt 0 ]; then
  PRUNED=true
  for backup in "${OLD_BACKUPS[@]}"; do
    rclone delete "${RCLONE_REMOTE}:${RCLONE_PATH}/${backup}"
  done
fi

echo "Backup completed and uploaded to ${RCLONE_REMOTE}."
if [[ "$PRUNED" == "true" ]]; then
  echo "Older backups pruned."
fi
