#!/bin/sh
xvfb-run chromium --disable-gpu --remote-debugging-address=0.0.0.0 "$@"
