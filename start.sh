#!/bin/bash

# Start supervisord
/etc/init.d/supervisord start 2>/dev/null
# Start nginx
service nginx start
