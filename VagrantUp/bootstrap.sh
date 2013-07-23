#!/bin/sh

bootstrap=/vagrant
if [ ! -d $bootstrap ]; then
  echo "Cannot find bootstrap directory '$bootstrap'"
  exit 0
fi

cd $bootstrap
bootstrap_log=$bootstrap/.bootstrap
[ -d $bootstrap_log ] || mkdir $bootstrap_log

sysstrap=$bootstrap_log/system
if [ ! -f $sysstrap ]; then
  $bootstrap/install-system.sh && touch $sysstrap
fi

phedexstrap=$bootstrap_log/phedex
if [ ! -f $phedexstrap ]; then
  $bootstrap/install-phedex-boot.sh && touch $phedexstrap
fi

echo "All done!"
