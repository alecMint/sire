#!/usr/bin/env node

var sql = require('../sql')
,argv = require('optimist').argv
;

var bucket = argv.b || argv.bucket
,dbName = argv.d || argv.database
;
if (!bucket || !dbName) throw "db and bucket required";

sql.backup(dbName,bucket,function(err){
  if (err)
    return console.log(err);
  console.log(dbName+' backed to '+bucket);
  sql.clean(bucket,dbName,3,function(err,filesDeleted){
    if (err)
      return console.log('error cleaning s3',err);
    console.log('cleaned remote',filesDeleted);
  });
});

