cd `dirname $0`
mkdir -p output
cd output

ls /Applications > applications_all.txt && echo "saved a list of installed Applications"
mas list > applications_mas.txt && echo "saved a list of installed app store applications"
brew cask list > applications_homebrewcask.txt && echo "saved a list of installed homebrew cask applications"
brew list > homebrew_packages.txt && echo "saved a list of installed homebrew packages"
npm -g ls --depth=0 > npm_global_packages.txt && echo "saved a list of installed global npm packages"
gem list > gem_global_packages.txt && echo "saved a list of installed global rubygem packages"
pip list > python2_packages.txt && echo "saved a list of installed global python2 packages"
pip3 list > python3_packages.txt && echo "saved a list of installed global python3 packages"

cp -r /usr/local/etc/ brew_etc && echo "copied homebrew /usr/local/etc"
mkdir -p privateconfig
cd privateconfig
cp -r ~/.aws .aws && echo "copied ~/.aws"
cp -r ~/.ngrok2 .ngrok2 && echo "copied ~/.ngrok2"
cp -r ~/.ssh .ssh && echo "copied ~/.ssh"
cp -r ~/.config .config && echo "copied ~/.config"
cd ..

mkdir -p dbdumps/mysql
mkdir -p dbdumps/redis
mkdir -p dbdumps/mongo
cd dbdumps/mysql/
mysql --host=localhost -uroot -proot -e 'show databases' | while read dbname; do mysqldump -uroot -proot --complete-insert "$dbname" > "$dbname".sql; done
echo "dumped brew mysql db"
cd ../redis #to /dbdumps/redis
redis-dump > redis_db0.txt && echo "saved redis db0"
cd .. #back up to /dbdumps
mongodump --out mongo/ && echo "saved mongodb"
cd ../.. #back up to root dir
now=$(date +%Y-%m-%d.%H:%M:%S)
archivename="backup_$now.tar.gz"

tar czvf ${archivename} output/
rm -rf output/
# ship off to S3 bucket (using: brew info awscli)
echo "uploading to S3"
aws s3 cp $archivename s3://nickysemenza-backups/laptop/
rm $archivename
echo "DONE"