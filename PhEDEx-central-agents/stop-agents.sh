#!/bin/bash

. $TESTBED_ROOT/env-anse.sh
$PHEDEX_ROOT/Utilities/Master --config Config.Mgmt.Testbed stop
for dir in $TESTBED_ROOT/Testbed2_Mgmt/state/*/
do
  [ -f $dir/pid ]  && rm $dir/pid
  [ -f $dir/stop ] && rm $dir/stop
done
