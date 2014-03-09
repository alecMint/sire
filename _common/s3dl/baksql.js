var path = require('path')
,cp = require('child_process')
,fs = require('fs')
,s3cmd = require('./s3cmd')
,tmpDir = '/tmp/sire-dbbak/'
;

var bucket = argv.b || argv.bucket
,dbName = argv.d || argv.database
;

if (!bucket || !dbName) throw "db and bucket required";

fs.mkdir(tmpDir,function(err){
  if (err) {
    return console.log(err,err.code);
  }
  var fn = dbName+'.'+Date.now()+'.sql.gz'
  ,path = tmpDir+fn;
  cp.exec('mysqldump --opt -hlocalhost -uroot '+dbName+' | gzip > '+path,function(err){
    if (err) {
      return console.log(err);
    }
  });
});

