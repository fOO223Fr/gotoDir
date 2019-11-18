<<<<<<< HEAD
echo "Type the Microservice directory to watch and rsync, followed by [Enter]"
read directory
echo "Searching for $directory anywhere inside $HOME/repos"
directory_path=$(find $HOME/repos -maxdepth 1 -name $directory -type d -print)
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
=======
#!/bin/bash

# Checking if stdin is set for directory, $1
if [ -z "$1" ]
then
	echo "Type the Microservice directory to watch and rsync, followed by [Enter]"
	read directory
else
	directory=$1
fi

echo "Searching for $directory anywhere inside $HOME/repos"
directory_path=$(find -L $HOME/repos -maxdepth 1 -name $directory -type d -print)

# Checking if the directory could be found
if [ $? != 0 ]
then
	echo "Directory not found!"
	exit 1
else
	echo "Found path for $directory which is: $directory_path"
	echo "Press [Enter] to continue else [CTRL]+Z"
	read
fi

# Checking if stdin is set for lap_ip, $2
if [ -z "$2" ]
then
	echo "IP of lab to sync, followed by [Enter]"
	read lab_ip
else
	lab_ip=$2
fi

echo "Exchanging ssh keys, enter lab password for the first time"
ssh-copy-id -i ~/.ssh/id_rsa.pub sysadm@$lab_ip
echo "Copied to /home/sysadm/$directory/ in remote machine"

while inotifywait -r -e modify,create,delete $directory_path; do
    rsync -avz -e ssh $directory_path sysadm@$lab_ip:/home/sysadm/$directory/
done
>>>>>>> d9d253c7a7af7a836c0519478e90083155a41088
