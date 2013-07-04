#!/bin/bash

. $TESTBED_ROOT/env-anse.sh
$PHEDEX_ROOT/Utilities/Master --config Config.Mgmt.Testbed start watchdog
