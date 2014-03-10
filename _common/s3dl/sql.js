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
    var numToDel = numDeled = 0;
    list.forEach(function(file,i){
      if (i < histNum)
        return;
      ++numToDel;
      s3cmd(['del',file.p],function(err){
        if (err) {
          cb(err);
          return cb = function(){};
        }
        console.log('deleted '+file.p);
        if (++numDeled == numToDel)
          cb();
      });
    });
  });
}

function getBakList(bucket,dbName,cb){
  if (bucket[bucket.length-1] != '/')
    bucket = bucket+'/';  
  s3cmd(['ls','s3://'+bucket],function(err,data){
    if (err)
      return cb(err);
    var files = []
    ,re = new RegExp(' (s3://'+bucket+dbName+'\.([0-9]+)\.sql\.gz)$')
    console.log(re);
    data.split('\n').forEach(function(l){
      var m = l.match(re);
      if (m && m[1] && m[2]) {
        files.push({
          t: +m[2]
          ,p: m[1]
        });
      }
    });
    files.sort(function(a,b){
      return b.t-a.t;
    });
    cb(false,files);
  });
}