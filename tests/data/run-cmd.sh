#!/bin/bash -e

echo "Waiting for keystone to become available at http://keystone:5000..." ; \
        success=false ; \
        for i in {1..15}; do  \
        if wget  -q -O - "http://keystone:5000" > /dev/null; then  \
            echo "Keystone API is up, continuing..." ; \
            success=true ; \
            break ; \
        else  \
            echo "Connection to keystone failed, attempt #$i of 10" ; \
            sleep 1 ; \
        fi ; \
        done

source /data/openrc

#rally deployment create --name deploy --filename /data/auth.json
rally deployment create --name deploy --fromenv

rally deployment check

openstack project list
#cat /etc/hosts

sleep 100
