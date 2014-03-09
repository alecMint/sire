// todo: make sure its in s3 before deleting

var fs = require('fs')
,s3cmd = require('./s3cmd')
,ttl = 60000 // this needs to be large enough for s3 to receive the file or it will get stuck here
,files = {}
,seconds = {}
,counts = {}
,interval,undef
,refetchHandler
;

module.exports = addDeleteTimer;

function addDeleteTimer(localPath, remotePath){
  cleanFile(localPath); // should bump ttl for this file
  var sec = Math.ceil((Date.now()+ttl)/1000);
  (seconds[sec] = seconds[sec] || {})[localPath] = {
    remotePath: remotePath
  };
  counts[sec] = counts[sec] ? counts[sec]+1 : 1;
  files[localPath] = sec;
  if (interval === undef)
    interval = setInterval(delNext,1000);
}


module.exports.onrefetch = function(cb){
  refetchHandler = cb;
}

module.exports.delete = del;

// for testing
module.exports.__setTTL = function(t){
  ttl = t;
}

module.exports.__stat = function(){
  return JSON.stringify({
    files: files
    ,seconds: seconds
    ,counts: counts
  });
}

function del(localPath,cb){
  cb = cb || function(){};
  okToDelete(localPath,function(err,ok){
    if (!ok) {
      // clean up.
      cleanFile(localPath);
      return cb('not deleting. not on s3 yet');
    }
    fs.unlink(localPath,function(err){
      cleanFile(localPath);
      if (err && err.code != 'ENOENT') {
        console.log('s3deleter: fs failed to delete',localPath,err);
        return cb(err);
      }
      console.log('s3deleter: fs delete success',localPath);
      cb();
    });
  });
}

function delNext(){
  var now = Date.now()/1000;
  Object.keys(seconds).forEach(function(sec){
    if (sec > now)
      return;
    Object.keys(seconds[sec]).forEach(function(localPath){
      del(localPath);
    });
  });
}

function cleanFile(localPath){
  var sec = files[localPath]
  if (sec !== undef) {
    delete files[localPath];
    if (seconds[sec])
      delete seconds[sec][localPath];
    if (--counts[sec] == 0) {
      delete seconds[sec];
      delete counts[sec];
    }
  }
  if (interval !== undef && !Object.keys(seconds).length) {
    clearInterval(interval);
    interval = undef;
  }
}

function okToDelete(localPath,cb){
  var sec = files[localPath]
  if (sec === undef)
    return cb(false,true);
  if (!sec.remotePath)
    return cb(false,true);

  fileOftenUsed(localPath,function(err,often){
    if(err) cb(err);
     
    fileExistsOnS3(sec.remotePath,function(err,isOnS3){
      console.log('fileExistsOnS3',err?'has error':'no error',isOnS3?'isOnS3:true':'isOnS3:false');
      if (err)
        return cb(false,false);

      if(often && isOnS3 && refetchHandler) refetchHandler(localPath,sec.remotePath);

      cb(false,!often && isOnS3);
    });
  });
}

function fileOftenUsed(localPath,cb){

  fs.stat(localPath,function(err,stat){
    if(err) return cb(err);

    var now = Date.now();
    var msSinceLastAccess = now-stat.atime.getTime();
    var msSinceLastModify = now-stat.mtime.getTime();
    var msSinceCreate = now-stat.ctime.getTime();
    var often = msSinceLastAccess < ttl || msSinceLastAccess < ttl || msSinceCreate < ttl;

    cb(false,often,now-msSinceCreate);
  });

}

function fileExistsOnS3(remotePath,cb){
  s3cmd(['info',remotePath],function(err,out){
    if (err) {
      if (err.indexOf('no element found') != -1)
        return cb(false,false);
      cb(err);
    }
    cb(false,true);
  });
}

