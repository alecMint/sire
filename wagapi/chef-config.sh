# Pull configs down from waglabs/chef-deploy
#
#


git clone git@github.com:waglabs/chef-deploy.git /tmp/chef-deploy


# @todo: pick based on $CHEF_ENV instead of hardcoding DEV
if [ -f /tmp/chef-deploy/wagapi/files/DEV.config.local.php ]; then
	cp -f /tmp/chef-deploy/wagapi/files/DEV.config.local.php "$installDir/config.local.php"
fi
if [ -f /tmp/chef-deploy/wagapi/files/DEV.config.local.sh ]; then
	cp -f /tmp/chef-deploy/wagapi/files/DEV.config.local.sh "$installDir/config.local.sh"
fi
if [ -f /tmp/chef-deploy/wagapi/files/DEV.config.local.json ]; then
	cp -f /tmp/chef-deploy/wagapi/files/DEV.config.local.json "$installDir/config.local.json"
fi


if [ -f /tmp/chef-deploy/tools/files/DEV.bashrc ]; then
	bashrc=/root/.bashrc
	tmp=`mktemp -t pushbash.deploy.XXXXXX`
	lineNum=`cat $bashrc 2>/dev/null | grep -n '# wag stuff' | head -n1 | sed 's/\([0-9]*\).*/\1/g'`
	if [ "$lineNum" ]; then
		head -n$((lineNum-2)) $bashrc > "$tmp"
	else
		cat $bashrc > "$tmp"
		echo $'\n\n' >> "$tmp"
	fi
	cp -n $bashrc $bashrc.pushbash.deploy.bak && \
	cp -n $bashrc /tmp/pushbash.deploy.$(date +%Y%m%d_%H%M%S).bak && \
	cat /tmp/chef-deploy/tools/files/DEV.bashrc >> "$tmp" && \
	mv -f "$tmp" $bashrc && \
	chmod 0644 $bashrc
fi

