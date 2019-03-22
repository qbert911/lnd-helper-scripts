#!/bin/bash
IFS=","     #add hot to run full auto
myconnections=`eval lncli listchannels | jq -r '.channels[].remote_pubkey'`
mypending=`eval lncli pendingchannels | jq -r '.pending_open_channels[].channel.remote_node_pub'`
mypendingc=`eval lncli pendingchannels | jq -r '.pending_force_closing_channels[].channel.remote_node_pub'`
blacklist=`eval lncli closedchannels | jq -r '.channels[]|select(.close_type=="REMOTE_FORCE_CLOSE") |.remote_pubkey'`

while read -r thisID channels; do
  : $((recs++))
	ip=`eval lncli getnodeinfo ${thisID} |jq -r '.node.addresses[].addr'`
  title=`eval lncli getnodeinfo ${thisID} |jq -r '.node.alias'`
	if [[ $myconnections == *$thisID* || $mypending == *$thisID* || $mypendingc == *$thisID* ]];then
		status="connected";color="111m";thisIDd=$thisID; : $((recse++))
		if [[ $ip == *"n:"* ]];then status="allset";color="122m";thisIDd=""; : $((recsc++));fi
		if [[ $ip == *":"*":"* ]];then status="CONmix";color="111m";thisIDd=$thisID; : $((recse++));fi	
	else
		status="no";color="235m";thisIDd=""
		if [[ $ip == *"n:"* ]];then status="target";color="065m";thisIDd=$thisID; : $((recst++));fi
		if [[ $ip == *":"*":"* ]];then status="mixed ";color="241m";thisIDd=""; : $((recsm++));fi
    if [[ $blacklist == *$thisID* ]];then status="BLACKLIST";color="001m";thisIDd=""; : $((recsm++));fi
	fi
	if [[ $thisID == "02419ef2aa268f21606cdc725f08d5ddf2365de96b2606b5852e4155c0f24260e3" ]]; then
		status="me";color="177m";thisIDd="";fi
	if [[ $status == "target" ]];then 
	  echo -e "\e[38;5;$color $channels,"$title",$status,$thisIDd \e[0m" 
    eval "./openchan.sh $thisID 2000000 $1"
    echo
  fi
done <listofonionnodes.csv

echo -e " $recs records: $recsc connected $(( $recst - $recsm )) target $recsm mixed $(( $recse - $recsc )) errors $(( $recs - $recst - $recse )) duds"

