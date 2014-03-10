var path = require('path')
,cp = require('child_process')
,fs = require('fs')
,s3cmd = require('./s3cmd')
,tmpDir = '/tmp/sire-dbbak/'
;


module.exports.backup = function(dbName,bucket,cb){
  fs.mkdir(tmpDir,function(err){
    if (err && err.code != 'EEXIST')
      return cb(err);
    var fn = dbName+'.'+Date.now()+'.sql.gz'
    ,localPath = tmpDir+fn
    ,remotePath = 's3://'+path.join(bucket,fn)
    ;
    cp.exec('mysqldump --opt -hlocalhost -uroot '+dbName+' | gzip > '+localPath,function(err){
      if (err)
        return cb(err);
      s3cmd(['put',localPath,remotePath],function(err){
        try {
          fs.unlinkSync(localPath);
        } catch (e){
          console.log('failed to clean up local '+localPath,e);
        }
        cb(err);
      });
    });
  });
}

module.exports.clean = function(bucket,dbName,histNum,cb){
  getBakList(bucket,dbName,function(err,list){
    if (err)
      return cb(err);
    cb();
  });
}

function getBakList(bucket,dbName,cb){
  if (bucket[bucket.length-1] != '/')
    bucket = bucket+'/';  
  s3cmd(['ls','s3://'+bucket],function(err,data){
    console.log(err,'\n',data,'\n');
    if (err)
      return cb(err);
    cb(data);
  });
}