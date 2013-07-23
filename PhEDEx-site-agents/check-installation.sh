#!/bin/bash

cd "`dirname $0`"

# Check the environment
echo "Checking your environment"
if [ -d "$TESTBED_ROOT" ]; then
  echo "TESTBED_ROOT set, good..."
else
  echo "TESTBED_ROOT not defined or not a directory"
  exit 0
fi

if [ ! -f $TESTBED_ROOT/env-anse.sh ]; then
  echo "Cannot find your \$TESTBED_ROOT/env-anse.sh file, did your installation work?"
  exit 0
fi
. $TESTBED_ROOT/env-anse.sh

if [ ! -z "$PHEDEX_SITE" ]; then
  echo "PHEDEX_SITE set to $PHEDEX_SITE, good..."
else
  echo "PHEDEX_SITE not defined. Did you set it in \$TESTBED_ROOT/env-anse.sh?"
  exit 0
fi

if [ `echo $PHEDEX_SITE | grep -v Test | grep -c Buffer` -gt 0 ]; then
  echo "Your PHEDEX_SITE variable should not have the '_Buffer' extension"
  exit 0
fi
if [ "$PHEDEX_SITE" == "InsertYourSiteNameHere" ]; then
  echo "You have not defined the PHEDEX_SITE variable yet."
  echo "You need to set it in \$TESTBED_ROOT/env-anse.sh"
  exit 0
fi

# Check the user has a DBParam
param=`echo $PHEDEX_DBPARAM | awk -F: '{ print $1 }'`
if [ -f $param ]; then
  echo "You have a DBParam file at $param, good..."
else
  echo "You do not have a DBParam file yet, it should be at $param"
  exit 0
fi

# Check PhEDEx DB connection works
echo "Checking your database connection"
$PHEDEX_ROOT/Utilities/Master --config Config.ANSE checkdb

# Check lifecycle agent works? (not needed...)

# Declare success!
echo "If you see this message that means it all worked! You can now start your agents."
