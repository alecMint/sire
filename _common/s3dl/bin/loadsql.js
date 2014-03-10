#!/usr/bin/env node

var sql = require('../sql')
,argv = require('optimist').argv
;

var bucket = argv.b || argv.bucket
,dbName = argv.d || argv.database
;
if (!bucket || !dbName) throw "db and bucket required";

sql.load(bucket,dbName,function(err){
  if (err)
    return console.log('ERROR',err);
  console.log('SUCCESS');
});
