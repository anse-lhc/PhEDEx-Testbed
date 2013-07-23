#!/bin/sh

export TESTBED_ROOT=/home/vagrant/TESTBED_ROOT
if [ ! -d "$TESTBED_ROOT" ]; then
  echo "TESTBED_ROOT not a directory. Creating it..."
  mkdir TESTBED_ROOT
fi
cd $TESTBED_ROOT
if [ `pwd` != $TESTBED_ROOT ]; then
  echo "Cannot cd to $TESTBED_ROOT"
  exit 0
fi

if [ ! -d ANSE-PhEDEx-Testbed ]; then
  git clone https://github.com/TonyWildish/ANSE-PhEDEx-Testbed
fi

ENVIRONMENT=$TESTBED_ROOT/env-anse.sh
export SCRAM_ARCH=slc5_amd64_gcc461
export repo=comp.pre.wildish # for now, should be comp later on
export sw=$TESTBED_ROOT/sw
[ -d $sw ] && echo "Removing old sw installation..." && rm -rf $sw
mkdir -p $sw

( 
  echo "unset \`set | awk -F= '{ print \$1 }' | sort | egrep -a '_ROOT\$'\`"
  echo export TESTBED_ROOT=$TESTBED_ROOT
  echo unset PERL5LIB LD_LIBRARY_PATH PYTHONPATH PATH SQLPATH ORACLE_HOME
  echo export PATH=/bin:/usr/bin
  echo export SCRAM_ARCH=$SCRAM_ARCH
  echo export sw=$sw
  echo export LIFECYCLE_ROOT=$TESTBED_ROOT/lifecycle
  echo export LIFECYCLE=$TESTBED_ROOT/lifecycle/Testbed/LifeCycle
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
  echo '[ -f /afs/cern.ch/cms/LCG/LCG-2/UI/cms_ui_env.sh ] && \'
  echo '  . /afs/cern.ch/cms/LCG/LCG-2/UI/cms_ui_env.sh'
  echo . $TESTBED_ROOT/phedex/etc/profile.d/init.sh
  echo . $TESTBED_ROOT/lifecycle/etc/profile.d/init.sh
  echo export PHEDEX_ROOT=$TESTBED_ROOT/phedex
  echo export SCHEMA_ROOT=$TESTBED_ROOT/phedex/Schema
  echo export TNS_ADMIN=$TESTBED_ROOT/phedex/Schema
  echo export PHEDEX_DBPARAM=$TESTBED_ROOT/DBParam:Testbed2
  echo export SQLPATH=~/wildish/public:$SQLPATH
  echo export PHEDEX_SCRIPTS=$TESTBED_ROOT/lifecycle
  echo ' '
  echo "# You need to set this variable!"
  echo "# export PHEDEX_SITE=InsertYourSiteNameHere"
) | tee -a $ENVIRONMENT >/dev/null

echo '. /home/vagrant/TESTBED_ROOT/env-anse.sh' >> ~/.bashrc
echo "All done!"
