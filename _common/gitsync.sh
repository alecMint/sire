
sig=`echo "$@" | sed -n 's/[^a-zA-Z0-9_-]/_/gp'`
lockFile="/tmp/gitsync.$sig.lock"
if [ -f "$lockFile" ]; then
	echo "lock file found, exiting"
	exit
fi
date >> "$lockFile"


dir=$1
branch=$2

cd $dir || (echo "dir $dir does not exist, exiting" && exit 1)
git fetch
git reset --hard HEAD
git checkout -f origin/$branch
git pull origin $branch
git submodule update

if [ -f "$dir/package.json" ]; then
	npm install
fi

if [ -f "$dir/post-gitsync.sh" ]; then
	$dir/post-gitsync.sh "$dir" "$branch"
fi


rm "$lockFile"
