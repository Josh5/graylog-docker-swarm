#!/usr/bin/env bash
###
# File: run-fluent-bit.sh
# Project: fluent-bit
# File Created: Tuesday, 29th October 2024 1:00:08 pm
# Author: Josh5 (jsunnex@gmail.com)
# -----
# Last Modified: Tuesday, 29th October 2024 2:44:35 pm
# Modified By: Josh5 (jsunnex@gmail.com)
###

loop_run() {
    sudo docker stop test-fluent-bit && sudo docker rm test-fluent-bit
    sudo docker run -d \
        --name test-fluent-bit \
        -e HOST_IP=$(hostname -I | awk '{print $1}') \
        -v $(pwd)/etc/fluent-bit.yaml:/fluent-bit/etc/fluent-bit.yaml \
        -v $(pwd)/logs:/logs \
        fluent/fluent-bit:latest \
        /fluent-bit/bin/fluent-bit -c /fluent-bit/etc/fluent-bit.yaml

    sudo docker logs -fn100 test-fluent-bit &

    sleep 5
}

while true;do
    loop_run
done
