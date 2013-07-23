#!/bin/bash

if [ ! -d "$TESTBED_ROOT" ]; then
  echo "TESTBED_ROOT not defined or not a directory"
  exit 0
fi

. $TESTBED_ROOT/env-anse.sh
$PHEDEX_ROOT/Utilities/Master --config Config.ANSE start watchdog
