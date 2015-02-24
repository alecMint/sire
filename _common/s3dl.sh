#!/bin/bash

s3dlinstall_pwd=`pwd`
mkdir -p $sireDir/_common/s3dl/node_modules
cd $sireDir/_common/s3dl
npm install
cd "$s3dlinstall_pwd"
