
startpwd=`pwd`

. ../secrets

# modules
#../_common/nginx.sh
#../_common/php.sh
../_common/mysql.sh
../_common/nodejs.sh
../_common/forever.sh


# reboot hook
sed -i '/exit 0/d' /etc/rc.local
gen_add_line_to_file '/etc/rc.local' "$sireDir/fabcompute/onstartup.sh"
gen_add_line_to_file '/etc/rc.local' 'exit 0'
#crontab_add 'FABCOMPUTE_REBOOT' '@reboot export FABCOMPUTE_REBOOT=1; /root/sire/index.sh fabcompute; unset FABCOMPUTE_REBOOT'


# repo
install_repo "$installDir" "$gitRepo"

# give ubuntu access to uploads directory
chown ubuntu $installDir/uploads
forever_run ./server.js


# deploy hook service
configure_hooky "$installDir" master $githubHookAuthToken


# crons
chmod 0744 $installDir/crons/*
crontab_add "$installDir/crons/cleanup.sh" "0 3 * * * $installDir/crons/cleanup.sh '$installDir'"


# BEGIN set file open limit
gen_add_line_to_file '/root/.profile' 'ulimit -Sn' 'ulimit -Sn 4096' '0644'
gen_add_line_to_file '/etc/security/limits.conf' 'root soft nofile' 'root soft nofile 4096'
#gen_add_line_to_file '/etc/security/limits.conf' '* soft nofile' '* soft nofile 4096'
#gen_add_line_to_file '/etc/sysctl.conf' 'fs.file-max' 'fs.file-max = 4096'
sessionFiles=/etc/pam.d/common-session*
for f in $sessionFiles; do
	gen_add_line_to_file "$f" 'session required pam_limits.so'
done
# reboot...
echo "FABCOMPUTE_REBOOT == $FABCOMPUTE_REBOOT"
if [ "$FABCOMPUTE_REBOOT" == "" ]; then
	sudo reboot
fi
# END set file open limit

