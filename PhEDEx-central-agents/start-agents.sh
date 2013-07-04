#!/bin/bash

. $TESTBED_ROOT/env-anse.sh
echo $PHEDEX_ROOT
ls -l $PHEDEX_ROOT/Utilities/Master
$PHEDEX_ROOT/Utilities/Master --config Config.Mgmt.Testbed start watchdog
