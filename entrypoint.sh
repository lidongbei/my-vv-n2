#!/bin/sh
set -eu

if [ "$#" -gt 0 ]; then
  exec "$@"
fi

./curl-check-test.sh &
exec ./sing-box run -c config.json
