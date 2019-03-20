#!/bin/bash
PS1=$
PROMPT_COMMAND=
echo -en "\033]0;Watcher\a"

IFS=","
while : ;do
  eval lncli listchannels > rawout.txt
  cat rawout.txt | jq -r '.channels[] | [.remote_pubkey,.capacity,.local_balance,.remote_balance,(.active|tostring),(.initiator|tostring),.commit_fee,.commit_weight,.fee_per_kw] | join("," )' > nodelist.txt
  eval lncli pendingchannels > rawoutp.txt
  cat rawoutp.txt | jq -r '.pending_open_channels[]|[.channel.remote_node_pub,.channel.capacity,.channel.local_balance,.channel.remote_balance,"pendo","true",.commit_fee] | join("," )' >> nodelist.txt
  cat rawoutp.txt | jq -r '.waiting_close_channels[]|[.channel.remote_node_pub,.channel.capacity,.channel.local_balance,.channel.remote_balance,"pend c","true","0"] | join("," )' >> nodelist.txt
  cat rawoutp.txt | jq -r '.pending_closing_channels[]|[.channel.remote_node_pub,.channel.capacity,.channel.local_balance,.channel.remote_balance,"pend c","true","0"] | join("," )' >> nodelist.txt
  cat rawoutp.txt | jq -r '.pending_force_closing_channels[]|[.channel.remote_node_pub,.channel.capacity,.channel.local_balance,.channel.remote_balance,"pend c","true","0"] | join("," )' >> nodelist.txt
  height=`eval lncli getinfo |jq -r '.block_height'`
  reco=`cat rawout.txt | jq -s '[.[].channels[]|select(.initiator==true) | "1"|tonumber]|add'`
  reci=`cat rawout.txt | jq -s '[.[].channels[]|select(.initiator==false) | "1"|tonumber]|add'`
  unset_balanceo=`cat rawout.txt | jq -s '[.[].channels[]|select(.initiator==true) |.unsettled_balance|tonumber]|add'`
  unset_balancei=`cat rawout.txt | jq -s '[.[].channels[]|select(.initiator==false) | .unsettled_balance|tonumber]|add'`
  unset_times=`cat rawout.txt | jq -r -s '[.[].channels[].pending_htlcs[].expiration_height|select(length > 0)-'${height}'|tostring]|join(",")'`
  mybalance=`cat rawout.txt | jq -s '[.[].channels[].local_balance|tonumber]|add'`
  cap_balance=`cat rawout.txt | jq -s '[.[].channels[].remote_balance|tonumber]|add'`
  commitfees=`cat rawout.txt | jq -s '[.[].channels[]|select(.initiator==true) | .commit_fee|tonumber]|add'`
  ocommitfees=`cat rawout.txt | jq -s '[.[].channels[]|select(.initiator==false) | .commit_fee|tonumber]|add'`
  mybalc=$(( ${mybalance} + ${commitfees} ))
  incc=$(( ${cap_balance} + ${ocommitfees} )) 
  walletbal=`eval lncli walletbalance |jq -r '.total_balance'`
	unc=`eval lncli walletbalance |jq -r '.unconfirmed_balance'`
  income=`eval lncli feereport | jq -r '.month_fee_sum'`
  recs=$((-1))  #so we don't count self
  eval lncli getinfo | jq -r '[.identity_pubkey,"","'${mybalc}'","'${incc}'","--me--"," "," "," "," "]| join("," )' >> nodelist.txt  #add own node to list
  #--------------combiner-------------------------------------------------------
  rm -f combined.txt
  sort nodelist.txt -o nodelist.txt
  while read -r thisID capacity balance incoming cstate init cf cw fpk && read -r thatID title thiscapacity thisconnectedcount avgchancap thisbiggestchan age color city state country junk <&3; do
    : $((recs++))
    if [ "$thisID" = "$thatID" ];then
#--------------processing  	
    if [ "$init"   = "true" ];then balance=$(( $balance + $cf ))
	elif [ "$init"   = "false" ];then incoming=$(( $incoming + $cf ));fi

	if [ "$balance"   = "0" ];then balance="";fi
	if [ "$incoming"   = "0" ];then incoming="";fi

  if [[ -n "$incoming" ]];then incoming="          ${incoming}";incomingA="${incoming:(-9):3}";incomingB="${incoming:(-6):3}";incomingC="${incoming:(-3):3}";incoming="${incomingA// /} ${incomingB// /} ${incomingC// /}";incoming="${incoming/  /}";fi
  incoming="'\e[38;5;232m'...........'\e[0m'${incoming}";incoming="${incoming:0:14}${incoming: -17}"
  if [[ -n "$balance" ]];then abalance="           ${balance}";balanceA="${abalance:(-9):3}";balanceB="${abalance:(-6):3}";balanceC="${abalance:(-3):3}";balance="${balanceA// /} ${balanceB// /} ${balanceC// /}";balance="${balance/  /}";fi
  balance="'\e[38;5;232m'___________'\e[0m'${balance}";balance="${balance:0:14}${balance: -17}"

  title=`eval lncli getnodeinfo ${thisID} |jq -r '.node.alias'| tr -d "<')(>"`
  ipexam=`eval lncli getnodeinfo ${thisID} |jq -r '.node.addresses[].addr'`
  ipstatus="-ip4-";ipcolor="001m"
  if [[ $ipexam == *"n:"* ]];then ipstatus="onion";ipcolor="122m";fi
  if [[ $ipexam == *":"*":"* ]];then ipstatus="mixed";ipcolor="111m";fi
	if   [ "$state"   = "" ];then country=$city ;              city=""
	elif [ "$country" = "" ];then country=$state; state=$city; city="";fi
#--------------processing 
      OUTPUTME=`eval echo "'\e[38;5;$color'${thisID:0:2}'\e[0m'${thisID:2:7},$balance,$incoming,"$title",'\e[38;5;$ipcolor' $ipstatus'\e[0m',${cstate:0:8},$init,$thisconnectedcount,${thiscapacity:0:6},${avgchancap:0:6},${thisbiggestchan:0:6},$age,${city:0:13},${state:0:5},${country:0:6},$cf"`   #,$cw,$fpk
    else
      OUTPUTME=`eval echo "'\e[38;5;$color'${thisID:0:2}'\e[0m'${thisID:2:7},$balance,$incoming,MISMATCHingWebdata,${cstate:0:8},$init',- ,- ,- ,- ,- ,- ,- ,- ,-'"`
      echo -e "${OUTPUTME}\a" >> mismatch.txt
    fi
    echo "${OUTPUTME}" >> combined.txt
  done <nodelist.txt 3<webdata.txt
  #--------------combiner-------------------------------------------------------
  data_table=`cat combined.txt|sort --field-separator=',' -k 7,7 -k 5,5 -k 4`
  echo -e "${data_table}" > myout.txt
  OUTPUTME=`cat combined-header. myout.txt| column -n -ts,`
  clear

if [[ -n "$mybalc" ]];then mybalc="          ${mybalc}";mybalcA="${mybalc:(-9):3}";mybalcB="${mybalc:(-6):3}";mybalcC="${mybalc:(-3):3}";mybalc="${mybalcA// /} ${mybalcB// /} ${mybalcC// /}";mybalc="${mybalc/  /}";fi
if [[ -n "$incc" ]];then incc="          ${incc}";inccA="${incc:(-9):3}";inccB="${incc:(-6):3}";inccC="${incc:(-3):3}";incc="${inccA// /} ${inccB// /} ${inccC// /}";incc="${incc/  /}";fi

if [[ -n "$walletbal" ]];then walletbal="             ${walletbal}";walletbalA="${walletbal:(-9):3}";walletbalB="${walletbal:(-6):3}";walletbalC="${walletbal:(-3):3}";walletbal="${walletbalA// /} ${walletbalB// /} ${walletbalC// /}";walletbal="${walletbal/  /}";fi


echo -e "${OUTPUTME} \n\nChans: \e[38;5;45m${recs}\e[0m ${reco}/${reci}  \e[38;5;157m${mybalc} \e[0m \e[38;5;183m ${incc}\e[0m \e[38;5;113m ${walletbal}\e[0m in wallet (${unc} unconfirmed) (${unset_balanceo} / ${unset_balancei} unsettled ${unset_times})	Income: \e[38;5;83m${income}\e[0m"
  secsi=$((7));while [ $secsi -gt -1 ]; do echo -ne "$secsi\033[0K\r";sleep 1; : $((secsi--));done   #countdown
done
