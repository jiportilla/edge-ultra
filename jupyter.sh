#!/bin/bash

#lighttpd -D -f /etc/lighttpd/lighttpd.conf
jupyter notebook --port=8888 --no-browser --ip=0.0.0.0 --allow-root

while true; do
    echo "DEBUG: ****   $HZN_DEVICE_ID is pulling ESS ..."
    echo "DEBUG: **** HERE IN JUPYTER"
    sleep  30
done
