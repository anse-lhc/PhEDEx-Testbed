#!/bin/sh
#
# Create the ANSE nodes in the database
#

datasvc=https://brazil.accre.vanderbilt.edu:4443/phedex/datasvc/perl/prod
#datasvc=https://phedex-web-dev.cern.ch/phedex/datasvc/perl/tbedii

if [ -z $PHEDEX_ROOT ]; then
  echo "PHEDEX_ROOT not set, are you sure you sourced the environment?"
  exit 0
fi
if [ -z $PHEDEX_DBPARAM ]; then
  echo "PHEDEX_DBPARAM not set, are you sure you sourced the environment?"
  exit 0
fi

# List of locations in the testbed
ANSE=( CERN Caltech Indiana Michigan Vanderbilt UTA )
Test=( Test1 Test2 Test3 Test4 )
locations=( T0_Test_Buffer )
for i in ${ANSE[*]}
do
  locations=("${locations[@]}" "T2_ANSE_${i}")
done
for i in ${Test[*]}
do
  locations=("${locations[@]}" "T2_${i}_Buffer")
done

for node in ${locations[*]}
do
  if [ `wget --no-check-certificate -q -O - $datasvc/nodes | grep -c $node` -eq 0 ]; then
    echo "$node does not exist, create it!"
    $PHEDEX_ROOT/Utilities/NodeNew \
	-db $PHEDEX_DBPARAM \
	-name $node \
	-kind Disk \
	-technology Other \
	-se-name $node.se.anse.org
  else
    echo "$node already there..."
  fi
done

for node in ${locations[*]}
do
  echo "Check links for $node"
  for peer in ${locations[*]}
  do
    if [ $node != $peer ]; then
      if [ `wget --no-check-certificate -q -O - "$datasvc/links?to=$node;from=$peer" | grep -c STATUS` -ne 1 ]; then
        echo "Create link: $node <-> $peer"
        $PHEDEX_ROOT/Utilities/LinkNew \
		-db $PHEDEX_DBPARAM \
		$node $peer
      fi
    fi
  done
done
