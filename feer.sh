#!/bin/bash
IFS=","
myid=`eval lncli getinfo | jq -r '.identity_pubkey'`
mytitle=`eval lncli getnodeinfo ${myid} |jq -r '.node.alias'`
lncli listchannels | jq -r '.channels[].chan_id' > nchannelfees.txt
while read -r thischanID extradata; do
  : $((recs++))
  lncli getchaninfo ${thischanID} > tempchandata.json
  thisID=`cat tempchandata.json |jq -r '.node1_pub'`
  thisID2=`cat tempchandata.json  |jq -r '.node2_pub'`
  chanfees1=`cat tempchandata.json  |jq -r '[(.node1_policy.fee_base_msat|tonumber),(.node1_policy.fee_rate_milli_msat|tonumber)]|@csv'`
  chanfees2=`cat tempchandata.json  |jq -r '[(.node2_policy.fee_base_msat|tonumber),(.node2_policy.fee_rate_milli_msat|tonumber)]|@csv'`
  if [[ $thisID2 == $myid ]];then 
    idt=$chanfees2;    chanfees2=$chanfees1;    chanfees1=$idt
    thisID2=$thisID;    thisID=$myid
  fi
  title2=`eval lncli getnodeinfo ${thisID2} |jq -r '.node.alias'`
  echo -e "$mytitle,$chanfees1,<-->,$chanfees2,$title2"  >> midway.txt
  echo -n "."
done <nchannelfees.txt
boop=`cat midway.txt |sort -g -r --field-separator=',' -k 5,5 -k 6,6 -k 2 | column -ts,`
echo -e -n "\n${boop}\n $recs channels   earned in fees: "
rm -f midway.txt tempchandata.json nchannelfees.txt
lncli feereport | jq -r '.month_fee_sum'
