#!/bin/bash
if [[ -n $1 ]];then
	chanpoint=`eval lncli getchaninfo ${1} |jq -r '.chan_point'`
	thisID=`eval echo ${chanpoint} | cut -d":" -f 1`
	idx=`eval echo ${chanpoint} | cut -d":" -f 2`
	echo
	echo "$(lncli getnodeinfo $(lncli getchaninfo ${1} |jq -r '.node1_pub') |jq -r '.node.alias')		<-->		$(lncli getnodeinfo $(lncli getchaninfo ${1} |jq -r '.node2_pub') |jq -r '.node.alias')"
	echo
	if [[ $2 == "hot" ]];then
		lncli closechannel --sat_per_byte 1 --funding_txid $thisID --output_index $idx
	elif [[ $2 == "force" ]];then
		lncli closechannel --funding_txid $thisID --output_index $idx --force
	else	
		read -p "Are you sure you want CLOSE? " -n 1 -r
		if [[ $REPLY =~ ^[Yy]$ ]];then
			echo -e "\nOK..."
			lncli closechannel --sat_per_byte 1 --funding_txid $thisID --output_index $idx $2
		fi
	fi	
	echo 	
else
	lncli listchannels | jq -r '.channels[] | [.remote_pubkey[0:6],.capacity,.local_balance,.remote_balance,.total_satoshis_sent,.total_satoshis_received,.chan_id]|join(",")'|sort --field-separator=',' -k 1|sort --field-separator=',' -n -k 5,5 -k 6,6 -k 4,4 -k 2,2  |column -n -ts,
fi
