#!/bin/sh

##########                         Killwine                           ##########
################################################################################
PIDSTT=$(eval "ps x | grep wine | awk '{print \$1}'")
for PID in $PIDSTT;
do
    if (ps -p $PID | grep $PID) &>/dev/null; then
        if kill -9 $PID; then
            echo "Killed $PID"
        else
            echo "could not kill $PID"
        fi
    fi
done
