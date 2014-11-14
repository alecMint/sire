
#echo `date` >> /root/fabcompute_onstartup
export FABCOMPUTE_REBOOT=1
/root/sire/index.sh fabcompute
unset FABCOMPUTE_REBOOT
