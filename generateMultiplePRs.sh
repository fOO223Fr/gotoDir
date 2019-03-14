echo "Enter bitbucket username:"
read username
echo "Enter bitbucket user password:"
read -s password
echo "Enter bitbucket username of reviewer:"
read reviewer

# Constant variables.
projectName=WRTCPLAT
# Store repository list in a variable.
inputJson=$(curl -u $username:$password -H "Content-Type: application/json" "http://bitbucket.genband.com/rest/api/1.0/projects/$projectName/repos")

# Iterate through the reposition in side $projectName.
echo $inputJson | jq -r '.["values"] | .[].slug' | while read i; do
  repoName=$i;
  generate_post_data() {
  cat <<EOF
{
  "title": "Type your commit message.",
  "description": "Type your commit description.",
  "state": "OPEN",
  "open": true,
  "closed": false,
  "fromRef": {
    "id": "refs/heads/dev-2.2.0",
    "repository": {
      "slug": "$repoName",
      "name": null,
      "project": {
        "key": "$projectName"
      }
    }
  },
  "toRef": {
    "id": "refs/heads/dev-2.3.0",
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
        "name": "$reviewer"
      }
    }
  ]
}
EOF
  }

  # Post request for bitbucket PR.
  curl -u $username:$password -H "Content-Type: application/json" "http://bitbucket.genband.com/rest/api/1.0/projects/$projectName/repos/$repoName/pull-requests" -X POST -d "$(generate_post_data)"
  exit 1;
done
