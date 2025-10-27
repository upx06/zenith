#!/bin/sh
set -e
/app/bin/zenith eval "Zenith.Release.migrate"
exec /app/bin/zenith start