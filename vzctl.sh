#!/bin/bash

CTID=$(echo $1 | awk '{match($0,"[0-9]+$",ID); print ID[0]}')
/usr/bin/sudo /usr/sbin/vzctl exec2 $CTID $2
