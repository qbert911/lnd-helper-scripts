#!/bin/bash
days=$((14))
mincap=$((2000000))
minchans=$((8))
threshold=$((50000000))
myid=`eval lncli getinfo | jq -r '.identity_pubkey'`
height=`eval date +%s`
START=$(date +%s)
echo -e "\nGrabbing lightning network map : filtering using \e[38;5;45m$days\e[0m days, \e[38;5;173m$(echo "scale=8;($threshold / 100000000)" | bc | sed 's/[0]*$//g' )\e[0m btc, and at least \e[38;5;45m$minchans\e[0m channels having at least \e[38;5;173m$(echo "scale=8;($mincap / 100000000)" | bc | sed 's/[0]*$//g' )\e[0m capacity.\n"
lncli describegraph > networkgraph.json
cat networkgraph.json | jq -c '.edges[]|select(('${height}'-.last_update) < ('${days}'*86400))|select((.capacity|tonumber) >= '${mincap}')|[.node1_pub,.node2_pub]' > networkchannels.json
#------------------------------------------------------------------------------------------------
echo -e "$(wc -l networkchannels.json | sed -e 's/ .*//') Lively Channels with \e[38;5;173m$(echo "scale=8;($mincap / 100000000)" | bc | sed 's/[0]*$//g' )\e[0m capacity seen in last \e[38;5;45m$days\e[0m days days"
echo -e "$(cat networkgraph.json | jq -r '[[.edges[]|select(('${height}'-.last_update) < ('${days}'*86400))|select((.capacity|tonumber) >= '${mincap}')|select("'${myid}'" == .node1_pub or "'${myid}'" == .node2_pub)|.node1_pub,.node2_pub]|unique|.[]|select("'${myid}'" != .)]|length') Lively edges 1 hop away with at least \e[38;5;173m$(echo "scale=8;($mincap / 100000000)" | bc | sed 's/[0]*$//g' )\e[0m capacity. Building 2hop list using nodes with \e[38;5;173m$(echo "scale=8;($threshold / 100000000)" | bc | sed 's/[0]*$//g' )\e[0m btc :"
#cat networkgraph.json | jq -r '[.edges[]|select(('${height}'-.last_update) < ('${days}'*86400))|select((.capacity|tonumber) >= '${mincap}')|select("'${myid}'" == .node1_pub or "'${myid}'" == .node2_pub)|.node1_pub,.node2_pub]|unique|.[]|select("'${myid}'" != .)' > n1hop.txt
lncli listchannels | jq -r '[.channels[]|select((.capacity|tonumber) >= '${mincap}')|.remote_pubkey]|unique|.[]' > n1hop.txt
#echo "02c69a0b4cb468660348d6d457d9212563ad08fb94d424395da6796fb74a13f276" >> n1hop.txt  #CreamPay
sort -u -o n1hop.txt n1hop.txt
echo -e "$(wc -l n1hop.txt | sed -e 's/ .*//') Nodes"
echo -e "\e[38;5;229m $(( $(date +%s) - $START )) \e[0mseconds "
START=$(date +%s)
rm -f n2hop.txt nlively.txt
while read myid unused; do
  tempnodeinfo=`eval lncli getnodeinfo ${myid} |jq -r '[(.num_channels|tostring),.total_capacity,.node.alias]|join(":")'| tr -d "<')(>&|," |tr -d '"´'|tr -dc [:print:][:cntrl:]` 
  channels=`eval echo ${tempnodeinfo} | cut -d":" -f 1`
  capa=`eval echo ${tempnodeinfo} | cut -d":" -f 2`
  title=`eval echo ${tempnodeinfo} | cut -d":" -f 3`
  if [ "$capa" -ge "$threshold" ];then
    #echo -ne "\e[38;5;229m⚡\e[0m"
    echo -e "$(echo "scale=8; $capa / 100000000" | bc -ql ),$channels,$title "| column -ts,   
    cat networkgraph.json | jq -r '[.edges[]|select(('${height}'-.last_update) < ('${days}'*86400))|select((.capacity|tonumber) >= '${mincap}')|select("'${myid}'" == .node1_pub or "'${myid}'" == .node2_pub)|.node1_pub,.node2_pub]|unique|.[]|select("'${myid}'" != .)' >> n2hop.txt &
  else    echo -e "\e[38;5;246m($(echo "scale=8; $capa / 100000000" | bc -ql )),$channels,$title\e[0m "| column -ts,;  fi
done < n1hop.txt  ; echo ;echo;wait
sort -u -o n2hop.txt n2hop.txt
echo -e "\e[38;5;229m $(( $(date +%s) - $START )) \e[0mseconds "
START=$(date +%s)
#------------------------------------------------------------------------------------------------
echo -e "$(cat networkgraph.json | jq -c '[.nodes[]|select(('${height}'-.last_update) < ('${days}'*86400)) ]|length') Lively Nodes seen in last \e[38;5;45m$days\e[0m days, filtering for nodes with \e[38;5;173m$(echo "scale=8;($threshold / 100000000)" | bc | sed 's/[0]*$//g' )\e[0m btc and at least \e[38;5;45m$minchans\e[0m channels :"
cat networkgraph.json | jq -r '.nodes[]|select(('${height}'-.last_update) < ('${days}'*86400))|.pub_key' > nxx.txt
while read myid unused; do
  cat networkchannels.json |grep ${myid} |awk '{gsub("'${myid}'", "");print}' |tr -d '[",]'|sort -u -o nzz.txt
  score="$(wc -l nzz.txt | sed -e 's/ .*//')"
  if [ "$score" -lt "$minchans" ];then  echo -ne "\e[38;5;238m$score"
  elif [ "`eval lncli getnodeinfo ${myid} |jq -r '.total_capacity'`" -ge "$threshold" ];then
    echo "$myid" >> nlively.txt
    echo -ne "\e[38;5;083m⚡"
  else   echo -ne "\e[38;5;052m⚡";  fi
done < nxx.txt
comm -23 nlively.txt n1hop.txt > nyy.txt
comm -23 nyy.txt n2hop.txt > ntargets3.txt
comm -23 nyy.txt ntargets3.txt > ntargets2.txt
echo -e "\e[0m\n\nFound $(wc -l nlively.txt | sed -e 's/ .*//') Lively Nodes with \e[38;5;173m$(echo "scale=8;($threshold / 100000000)" | bc | sed 's/[0]*$//g' )\e[0m btc"
echo -e "$(( $(wc -l nlively.txt | sed -e 's/ .*//') - $(wc -l nyy.txt | sed -e 's/ .*//') )) 1 hop, $(wc -l ntargets2.txt | sed -e 's/ .*//') Nodes 2 hops away, $(wc -l ntargets3.txt | sed -e 's/ .*//') Are beyond :"
echo -e "\e[38;5;229m $(( $(date +%s) - $START )) \e[0mseconds "
eval "./xaminechanneldata.sh 3" 
#eval "./xaminechanneldata.sh 2"
