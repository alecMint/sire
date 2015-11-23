
sig=`echo "$1" | sed -n 's/[^a-zA-Z0-9_-]/_/gp'`
lockFile="/tmp/gitsync.$sig.lock"
if [ -f "$lockFile" ]; then
	echo "lock file found, exiting"
	exit
fi
date >> "$lockFile"


dir=$1
branch=$2

cd "$dir" || (echo "dir $dir does not exist, exiting" && exit 1)
git fetch
git reset --hard HEAD
#git checkout -f origin/$branch # is there a reason i had origin/...?
git checkout -f $branch
git pull origin $branch
git submodule update

if [ -f ./package.json ]; then
	npm install --production # --production to avoid installing devDependencies
fi

if [ -f ./post-gitsync.sh ]; then
	./post-gitsync.sh "$dir" "$branch"
fi


rm "$lockFile"
