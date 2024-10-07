#!/bin/sh

# Source the PBS token secret
. /opt/scripts/backup/.env_pbs

# Paths
# UPLOAD_LOCATION is sourced from .env_pbs
DATABASE_BACKUP_DIR="$UPLOAD_LOCATION/database-backup"

# Backup Immich database
echo "Backing up Immich database..."
echo "immich lxc container ID: $IMMICH_LXC_CT_ID"
pct exec "$IMMICH_LXC_CT_ID" -- docker exec -t immich_postgres pg_dumpall --clean --if-exists --username=postgres > "$DATABASE_BACKUP_DIR/immich-database.sql"

# Optional: If you want compression, uncomment the following and comment out the previous line
# pct exec "IMMICH_LXC_CT_ID" -- docker exec -t immich_postgres pg_dumpall --clean --if-exists --username=postgres | /usr/bin/gzip --rsyncable > "$DATABASE_BACKUP_DIR/immich-database.sql.gz"

# check if the DB backup was successful
if [ $? -eq 0 ]; then
    echo "Database backup complete."
else
  echo "Database backup failed!" >&2
  exit 1
fi

# Backup Immich data (excluding unnecessary directories)
echo "Starting Proxmox Backup Client for Immich data..."
proxmox-backup-client backup immich.pxar:"$UPLOAD_LOCATION" \
  --exclude "$UPLOAD_LOCATION/thumbs" \
  --exclude "$UPLOAD_LOCATION/encoded-video" \
  --repository "$PBS_REPOSITORY"

# check if the backup was successful
if [ $? -eq 0 ]; then
  echo "Backup completed successfully."
else
  echo "Backup failed!" >&2
  exit 1
fi