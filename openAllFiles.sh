echo "Type the root directory name, followed by [Enter]:"
read dirName

echo "Type the directory names/paths to ignore within $dirName (seperate with spaces), followed by [Enter]:"
read subDirNames

decoratedSubDirNames=$(echo $subDirNames | sed "s/[^ ]* */-path $dirName\/&-o /g" | sed 's/...$//')
# echo $decoratedSubDirNames
find $dirName -type d \( $decoratedSubDirNames \) -prune -o -type f -follow -print |xargs rmate

echo "All files opened in rmate"