#!/bin/sh

# You need to change this in order to match where you want your folder to be
export TESTBED_ROOT=$HOME/TESTBED_ROOT
# export TESTBED_ROOT=/data/TESTBED_ROOT
if [ ! -d "$TESTBED_ROOT" ]; then
  echo "TESTBED_ROOT not a directory. Creating it..."
  mkdir $TESTBED_ROOT
fi
cd $TESTBED_ROOT
if [ `pwd` != $TESTBED_ROOT ]; then
  echo "Cannot cd to $TESTBED_ROOT"
  exit 0
fi

if [ ! -d ANSE-PhEDEx-Testbed ]; then
  git clone https://github.com/anse-lhc/PhEDEx-Testbed.git ANSE-PhEDEx-Testbed
fi

ENVIRONMENT=$TESTBED_ROOT/env-anse.sh
export SCRAM_ARCH=slc6_amd64_gcc461
export repo=comp.pre # for now, should be comp later on
export sw=$TESTBED_ROOT/sw
[ -d $sw ] && echo "Removing old sw installation..." && rm -rf $sw
mkdir -p $sw

( 
  echo "unset \`set | awk -F= '{ print \$1 }' | sort | egrep -a '_ROOT\$'\`"
  echo
  echo "# Change here if you want to use a new location for your testbed"
  echo export TESTBED_ROOT=$TESTBED_ROOT
  echo
  echo unset PERL5LIB LD_LIBRARY_PATH PYTHONPATH PATH SQLPATH ORACLE_HOME
  echo export PATH=/bin:/usr/bin
  echo export SCRAM_ARCH=$SCRAM_ARCH
  echo export sw=$sw
  echo export LIFECYCLE_ROOT='$TESTBED_ROOT'/lifecycle
  echo export LIFECYCLE='$LIFECYCLE_ROOT'/Testbed/LifeCycle
  echo 
) | tee $ENVIRONMENT

# Base installation
wget -O $sw/bootstrap.sh http://cmsrep.cern.ch/cmssw/cms/bootstrap.sh
sh -x $sw/bootstrap.sh setup -path $sw -arch $SCRAM_ARCH -repository $repo
. $sw/$SCRAM_ARCH/external/apt/*/etc/profile.d/init.sh

# Install PhEDEx from RPMs
rpm=`apt-cache search 'PHEDEX-admin' | sort | tail -1 | awk '{ print $1 }'`
echo Installing $rpm
apt-get -y install $rpm
( cd $TESTBED_ROOT && \
	rm -f phedex && \
	ln -s $sw/$SCRAM_ARCH/cms/PHEDEX-admin/* phedex )

# Install the LifeCycle agent from RPMs
rpm=`apt-cache search PHEDEX-lifecycle | sort | tail -1 | awk '{ print $1 }'`
echo Installing $rpm
apt-get -y install $rpm
( cd $TESTBED_ROOT && \
	rm -f lifecycle && \
	ln -s $sw/$SCRAM_ARCH/cms/PHEDEX-lifecycle/* lifecycle )

(
  echo export PHEDEX_ROOT='$TESTBED_ROOT'/phedex
  echo 
  echo . '$PHEDEX_ROOT'/etc/profile.d/init.sh
  echo . '$LIFECYCLE_ROOT'/etc/profile.d/init.sh
  echo
  echo PYTHONPATH='$PYTHONPATH':/usr/lib/python2.6/site-packages:/usr/lib64/python2.6/site-packages/
  echo
  echo "# DB related items"
  echo export SCHEMA_ROOT='$PHEDEX_ROOT'/Schema
  echo export TNS_ADMIN='$PHEDEX_ROOT'/Schema
  echo
  echo "# Change here if you want to use a different instance"
  echo export PHEDEX_INSTANCE=SuperComputingTestbed
  echo export PHEDEX_DBPARAM='$TESTBED_ROOT'/DBParam:'$PHEDEX_INSTANCE'
  echo export PHEDEX_SCRIPTS='$PHEDEX_ROOT'
  echo export ANSE_ROOT='$TESTBED_ROOT'/ANSE-PhEDEx-Testbed
  echo 
  echo "# You need to set this variable!"
  echo "# export PHEDEX_SITE=InsertYourSiteNameHere"
) | tee -a $ENVIRONMENT >/dev/null

echo "[ -f $TESTBED_ROOT/end-anse.sh ] && . $TESTBED_ROOT/env-anse.sh" >> ~/.bashrc
echo "All done!"
