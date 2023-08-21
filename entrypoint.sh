#!/bin/bash
unset BUNDLE_PATH
unset BUNDLE_BIN
set -e
exec "$@"
