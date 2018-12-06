echo -n "Enter Password for bitbucket:"
read -s password
while read repo; do
    pwd
    cd /root/repos
    if [ ! -z "$repo" ]
    then
        echo $repo
        git clone $repo

        # The below code can be used when input of repo links is not from a file instead it is from command line.
        #repoName=$(echo $1 | perl -ne '/\/(?!.*\/)(.*)\./ && print "$1\n"')
        projectName=$(echo $repo |  perl -ne '/:7999\/(.+)\/(.+)\./ && print "$1"')
        repoName=$(echo $repo |  perl -ne '/:7999\/(.+)\/(.+)\./ && print "$2"')
        
        cd $repoName
        
        # Assumtion the checkout branches are in remote or in local branch list.
        if [[ $repoName == cpaas* ]];
        then
            if [[ $repoName == "cpaas_wrapper_bridge" ]];
            then
                git checkout rpm-packing
            else
                git checkout integration
            fi
        else
            git checkout develop
        fi
        
        # Creating dev-2.2.0 branch
        git branch -a | grep dev-2.2.0
        branchPresentOrNot=$?
        if [ $branchPresentOrNot -ne 0 ]; then
            git checkout -b dev-2.2.0
        else
            git checkout dev-2.2.0
        fi
        git push origin dev-2.2.0
        
        # Create patch branch
        git branch -a | grep patch/AEB-3180
        branchPresentOrNot=$?
        if [ $branchPresentOrNot -ne 0 ]; then
            git checkout -b patch/AEB-3180
        else
            git checkout patch/AEB-3180
        fi
        
        # Finds the tasks dir which contains install.yml.
        # Assumtion there is only one install.yml file in the repository.
        dirPathOfTasks=$(find . -name install.yml -printf '%h\n')
        echo $dirPathOfTasks
        cd $dirPathOfTasks
        
        # It is expected that filePathOfInstall will contain "./install.yml".
        filePathOfInstall=$(find . -type f -name install.yml -print)
        echo $filePathOfInstall
        sed -i 's/kubectl create -f {{ item }}/kubectl create -f {{ item }} --save-config/g' $filePathOfInstall

        # The bellow command allows you to see the differences also gives you some control over this script as it waits for key "q" to be pressed before the while loop is continued. if you dont want to control then comment the below line.
        git diff

        git add $filePathOfInstall
        git status
        git commit -m "kubectl create command updated. AEB-3180"
        git push origin patch/AEB-3180

        # the reviewer in the request should be changed accordingly.
        generate_post_data()
        {
cat <<EOF
{
  "title": "kubectl create command updated",
  "description": "Jira: AEB-3180",
  "state": "OPEN",
  "open": true,
  "closed": false,
  "fromRef": {
    "id": "refs/heads/patch/AEB-3180",
    "repository": {
      "slug": "$repoName",
      "name": null,
      "project": {
        "key": "$projectName"
      }
    }
  },
  "toRef": {
    "id": "refs/heads/dev-2.2.0",
    "repository": {
      "slug": "$repoName",
      "name": null,
      "project": {
        "key": "$projectName"
      }
    }
  },
  "reviewers": [
    {
      "user": {
        "name": "albloor"
      }
    }
  ]
}
EOF
        }

        # Post request for bitbucket PR.
        curl -u skghosh:$password -H "Content-Type: application/json" "http://bitbucket.genband.com/rest/api/1.0/projects/$projectName/repos/$repoName/pull-requests" -X POST -d "$(generate_post_data)"
    fi

done <gitLinks.txt
