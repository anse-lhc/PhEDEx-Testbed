#!/bin/bash

git pull

rm /vagrant/.bootstrap/phedex*

/vagrant/install-phedex.sh
