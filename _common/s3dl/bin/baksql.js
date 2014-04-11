#!/usr/bin/env node

var sql = require('../sql')
,argv = require('optimist').argv
;

var bucket = argv.b || argv.bucket
,dbName = argv.d || argv.database
,numBaks = +(argv.n || argv.numbaks || 30)
;
if (!bucket || !dbName) throw 'db and bucket required';
if (isNaN(numBaks)) throw 'num baks should be an integer';

sql.backup(dbName,bucket,function(err){
  if (err)
    return console.log(err);
  console.log(dbName+' backed to '+bucket);
  sql.clean(bucket,dbName,numBaks,function(err,filesDeleted){
    if (err)
      return console.log('error cleaning s3',err);
    console.log('cleaned remote',filesDeleted);
  });
});

