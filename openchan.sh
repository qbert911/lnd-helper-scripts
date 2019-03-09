#!/bin/bash

thisID=`eval echo ${1} | cut -d"@" -f 1`
ip=`eval echo ${1} | cut -d"@" -f 2`

echo $ip 
echo $thisID
curl -s https://1ml.com/node/$thisID |grep "<h1>Node" |pup h1 text{}| tr -d '()' 
echo $2 satoshis
echo $(echo "scale=8; $2 / 100000000" | bc -ql ) btc
echo

read -p "Are you sure? " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]];then
	echo -e "\nOK..."
	lncli openchannel --sat_per_byte 1 --connect $ip $thisID $2 0
fi

