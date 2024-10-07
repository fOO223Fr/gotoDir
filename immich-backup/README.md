# Purpose
Provide an alternative to immich borg backup template with proxmox backup client. `immich.sh` is an alternative to [Borg backup template](https://immich.app/docs/guides/template-backup-script) 

# Pre-requsite
- proxmox virtual environment - pve
- proxmox backup server - pbs
- immich running as docker container inside a LXC container

# How to Use
- Edit the `.env_pbs` and update the value of the environment variables
- Place `immich.sh` and `.env_pbs` in a directory in your pve host. For example: `/opt/scripts/backup/`.
- Place the systemd service file `immich-backup.service` in `/etc/systemd/system/immich-backup.service`.
- Place the systemd timer file `immich-backup.timer` in `/etc/systemd/system/immich-backup.timer`.
- `systemctl daemon-reload`
- `systemctl enable immich-backup.timer`