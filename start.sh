#!/bin/bash

# turn on bash's job control
set -m

# Start the primary process (jupyter server) and put it in the background
./jupyter.sh &

# Start the helper process (ESS pull service)
#./service.sh
#./test.sh
./mms.service.sh

# now we bring the primary process (http server) back into the foreground
# and leave it there
fg %1

# Details at:
# https://docs.docker.com/config/containers/multi-service_container/
