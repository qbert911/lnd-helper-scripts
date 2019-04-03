#!/bin/bash
if [[ -n $1 ]];then
	thisID=`eval echo ${1} | cut -d":" -f 1`
	idx=`eval echo ${1} | cut -d":" -f 2`
	echo
	echo $thisID
	echo "Index: $idx "
	echo
	lncli getnodeinfo ${thisID} |jq -r '.node.alias'
	echo
	read -p "Are you sure you want CLOSE? " -n 1 -r
	if [[ $REPLY =~ ^[Yy]$ ]];then
		echo -e "\nOK..."
		lncli closechannel --sat_per_byte 1 --funding_txid $thisID --output_index $idx
	fi
else
	lncli listchannels | jq -r '.channels[] | [.remote_pubkey[0:6],.capacity,.local_balance,.remote_balance,.channel_point]|join(",")'|sort --field-separator=',' -k 1|sort --field-separator=',' -n -k 3,3 |column -n -ts,
fi
