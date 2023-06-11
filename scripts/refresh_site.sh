#!/bin/bash
SCRIPT_PATH=`realpath "$0"`
SCRIPT_DIR=`dirname "$SCRIPT_PATH"`

source ${SCRIPT_DIR}/utils.sh
update_site
