# nginx conf

if [ ! -d /mnt/logs ]; then
  mkdir /mnt/logs
fi


crontab_add 'cleanup.sh' '0 4 * * * sh /var/www/m1.jewelmint.com/crons/cleanup.sh'

if [ "$isCronServer" == "1" ]; then
  crontab_add 'updateProductsByStoreId.sh 1' '0 * * * * sh /var/www/m1.jewelmint.com/crons/updateProductsByStoreId.sh 1'
  crontab_add 'updateProductsByStoreId.sh 2' '0 * * * * sh /var/www/m1.jewelmint.com/crons/updateProductsByStoreId.sh 2'
  crontab_add 'updateProductsByStoreId.sh 4' '0 * * * * sh /var/www/m1.jewelmint.com/crons/updateProductsByStoreId.sh 4'
  crontab_add 'updateProductsByStoreId.sh 6' '0 * * * * sh /var/www/m1.jewelmint.com/crons/updateProductsByStoreId.sh 6'
  crontab_add 'prod_acq_dump.sh' '58 1 * * * sh /var/www/m1.jewelmint.com/crons/prod_acq_dump.sh prod-west-marketing-read.cnb7tr6b9nct.us-west-1.rds.amazonaws.com root marketinG78'
  crontab_add 'optimal_daily.sh' '15 4 * * * sh /var/www/m1.jewelmint.com/crons/optimal_daily.sh'
  crontab_add 'ssdaily.sh' '0 3 * * * sh /var/www/m1.jewelmint.com/crons/ssdaily.sh'
  crontab_add 'sshourly.sh' '0 * * * * sh /var/www/m1.jewelmint.com/crons/sshourly.sh'
  crontab_add 'ssquarterhourly.sh' '*/15 * * * * sh /var/www/m1.jewelmint.com/crons/ssquarterhourly.sh'
  crontab_add 'ssminutely.sh' '*/1 * * * * sh /var/www/m1.jewelmint.com/crons/ssminutely.sh'
  crontab_add 'ssweekly.sh' '5 3 * * 7 sh /var/www/m1.jewelmint.com/crons/ssweekly.sh'
  crontab_add 'dailyproductfeed.sh' '0 2 * * * sh /var/www/m1.jewelmint.com/crons/dailyproductfeed.sh'
  crontab_add 'fbprofilesync1.sh' '5 4 * * * sh /var/www/m1.jewelmint.com/crons/fbprofilesync1.sh'
  crontab_add 'fbprofilesync2.sh' '30 4 * * * sh /var/www/m1.jewelmint.com/crons/fbprofilesync2.sh'
  crontab_add 'fbsyncpromos.sh' '0 5 * * * sh /var/www/m1.jewelmint.com/crons/fbsyncpromos.sh'
  crontab_add 'optimal_update_next_cust_aud.sh' '*/60 * * * * sh /var/www/m1.jewelmint.com/crons/optimal_update_next_cust_aud.sh'
  crontab_add 'emailscraper.sh' '*/58 * * * * sh /var/www/m1.jewelmint.com/crons/emailscraper.sh'
  crontab_add 'adwords.sh' '15 12 * * * sh /var/www/m1.jewelmint.com/crons/adwords.sh'
  crontab_add 'updatecost.sh' '30 13 * * * sh /var/www/m1.jewelmint.com/crons/updatecost.sh'
fi
