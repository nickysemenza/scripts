s3url="s3://nickysemenza-backups/laptop/"
cd `dirname $0`
mkdir -p output && cd output

cmds=("mas list" "brew cask list" "brew list" "npm -g ls --depth=0" "gem list" "pip list" "pip3 list")
for i in "${cmds[@]}"
do
	dest="${i// /_}.txt" #replace spaces with underscore, .txt
	$i > $dest && echo "saved $i to $dest"
done

python ../macos_app_audit.py > macos_app_audit.txt

cp -r /usr/local/etc/ usr_local_etc && echo "copied homebrew /usr/local/etc"

#secure dotfiles
mkdir -p secure_dotfiles
dotfiles=(".aws" ".ngrok2" ".ssh" ".config")
for i in "${dotfiles[@]}"
do
	cp -r ~/$i secure_dotfiles/$i && echo "copied ~/$i"
done

# MYSQL
mkdir -p dbdumps/mysql && cd dbdumps/mysql/
mysql --host=localhost -uroot -proot -e 'show databases' | while read dbname; do mysqldump -uroot -proot --complete-insert "$dbname" > "$dbname".sql; done
echo "dumped brew mysql db"

# MONGO
cd .. && mkdir -p mongo
mongodump --out mongo/ && echo "saved mongodb"

# pack
cd ../.. #back up to root dir
now=$(date +%Y-%m-%d.%H:%M:%S)
archivename="backup_$now.tar.gz"
tar czvf ${archivename} output/
# rm -rf output/
# ship off to S3 bucket (using: brew info awscli)
echo "uploading to S3"
# aws s3 cp $archivename $s3url
rm $archivename
echo "Done. Shipped $archivename to $s3url"