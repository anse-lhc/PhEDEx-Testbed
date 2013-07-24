#!/bin/bash

if [ -z $TESTBED_ROOT ]; then
  echo "TESTBED_ROOT not set, are you sure you sourced the environment?"
  exit 0
fi
gitsrc=git@github.com:TonyWildish

. $TESTBED_ROOT/env-anse.sh

#echo "Install development path for LifeCycle agent"
#cd $TESTBED_ROOT/sw/$SCRAM_ARCH/cms/PHEDEX-lifecycle/*
#rpm_installed=`pwd`
#cd ..
#git clone -b PHEDEX-lifecycle $gitsrc/PHEDEX.git LifeCycle-git
#cd $rpm_installed
#mkdir rpm_orig
#for dir in Testbed Utilities perl_lib
#do
#  mv $dir rpm_orig/
#  ln -s ../LifeCycle-git/$dir $dir
#done
#
#cd bin
#mkdir rpm_orig
#for file in *
#do
#  mv $file rpm_orig/
#  ln -s `find ../../LifeCycle-git/ -name $file` .
#done

echo "Install development path for PhEDEx agents"
cd $TESTBED_ROOT/sw/$SCRAM_ARCH/cms/PHEDEX-admin/*
rpm_installed=`pwd`
cd ..
git clone $gitsrc/PHEDEX.git PhEDEx-git
cd $rpm_installed
mkdir rpm_orig
for dir in `ls | egrep -v 'rpm_orig|etc'`
do
  mv $dir rpm_orig/
  ln -s ../PhEDEx-git/$dir $dir
done
