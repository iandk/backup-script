#!/bin/bash

# --- Configurable Variables ---
DATE=$(date +%Y-%m-%d_%H-%M-%S)
BACKUP_DIR="/backup/${DATE}"
DIRS_TO_BACKUP=("/etc/bird")
FILES_TO_BACKUP=("/etc/network/interfaces" "/etc/sysctl.conf")
ARCHIVE_PATH="/backup/backup_${DATE}.tar.gz"
RCLONE_REMOTE="cloudflare"  # The name of the rclone remote you set up
RCLONE_PATH="backup/"  # The path on R2 where you want the backup stored, usually the name of the bucket
RETAIN_DAYS=7  # Number of days to retain backups


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

# Check if the file was successfully uploaded
if rclone lsf "${RCLONE_REMOTE}:${RCLONE_PATH}/" | grep -q "$(basename "${ARCHIVE_PATH}")"; then
    echo "Backup successfully uploaded."

    # Cleanup: Delete local backup files and directory
    rm -f "${ARCHIVE_PATH}"
    rm -rf "${BACKUP_DIR}"
    echo "Local backup files and directory removed."
else
    echo "Error: Backup upload failed."
    exit 1
fi

# --- Prune older backups using rclone ---
rclone delete "${RCLONE_REMOTE}:${RCLONE_PATH}/" --min-age "${RETAIN_DAYS}d"

echo "Backup completed and uploaded to ${RCLONE_REMOTE}. Older backups older than ${RETAIN_DAYS} days pruned."
