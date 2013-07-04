#!/bin/bash

. $TESTBED_ROOT/env-anse.sh
$PHEDEX_ROOT/Utilities/Master --config Config.T2_Test1_Buffer start watchdog
$PHEDEX_ROOT/Utilities/Master --config Config.T2_Test2_Buffer start watchdog
