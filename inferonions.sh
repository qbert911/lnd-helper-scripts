#!/bin/bash
IFS=","
myid=`eval lncli getinfo | jq -r '.identity_pubkey'`
myconnections=`eval lncli listchannels | jq -r '.channels[].remote_pubkey'`
mypending=`eval lncli pendingchannels | jq -r '.pending_open_channels[].channel.remote_node_pub'`
mypendingc=`eval lncli pendingchannels | jq -r '.pending_force_closing_channels[].channel.remote_node_pub'`
blacklist=`eval lncli closedchannels | jq -r '.channels[]|select(.close_type=="REMOTE_FORCE_CLOSE" or .close_type=="LOCAL_FORCE_CLOSE") |.remote_pubkey'`
threshold="100000000"
rm -f nodelisttargets.txt
echo -n "Searching all known nodes..."
lncli describegraph | jq -r '[.nodes[]|select(.addresses[].addr|contains("onion"))|.pub_key]|unique|.[]' > nodelistonions.txt
echo -e -n "$( wc -l nodelistonions.txt | sed -e 's/ .*//') found with an .onion address"
while read -r thisID extradata; do
  : $((recs++))
  capa=`eval lncli getnodeinfo ${thisID} |jq -r '.total_capacity'`
  min=$(echo "$capa" "$threshold" | awk '{if ($1 > $2) print "1"; else print "0"}')
if (( $min == "1" ));then
  title=`eval lncli getnodeinfo ${thisID} |jq -r '.node.alias'`
  ip=`eval lncli getnodeinfo ${thisID} |jq -r '.node.addresses[].addr'`
  channels=`eval lncli getnodeinfo ${thisID} |jq -r '.num_channels'`
  if [[ $myconnections == *$thisID* || $mypending == *$thisID* || $mypendingc == *$thisID* ]];then
		                                      status="connect?";color="111m";thisIDd=$thisID
		if [[ $ip == *"n:"* ]];then           status="connected";color="113m";thisIDd=""; fi
		if [[ $ip == *":"*":"* ]];then        status="CONmix";color="111m";thisIDd=""; fi	
    if [[ $ip == *"n:"*"n:"* ]];then      status="multio";color="113m";thisIDd=""; fi
    if [[ $ip == *":"*":"*":"* ]];then    status="CONmix";color="111m";thisIDd=""; fi
	else
		                                      status="no";color="235m";thisIDd=""
		if [[ $ip == *"n:"* ]];then           status="target";color="122m";thisIDd=$thisID; fi
		if [[ $ip == *":"*":"* ]];then        status="mixed";color="241m";thisIDd=$thisID; fi
    if [[ $ip == *"n:"*"n:"* ]];then      status="multi";color="062m";thisIDd=$thisID; fi
    if [[ $ip == *":"*":"*":"* ]];then    status="mixed2";color="241m";thisIDd=$thisID; fi
    if [[ $blacklist == *$thisID* ]];then status="BLACKLIST";color="001m";thisIDd=""; fi
  fi
  if [[ $thisID == $myid ]]; then         status="me";color="177m";thisIDd=""; fi
  case "$status" in
    "mixed" | "mixed2" | "BLACKLIST" | "no")    : $((recstb++))        ;;
    "connect?" | "CONmix")                      : $((recscb++))        ;;
    "connected" | "multio" | "me")              : $((recscg++))        ;;
    "target" | "multi")                         : $((recstg++));echo $thisID >> nodelisttargets.txt       ;;
  esac  
	echo -e "\e[38;5;$color , $channels,$(echo "scale=8; $capa / 100000000" | bc -ql ),"$title",$status,$thisIDd \e[0m" >> midway.txt
else
                                    : $((recssm++))        
fi
  echo -n "."
done <nodelistonions.txt
	boop=`cat midway.txt |sort -g -r --field-separator=',' -k 2,2 -k 3 | column -ts,`
	echo -e "\n${boop}\n\n$(( $recs - $recssm )) nodes with an .onion address over threshold of $threshold satoshi :   \e[38;5;122m$recstg targets    \e[38;5;241m$recstb undesireable    \e[38;5;113m$recscg connected pure onion   \e[38;5;111m$recscb connected mixed\n"
rm -f midway.txt nodelistonions.txt
