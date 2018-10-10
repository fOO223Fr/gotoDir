echo "Type the directory to watch and rsync in Home directory"
read directory
directory_path=$(find ~/ -name $directory -type d -print)
echo "$directory_path"
while inotifywait -r -e modify,create,delete $directory_path; do
    rsync -avu --delete $directory_path/src/main/deployment/ansible/setup-generic-nginx-ms/tasks/ /etc/ansible_guest/roles/setup-generic-nginx-ms/tasks/
done
