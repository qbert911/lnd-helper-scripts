#!/bin/bash
if [[ -n $1 ]];then
	thisID=`eval echo ${1} | cut -d"@" -f 1`
	ip=`eval echo ${1} | cut -d"@" -f 2`
	if [[ $ip != *":"* ]];then
		ip=`eval lncli getnodeinfo ${thisID} |jq 'first(.node.addresses[].addr)'`
		echo "Looking up ip..."
	fi
	echo
	echo $ip
	echo $thisID
	echo
	lncli getnodeinfo ${thisID} |jq -r '.node.alias'
	echo
	read -p "Are you sure ? " -n 1 -r
	if [[ $REPLY =~ ^[Yy]$ ]];then
		echo -e "\nOK..."
		#lncli sendtoroute --payment_hash=<pay_hash> --routes=<route>
	fi
else
	lncli listchannels | jq -r '.channels[] | select(.remote_balance|tonumber > 1000000)|[.remote_pubkey,.capacity,.local_balance,.remote_balance,.channel_point[0:6]]|join(",")'|sort --field-separator=',' -k 1|sort --field-separator=',' -n -k 3,3 |column -n -ts,
fi
