/*
node /opt/node-automation/happiness/s3dl/test/s3deleter.js 10 10000 1
s3cmd --recursive del s3://bm-marketing-web/webwrite/test
rm -R /var/www/m1.jewelmint.com/webwrite/test

s3cmd ls s3://bm-marketing-web/webwrite/
s3cmd ls s3://bm-marketing-web/webwrite/test/
ls /var/www/m1.jewelmint.com/webwrite/test
*/

var fs = require('fs')
,path = require('path')
,s3cmd = require('../s3cmd')
,watchedLocalDir = '/var/www/m1.jewelmint.com/webwrite/'
,watchedS3Dir = 'webwrite/'
,testDir = 'test/'
,bucket = 'bm-marketing-web'
,numFiles = process.argv[2] ? +process.argv[2] : 50
,waitForS3Sync = process.argv[3] ? +process.argv[3] : 10000
,dontCleanS3 = !!process.argv[4]
;


makeLocalDir(path.join(watchedLocalDir,testDir),function(err){
  var n = 0
  ,files = []
  ,interval = setInterval(function(){
    var fn = path.join(watchedLocalDir,testDir,Date.now()+'');
    fs.writeFile(fn,'abc',function(err){
      if (err) {
        console.log('error writing to '+fn);
      } else {
        console.log('created file: '+fn);
        files.push(fn);
      }
      if (++n == numFiles) {
        clearInterval(interval);
        console.log('waiting '+waitForS3Sync+' before checking s3...');
        setTimeout(function(){
          s3cmd(['ls','s3://'+path.join(bucket,watchedS3Dir,testDir)],function(err,out){
            console.log('ls s3 dir, err:'+err,out?'\n'+out:'');
            if (!dontCleanS3) {
              console.log('cleaning s3 test dir...');
              cleanUpS3(files);
            }
          });
        },waitForS3Sync);
      }
    });
  },400);
});

function makeLocalDir(dir,cb){
  fs.mkdir(dir,function(err){
    if (err && err.code != 'EEXIST')
      return cb(err);
    cb();
  });
}

function cleanUpS3(files,cb){
  cb = cb || function(){};
  var n = 0;
  files.forEach(function(fn){
    var s3fn = 's3://'+path.join(bucket,watchedS3Dir,testDir,path.basename(fn));
    s3cmd(['del',s3fn],function(err,out){
      console.log('cleanUpS3',s3fn,err,out);
      if (++n == files.length)
        cb();
    });
    //console.log('cleanUpS3',s3fn,fn);
  });
}






/* test outside of watched folder...
var dir = __dirname+'/files/'
,deleter = require('../s3deleter')
;

deleter.__setTTL(10000);

fs.mkdir(dir,function(err){
  if (err && err.code != 'EEXIST')
    return console.log(err);
  var n = 0
  ,interval = setInterval(function(){
    makeFile(function(err,fn){
      // test someone else deletes file...
      if (!Math.round(Math.random()*3)) {
        console.log('DELETING A FILE JUST CUZ\n');
        fs.unlink(fn);
      }
    });
    if (++n == numFiles)
      clearInterval(interval);
    console.log(deleter.__stat()+'\n');
  },400);
});

function makeFile(cb){
  var fn = dir+Date.now();
  fs.writeFile(fn,'',function(err){
    if (err) {
      console.log('error writing to '+fn);
      return cb(err,fn);
    }
    deleter(fn);
    cb(false,fn);
  });
}
*/