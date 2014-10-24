#!/bin/bash

log=/vagrant/.bootstrap/phedex.log
echo Installing PhEDEx site agents. This can take 5-10 minutes
sudo -i -u vagrant /vagrant/install-phedex-el5.sh 2>&1 | tee $log >/dev/null
chown vagrant.vagrant $log
