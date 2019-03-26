#!/bin/bash
IFS=","
myid=`eval lncli getinfo | jq -r '.identity_pubkey'`
#lncli feereport | jq -r '.channel_fees[]|[.channel_point,.base_fee_msat,.fee_per_mil,(.fee_rate|tostring)]|join(",")'
#lncli feereport | jq -r '.month_fee_sum'
lncli listchannels | jq -r '.channels[].chan_id' > nchannelfees.txt

while read -r thischanID extradata; do
  : $((recs++))
  thisID=`eval lncli getchaninfo ${thischanID} |jq -r '.node1_pub'`
  thisID2=`eval lncli getchaninfo ${thischanID} |jq -r '.node2_pub'`
  chanfees1=`eval lncli getchaninfo ${thischanID} |jq -r '[(.node1_policy.fee_base_msat|tonumber),(.node1_policy.fee_rate_milli_msat|tonumber)]|@csv'`
  chanfees2=`eval lncli getchaninfo ${thischanID} |jq -r '[(.node2_policy.fee_base_msat|tonumber),(.node2_policy.fee_rate_milli_msat|tonumber)]|@csv'`
  if [[ $thisID2 == $myid ]];then 
    idt=$chanfees2
    chanfees2=$chanfees1
    chanfees1=$idt
    thisID2=$thisID
    thisID=$myid
 fi
  title=`eval lncli getnodeinfo ${thisID} |jq -r '.node.alias'`
  title2=`eval lncli getnodeinfo ${thisID2} |jq -r '.node.alias'`
echo -e "$title,$title2,$chanfees1,$chanfees2 \e[0m"  >> midway.txt
 echo -n "."
done <nchannelfees.txt
boop=`cat midway.txt |sort -g -r --field-separator=',' -k 5,5 -k 6,6 -k 2 | column -ts,`
echo -e "\n${boop}\n $recs "
rm -f midway.txt
