/*
node /opt/node-automation/happiness/s3dl/test/s3cmd.js 10
*/

var s3cmd = require('../s3cmd')
,num = 30
,n = 0

for (var i=0;i<num;++i) {
  s3cmd(['ls','s3://bm-marketing-web/webwrite'],function(err,out){
    if (++n == num)
      console.log('received all responses');
  });
}
