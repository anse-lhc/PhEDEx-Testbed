#!/bin/bash
# Developer Testbed Setup - 1xT0 + 4xT2_Test + NxT2_ANSE_xyz

# Declare a couple of environment variables for steering
if [ -z $TESTBED_ROOT ]; then
  echo "TESTBED_ROOT not set, are you sure you sourced the environment?"
  exit 0
fi
if [ -z $LIFECYCLE ]; then
  echo "LIFECYCLE not set, are you sure you sourced the environment?"
  exit 0
fi
if [ -z $PHEDEX_ROOT ]; then
  echo "PHEDEX_ROOT not set, are you sure you sourced the environment?"
  exit 0
fi
if [ -z $PHEDEX_DBPARAM ]; then
  echo "PHEDEX_DBPARAM not set, are you sure you sourced the environment?"
  exit 0
fi

export PHEDEX=$PHEDEX_ROOT
PHEDEX_SQLPLUS="sqlplus $($PHEDEX/Utilities/OracleConnectId -db $PHEDEX_DBPARAM)"
PHEDEX_SQLPLUS_CLEAN=`echo $PHEDEX_SQLPLUS | sed -e's%/.*@%/password-here@%'`
# Minimal sanity-check on the DBPARAM and contents:
if [ `echo $PHEDEX_DBPARAM | egrep -ic 'prod|dev|debug|admin'` -gt 0 ]; then
  echo "Your DBParam appears to be unsafe?"
  echo "(It has one of 'prod|dev|debug|admin' in it, so I don't trust it)"
  exit 0
fi
if [ `echo $PHEDEX_SQLPLUS | egrep -ic 'testbed2'` -eq 0 ]; then
  echo "Your DBParam appears to be unsafe?"
  echo "('testbed2' does not appear in your connection string, so I don't trust it)"
  exit 0
fi

echo "Connection attempted as: $PHEDEX_SQLPLUS_CLEAN"
i=`echo 'select sysdate from dual;' | $PHEDEX_SQLPLUS 2>/dev/null | grep -c SYSDATE`
if [ $i -gt 0 ]; then
  echo "Your database connection is good..."
else
  echo "Cannot connect to your database (status=$i)"
  echo "Connection attempted as: $PHEDEX_SQLPLUS_CLEAN"
  echo "(your TNS_ADMIN is $TNS_ADMIN, in case that matters)"
  echo "(Oh, and your sqlplus is in `which sqlplus`)"
  exit 0
fi

# Create nodes / links
#$PHEDEX_ROOT/Utilities/NodeNew -db $PHEDEX_DBPARAM -name T0_Test_Buffer \
#        -kind Buffer -technology Other -se-name srm.test0.ch
#$PHEDEX_ROOT/Utilities/NodeNew -db $PHEDEX_DBPARAM -name T2_Test1_Buffer \
#        -kind Buffer -technology Other -se-name srm.test1.ch
#$PHEDEX_ROOT/Utilities/NodeNew -db $PHEDEX_DBPARAM -name T2_Test2_Buffer \
#        -kind Buffer -technology Other -se-name srm.test2.ch
#$PHEDEX_ROOT/Utilities/LinkNew -db $PHEDEX_DBPARAM T2_Test1_Buffer T2_Test2_Buffer:R/2

cd $TESTBED_ROOT/ANSE-PhEDEx-Testbed/PhEDEx-admin
./create-nodes.sh

i=1
echo -n "Inserting groups: "
for group in physicists managers operators administrators experts other anse ipv6
do
  echo -n "$group "
  echo "insert into t_adm_group (id,name) values ($i,'$group');" | $PHEDEX_SQLPLUS >/dev/null
  i=`expr $i + 1`
done
echo "groups inserted"

$LIFECYCLE/getNodesGroups.sh
echo ANSE-node setup completed
