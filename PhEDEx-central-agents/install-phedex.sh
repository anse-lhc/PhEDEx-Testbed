#!/bin/sh

# Install the software two levels up from here
(cd ../.. ; export TESTBED_ROOT=`pwd`)
echo "Set TESTBED_ROOT=$TESTBED_ROOT"

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
  echo export LIFECYCLE_ROOT=$TESTBED_ROOT/sw/lifecycle
  echo export LIFECYCLE=$TESTBED_ROOT/sw/lifecycle/Testbed/LifeCycle
) | tee $ENVIRONMENT

# Base installation
wget -O $sw/bootstrap.sh http://cmsrep.cern.ch/cmssw/cms/bootstrap.sh
sh -x $sw/bootstrap.sh setup -path $sw -arch $SCRAM_ARCH -repository $repo
. $sw/$SCRAM_ARCH/external/apt/*/etc/profile.d/init.sh

# Install PhEDEx from RPMs
rpm=`apt-cache search 'PHEDEX-admin' | sort | tail -1 | awk '{ print $1 }'`
echo Installing $rpm
apt-get -y install $rpm
(cd $sw; rm -f phedex; ln -s $sw/$SCRAM_ARCH/cms/PHEDEX-admin/* phedex)

# Install the LifeCycle agent from RPMs
rpm=`apt-cache search PHEDEX-lifecycle | sort | tail -1 | awk '{ print $1 }'`
echo Installing $rpm
apt-get -y install $rpm
(cd $sw; rm -f lifecycle; ln -s $sw/$SCRAM_ARCH/cms/PHEDEX-lifecycle/* lifecycle)

(
  echo '[ -f /afs/cern.ch/cms/LCG/LCG-2/UI/cms_ui_env.sh ] && \'
  echo '  . /afs/cern.ch/cms/LCG/LCG-2/UI/cms_ui_env.sh'
  echo . $TESTBED_ROOT/sw/phedex/etc/profile.d/init.sh
  echo . $TESTBED_ROOT/sw/lifecycle/etc/profile.d/init.sh
  echo export PHEDEX_ROOT=$TESTBED_ROOT/sw/phedex
  echo export SCHEMA_ROOT=$TESTBED_ROOT/sw/phedex/Schema
  echo export TNS_ADMIN=$TESTBED_ROOT/sw/phedex/Schema
  echo export PHEDEX_DBPARAM=$TESTBED_ROOT/DBParam:Testbed2
  echo export SQLPATH=~/wildish/public:$SQLPATH
) | tee -a $ENVIRONMENT >/dev/null

# Now get HEAD from git to override RPM installations
cd $sw/$SCRAM_ARCH/cms/PHEDEX-admin
version=`ls -1 | tail -1`
mv $version $version.rpm-installed
branch=`echo $version | sed -e 's%-.*$%%'`
git clone -b $branch git@github.com:dmwm/PHEDEX.git PHEDEX-git
ln -s PHEDEX-git $version
cd $version
git checkout -b ANSE
ln -s ../$version.rpm-installed/{etc,T0} .
mkdir bin
ln -s `find .. -name '*.pl' | grep -v examples` .

cd $sw/$SCRAM_ARCH/cms/PHEDEX-lifecycle
version=`ls -1 | tail -1`
mv $version $version.rpm-installed
version=`echo $version | sed -e 's%-.*$%%'`
git clone -b PHEDEX-LifeCycle git@github.com:dmwm/PHEDEX.git LifeCycle-git
ln -s LifeCycle-git $version
cd $version
git checkout -b ANSE
ln -s ../$version.rpm-installed/etc .

echo "All done!"
