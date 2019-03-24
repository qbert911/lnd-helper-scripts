#!/bin/bash
myconnections=`eval lncli listchannels | jq -r '.channels[].remote_pubkey'`
mypending=`eval lncli pendingchannels | jq -r '.pending_open_channels[].channel.remote_node_pub'`
mypendingc=`eval lncli pendingchannels | jq -r '.pending_force_closing_channels[].channel.remote_node_pub'`
blacklist=`eval lncli closedchannels | jq -r '.channels[]|select(.close_type=="REMOTE_FORCE_CLOSE"  or .close_type=="LOCAL_FORCE_CLOSE") |.remote_pubkey'`
thisID=`eval echo ${1} | cut -d"@" -f 1`
ip=`eval echo ${1} | cut -d"@" -f 2`

if [[ $ip != *":"* ]];then
	ip=`eval lncli getnodeinfo ${thisID} |jq 'first(.node.addresses[].addr)'`
	echo "Looking up ip..."
fi

echo $ip
echo $thisID
echo
curl -s https://1ml.com/node/$thisID |grep "<h1>Node" |pup h1 text{}| tr -d '()'
echo
echo $2 satoshis
echo $(echo "scale=8; $2 / 100000000" | bc -ql ) btc
echo
if [[ $3 != "force" && $myconnections == *$thisID* || $mypending == *$thisID* || $mypendingc == *$thisID* || $blacklist == *$thisID* ]];then
	echo -e "\nHEY DUMMY already connected to this node"
else
	if [[ $3 == "hot" ]];then
			eval "lncli openchannel --sat_per_byte 1 --connect $ip $thisID $2 0"
	else
			echo "openchannel --sat_per_byte 1 --connect $ip $thisID $2 0" | xargs -p lncli
	fi
fi
