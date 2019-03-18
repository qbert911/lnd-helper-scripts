#!/bin/bash
IFS=","
eval lncli listchannels | jq -r '.channels[] | [.remote_pubkey,.capacity,.local_balance,.remote_balance,(.active|tostring),(.initiator|tostring),.commit_fee,.commit_weight,.fee_per_kw] | join("," )' > mynodelist.txt

while read -r thisID capacity balance incoming cstate init cf cw fpk; do
  ip=`eval lncli getnodeinfo ${thisID} |jq -r '.node.addresses[].addr'`
  title=`eval lncli getnodeinfo ${thisID} |jq -r '.node.alias'`
  status="-ip4-";color="001m"
  if [[ $ip == *"n:"* ]];then status="onion";color="122m";fi
  if [[ $ip == *":"*":"* ]];then status="mixed";color="111m";fi
  
  echo -e "\e[38;5;$color $status\e[0m,${init:0:1},$title" >> middlefile.txt
done <mynodelist.txt

  data_table=`cat middlefile.txt|sort --field-separator=',' -k 2,2 -k 1| column -n -ts,`
  echo "${data_table}" 

rm -f mynodelist.txt middlefile.txt
