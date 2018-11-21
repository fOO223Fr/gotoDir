echo "Type the directory to watch and rsync in Home directory"
read directory
directory_path=$(find ~/ -name $directory -type d -print)
echo "$directory_path"
while inotifywait -r -e modify,create,delete $directory_path; do
    rsync -avu --delete $directory_path/src/main/deployment/ansible/setup-generic-nginx-ms/tasks/ /etc/ansible_guest/roles/setup-generic-nginx-ms/tasks/
    # For playbook file
    rsync -vu $directory_path/src/main/deployment/ansible/ /etc/ansible_guest/
    # For tasks folder
    rsync -avu --delete $directory_path/src/main/deployment/ansible/$role_name/tasks/ /etc/ansible_guest/roles/$namespace/$role_name/tasks/
    # For config.yml file 
    rsync -vu $directory_path/src/main/deployment/ansible/config.yml /etc/ansible_guest/roles/$namespace/$role_name/files/config.yml
    # For docker folder
    rsync -avu --delete $directory_path/src/main/deployment/docker/ /etc/ansible_guest/roles/$namespace/$role_name/files/docker/
    # For Kubernetes folder
    rsync -avu --delete $directory_path/src/main/deployment/kubernetes/ /etc/ansible_guest/roles/$namespace/$role_name/templates/kubernetes/
done
