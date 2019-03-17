#!/bin/bash
IFS=","
myconnections=`eval lncli listchannels | jq -r '.channels[].remote_pubkey'`
mypending=`eval lncli pendingchannels | jq -r '.pending_open_channels[].channel.remote_node_pub'`

  while read -r thisID title channels; do
    	: $((recs++))
	ip=`eval lncli getnodeinfo ${thisID} |jq -r '.node.addresses[].addr'`
	
	if [[ $myconnections == *$thisID* || $mypending == *$thisID* ]];then
		status="connected";color="111m";thisIDd=$thisID; : $((recse++))
		if [[ $ip == *"n:"* ]];then status="found";color="122m";thisIDd=""; : $((recsc++));fi		
		if [[ $ip == *":"*":"* ]];then status="CONmixed";color="111m";thisIDd=$thisID; : $((recse++));fi	
	else
		status="no";color="235m";thisIDd=""
		if [[ $ip == *"n:"* ]];then status="target";color="065m";thisIDd=$thisID; : $((recst++));fi
		if [[ $ip == *":"*":"* ]];then status="mixed";color="241m";thisIDd=""; : $((recsm++));fi
	fi
	if [[ $thisID == "02419ef2aa268f21606cdc725f08d5ddf2365de96b2606b5852e4155c0f24260e3" ]]; then 
		status="me";color="177m";thisIDd="";fi

	echo "\e[38;5;$color $channels,$title,$status,$thisIDd \e[0m" >> midway.txt
  done <listofonionnodes.csv

	boop=`cat midway.txt | column -ts,`
	echo -e "${boop}\n $recs records: $recsc connected $(( $recst - $recsm )) target $recsm mixed $(( $recse - $recsc )) errors $(( $recs - $recst - $recse )) duds"

rm -f midway.txt
