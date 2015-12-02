# Pull configs down from waglabs/chef-deploy
#
#


git clone git@github.com:waglabs/chef-deploy.git /tmp/chef-deploy


# @todo: pick based on $CHEF_ENV instead of hardcoding DEV
if [ -f /tmp/chef-deploy/wagapi/files/DEV.config.local.sh ]; then
	cp -f /tmp/chef-deploy/wagapi/files/DEV.config.local.sh "$installDir/config.local.sh"
fi
if [ -f /tmp/chef-deploy/wagapi/files/DEV.config.local.json ]; then
	cp -f /tmp/chef-deploy/wagapi/files/DEV.config.local.json "$installDir/config.local.json"
fi


