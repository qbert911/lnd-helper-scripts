#!/bin/bash
IFS=","
myid=`eval lncli getinfo | jq -r '.identity_pubkey'`
mytitle="My fees:  "    #`eval lncli getnodeinfo ${myid} |jq -r '.node.alias'`
lncli listchannels | jq -r '.channels[]|[.chan_id,.total_satoshis_received,.total_satoshis_sent]|join(",")' > nchannelfees.txt
while read -r thischanID tsr tss extradata; do
  : $((recs++))
  lncli getchaninfo ${thischanID} > tempchandata.json
  thisID=`cat tempchandata.json  |jq -r '.node1_pub'`
  thisID2=`cat tempchandata.json  |jq -r '.node2_pub'`
  chanfees1a=`cat tempchandata.json  |jq -r '.node1_policy.fee_base_msat|tonumber'`
  chanfees1b=`cat tempchandata.json  |jq -r '.node1_policy.fee_rate_milli_msat|tonumber'`
if [ "`cat tempchandata.json  |jq -r '.node2_policy'`" != "null" ];then
  chanfees2a=`cat tempchandata.json  |jq -r '.node2_policy.fee_base_msat|tonumber'`
  chanfees2b=`cat tempchandata.json  |jq -r '.node2_policy.fee_rate_milli_msat|tonumber'`
else chanfees2a=-999;chanfees2b=-999;fi  
    ini="0"
  if [[ $thisID2 == $myid ]];then 
    thisID2=$thisID;    thisID=$myid
    idt=$chanfees2a;    chanfees2a=$chanfees1a;    chanfees1a=$idt
    idt=$chanfees2b;    chanfees2b=$chanfees1b;    chanfees1b=$idt
    tst=$tsr;           tsr=$tss;                  tss=$tst
    ini="1"
  fi
  title2=`eval lncli getnodeinfo ${thisID2} |jq -r '.node.alias'`
  chan2=`eval lncli getnodeinfo ${thisID2} |jq -r '.num_channels'`
  cap2=`eval lncli getnodeinfo ${thisID2} |jq -r '.total_capacity'`

  if   [ "$chanfees2a" -gt 1000 ]; then color2a="022m"
  elif [ "$chanfees2a" -eq 1000 ]; then color2a="007m"
  elif [ "$chanfees2a" -gt 499 ]; then color2a="196m"
  elif [ "$chanfees2a" -gt 99 ]; then color2a="124m"
  elif [ "$chanfees2a" -gt 49 ]; then color2a="130m"
  elif [ "$chanfees2a" -gt 9 ]; then color2a="058m"
  elif [ "$chanfees2a" -gt 0 ]; then color2a="001m"
  elif [ "$chanfees2a" -eq 0 ]; then color2a="001m"
  else  color2a="014m" ; fi
  if   [ "$chanfees2b" -gt 499 ]; then color2b="001m"
  elif [ "$chanfees2b" -gt 99 ]; then color2b="196m"
  elif [ "$chanfees2b" -gt 49 ]; then color2b="124m"
  elif [ "$chanfees2b" -gt 19 ]; then color2b="130m"
  elif [ "$chanfees2b" -gt 9 ]; then color2b="058m"
  elif [ "$chanfees2b" -gt 1 ]; then color2b="113m"
  else color2b="007m" ;  fi
  echo -n "."
  echo  "${thischanID}  |,$mytitle,$chanfees1a,$chanfees1b,<-->,\e[38;5;$color2a,$chanfees2a,\e[38;5;$color2b,$chanfees2b\e[0m,$title2,$ini,$chan2,$cap2,$tsr,$tss"  >> midway.txt
done <nchannelfees.txt
boop=`cat midway.txt |sort -g -r --field-separator=',' -k 11,11 -k 7,7 -k 9,9 -k 13 | column -ts,`
echo -e -n "\n${boop}\n $recs channels    msats earned in fees: "
rm -f midway.txt tempchandata.json nchannelfees.txt
lncli fwdinghistory --start_time 5000 --end_time 50000000000000000|jq -r '[.forwarding_events[]|(.fee_msat|tonumber)]|add'