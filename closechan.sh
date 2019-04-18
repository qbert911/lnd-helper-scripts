#!/bin/bash
if [[ -n $1 ]];then
	chanpoint=`eval lncli getchaninfo ${1} |jq -r '.chan_point'`
	n1=`eval lncli getchaninfo ${1} |jq -r '.node1_pub'`
	n2=`eval lncli getchaninfo ${1} |jq -r '.node2_pub'`
	thisID=`eval echo ${chanpoint} | cut -d":" -f 1`
	idx=`eval echo ${chanpoint} | cut -d":" -f 2`
	
	echo
	echo $thisID
	echo "Index: $idx "
	echo
	lncli getnodeinfo ${n1} |jq -r '.node.alias'
	echo
	lncli getnodeinfo ${n2} |jq -r '.node.alias'
	echo
	read -p "Are you sure you want CLOSE? " -n 1 -r
	if [[ $REPLY =~ ^[Yy]$ ]];then
		echo -e "\nOK..."
		lncli closechannel --sat_per_byte 1 --funding_txid $thisID --output_index $idx
	fi
	echo 
else
	lncli listchannels | jq -r '.channels[] | [.remote_pubkey[0:6],.capacity,.local_balance,.remote_balance,.total_satoshis_sent,.total_satoshis_received,.chan_id]|join(",")'|sort --field-separator=',' -k 1|sort --field-separator=',' -n -k 5,5 -k 6,6 -k 4,4 -k 2,2  |column -n -ts,
fi
