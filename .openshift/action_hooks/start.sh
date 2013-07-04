#!/bin/bash
cd ${OPENSHIFT_DATA_DIR}
cd ..
cd repo
ruby irc_log.rb
echo "Ran post deployment script"