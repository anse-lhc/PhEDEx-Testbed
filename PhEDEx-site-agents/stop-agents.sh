#!/bin/bash

if [ ! -d "$TESTBED_ROOT" ]; then
  echo "TESTBED_ROOT not defined or not a directory"
  exit 0
fi

. $TESTBED_ROOT/env-anse.sh
$PHEDEX_ROOT/Utilities/Master --config Config.T2_Test1_Buffer stop
$PHEDEX_ROOT/Utilities/Master --config Config.T2_Test2_Buffer stop
for dir in $TESTBED_ROOT/Testbed2_T2_Test*/state/*/
do
  [ -f $dir/pid ]  && rm $dir/pid
  [ -f $dir/stop ] && rm $dir/stop
done
