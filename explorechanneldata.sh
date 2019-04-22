#!/bin/bash
lncli describegraph > networkgraph.json
height=`eval date +%s`
days=$((3))
myid=`eval lncli getinfo | jq -r '.identity_pubkey'`

echo "$(cat networkgraph.json | jq -c '[.nodes[]|select(('${height}'-.last_update) > ('${days}'*86400)) ]|length') Zombie Nodes"
echo "$(cat networkgraph.json | jq -c '[.edges[]|select(('${height}'-.last_update) > ('${days}'*86400)) ]|length') Zombie Channels"
echo
echo "$(cat networkgraph.json | jq -c '[.nodes[]|select(('${height}'-.last_update) < ('${days}'*86400)) ]|length') Nodes seen in last ${days} days"
echo "$(cat networkgraph.json | jq -c '[.edges[]|select(('${height}'-.last_update) < ('${days}'*86400)) ]|length') Lively Channels seen in last ${days} days"
cat networkgraph.json | jq -r '.nodes[]|select(('${height}'-.last_update) < ('${days}'*86400))|.pub_key' > nlively.txt
echo
echo "$(cat networkgraph.json | jq -r '[[.edges[]|select(('${height}'-.last_update) < ('${days}'*86400))|select("'${myid}'" == .node1_pub or "'${myid}'" == .node2_pub)|.node1_pub,.node2_pub]|unique|.[]|select("'${myid}'" != .)]|length') Lively Nodes with Channels 1 hop away"
cat networkgraph.json | jq -r '[.edges[]|select(('${height}'-.last_update) < ('${days}'*86400))|select("'${myid}'" == .node1_pub or "'${myid}'" == .node2_pub)|.node1_pub,.node2_pub]|unique|.[]|select("'${myid}'" != .)' > n1hop.txt

rm -f n2hop.txt
while read myid unused; do
  echo -n "$(cat networkgraph.json | jq -r '[[.edges[]|select(('${height}'-.last_update) < ('${days}'*86400))|select("'${myid}'" == .node1_pub or "'${myid}'" == .node2_pub)|.node1_pub,.node2_pub]|unique|.[]|select("'${myid}'" != .)]|length') "
  cat networkgraph.json | jq -r '[.edges[]|select(('${height}'-.last_update) < ('${days}'*86400))|select("'${myid}'" == .node1_pub or "'${myid}'" == .node2_pub)|.node1_pub,.node2_pub]|unique|.[]|select("'${myid}'" != .)' >> n2hop.txt
done < n1hop.txt
echo
echo -e "\n$(wc -l n2hop.txt | sed -e 's/ .*//') Total 2 hop Channels "
sort -u -o n2hop.txt n2hop.txt
echo "$(wc -l n2hop.txt | sed -e 's/ .*//') Unique 2 hop Channels "
echo
my2hops=`eval cat n2hop.txt`
rm -f ntargets.txt
while read myid unused; do
  if [[ $my2hops == *$myid* ]];then
  : $((recy++))
else
  : $((recn++))
  echo "$myid" >> ntargets.txt
fi    
done < nlively.txt
echo
echo "$recy Nodes 2 hops away, $recn Are beyond"

threshold="20000000"
while read -r thisID extradata; do
  : $((recs++))
  capa=`eval lncli getnodeinfo ${thisID} |jq -r '.total_capacity'`
  min=$(echo "$capa" "$threshold" | awk '{if ($1 > $2) print "1"; else print "0"}')
if (( $min == "1" ));then
  title=`eval lncli getnodeinfo ${thisID} |jq -r '.node.alias'`
  ip=`eval lncli getnodeinfo ${thisID} |jq -r '.node.addresses[].addr'`
  channels=`eval lncli getnodeinfo ${thisID} |jq -r '.num_channels'`
		                                      status="non";color="007m";thisIDd=$thisID
		if [[ $ip == *"n:"* ]];then           status="target";color="122m";thisIDd=$thisID; fi
		if [[ $ip == *":"*":"* ]];then        status="mixed";color="007m";thisIDd=$thisID; fi
    if [[ $ip == *"n:"*"n:"* ]];then      status="multi";color="062m";thisIDd=$thisID; fi
    if [[ $ip == *":"*":"*":"* ]];then    status="mixed2";color="007m";thisIDd=$thisID; fi
    if [[ $blacklist == *$thisID* ]];then status="BLACKLIST";color="001m";thisIDd=""; fi
  case "$status" in
    "mixed" | "mixed2" | "BLACKLIST" | "non")    : $((recstb++))       ;;
    "target" | "multi")                         : $((recstg++))        ;;
  esac  
	echo -e "\e[38;5;$color , $channels,$(echo "scale=8; $capa / 100000000" | bc -ql ),"$title",$status,$thisIDd \e[0m" >> midway.txt
else
  : $((recssm++))        
fi
  echo -n "."
done <ntargets.txt
	boop=`cat midway.txt |sort -g -r --field-separator=',' -k 2,2 -k 3 | column -ts,`
	echo -e "\n${boop}\n$recssm nodes under threshold\n $(( $recs - $recssm )) nodes over threshold of $threshold satoshi :   \e[38;5;122m$recstg onion    \e[38;5;007m$recstb non-onion\n "
rm -f midway.txt
