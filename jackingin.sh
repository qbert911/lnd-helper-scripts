#!/bin/bash
IFS=","     #add hot to run full auto
while read -r thisID extradata; do
    eval "./openchan.sh $thisID 2000000 $1"
done < nodelisttargets.txt