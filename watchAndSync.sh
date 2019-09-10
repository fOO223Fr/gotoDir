echo "Type the Microservice directory to watch and rsync, followed by [Enter]"
read directory
echo "Searching for $directory anywhere inside $HOME/repos"
directory_path=$(find -L $HOME/repos -maxdepth 1 -name $directory -type d -print)
echo "Found path for $directory which is: $directory_path"
echo "Press [Enter] to continue else [CTRL]+Z"
read
echo "IP of lab to sync, followed by [Enter]"
read labIp
echo "Exchanging ssh keys, enter lab password for the first time"
ssh-copy-id -i ~/.ssh/id_rsa.pub sysadm@$labIp
echo "Copied to /home/sysadm/$directory/ in remote machine"

while inotifywait -r -e modify,create,delete $directory_path; do
    rsync -avz -e ssh $directory_path sysadm@$labIp:/home/sysadm/$directory/
done
