
dir=$1
branch=$2

cd $dir
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
