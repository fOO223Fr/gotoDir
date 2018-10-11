echo "Type the Microservice directory to watch and rsync, followed by [Enter]"
read directory
echo "Searching for $directory anywhere inside $HOME"
directory_path=$(find ~/ -name $directory -type d -print)
echo "Found path for $directory which is: $directory_path"
echo "Enter the Namespace were to sync, example: 'platform' or 'security' or etc"
read namespace
echo "Enter role name"
read role_name
while inotifywait -r -e modify,create,delete $directory_path; do
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
