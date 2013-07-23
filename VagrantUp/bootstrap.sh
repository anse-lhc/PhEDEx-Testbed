#!/bin/sh

echo "Hello World!"

bootstrap=/vagrant/.bootstrap
[ -d $bootstrap ] || mkdir $bootstrap

sysstrap=$bootstrap/system
if [ ! -f $sysstrap ]; then
  /vagrant/install-system.sh && touch $sysstrap
fi

phedexstrap=$bootstrap/phedex
if [ ! -f $phedexstrap ]; then
  /vagrant/install-phedex-boot.sh && touch $phedexstrap
fi

echo "All done!"
