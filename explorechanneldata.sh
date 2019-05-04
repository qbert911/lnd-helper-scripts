#!/bin/bash
days=$((11))
mincap=$((2000000))
threshold="50000000"
myid=`eval lncli getinfo | jq -r '.identity_pubkey'`
height=`eval date +%s`
echo -e "\nGrabbing lightning network map : filtering using $days days, $threshold satoshi, $mincap capacity.\n"
lncli describegraph > networkgraph.json
cat networkgraph.json | jq -c '.edges[]|select(('${height}'-.last_update) < ('${days}'*86400))|select((.capacity|tonumber) >= '${mincap}')|[.node1_pub,.node2_pub]' > networkchannels.json
#------------------------------------------------------------------------------------------------
echo "$(wc -l networkchannels.json | sed -e 's/ .*//') Lively Channels with $mincap capacity seen in last ${days} days"
echo "$(cat networkgraph.json | jq -r '[[.edges[]|select(('${height}'-.last_update) < ('${days}'*86400))|select((.capacity|tonumber) >= '${mincap}')|select("'${myid}'" == .node1_pub or "'${myid}'" == .node2_pub)|.node1_pub,.node2_pub]|unique|.[]|select("'${myid}'" != .)]|length') Lively edges 1 hop away with $mincap capacity. Building 2hop list using nodes with $threshold satoshi :"
cat networkgraph.json | jq -r '[.edges[]|select(('${height}'-.last_update) < ('${days}'*86400))|select((.capacity|tonumber) >= '${mincap}')|select("'${myid}'" == .node1_pub or "'${myid}'" == .node2_pub)|.node1_pub,.node2_pub]|unique|.[]|select("'${myid}'" != .)' > n1hop.txt
echo "029e2a4faea100086a10c23d253ec4d5ae26d9015a8a7d756a17ecff4b923db923" >> n1hop.txt  #BubbleCoin.lol 
echo "0279c22ed7a068d10dc1a38ae66d2d6461e269226c60258c021b1ddcdfe4b00bc4" >> n1hop.txt  #ln1.satoshilabs.com 
echo "021607cfce19a4c5e7e6e738663dfafbbbac262e4ff76c2c9b30dbeefc35c00643" >> n1hop.txt  #ln.BitSoapBox.com
echo "0331f80652fb840239df8dc99205792bba2e559a05469915804c08420230e23c7c" >> n1hop.txt  #LightningPowerUsers.com 
#echo "030c3f19d742ca294a55c00376b3b355c3c90d61c6b6b39554dbc7ac19b141c14f" >> n1hop.txt  #Bitrefill.com
#echo "03c2abfa93eacec04721c019644584424aab2ba4dff3ac9bdab4e9c97007491dda" >> n1hop.txt  #tippin.me
#echo "02c69a0b4cb468660348d6d457d9212563ad08fb94d424395da6796fb74a13f276" >> n1hop.txt  #CreamPay
#echo "02bb24da3d0fb0793f4918c7599f973cc402f0912ec3fb530470f1fc08bdd6ecb5" >> n1hop.txt  #LNBIG.com [lnd-10]
sort -u -o n1hop.txt n1hop.txt
rm -f n2hop.txt nlively.txt
while read myid unused; do
  if [ "`eval lncli getnodeinfo ${myid} |jq -r '.total_capacity'`" -ge "$threshold" ];then
    echo -n "o"
    cat networkgraph.json | jq -r '[.edges[]|select(('${height}'-.last_update) < ('${days}'*86400))|select((.capacity|tonumber) >= '${mincap}')|select("'${myid}'" == .node1_pub or "'${myid}'" == .node2_pub)|.node1_pub,.node2_pub]|unique|.[]|select("'${myid}'" != .)' >> n2hop.txt
  else    echo -n ".";  fi
done < n1hop.txt  ; echo ;echo
sort -u -o n2hop.txt n2hop.txt
#------------------------------------------------------------------------------------------------
echo "$(cat networkgraph.json | jq -c '[.nodes[]|select(('${height}'-.last_update) < ('${days}'*86400)) ]|length') Lively Nodes seen in last ${days} days, filtering for nodes with $threshold satoshi :"
cat networkgraph.json | jq -r '.nodes[]|select(('${height}'-.last_update) < ('${days}'*86400))|.pub_key' > nxx.txt
while read myid unused; do
  if [ "`eval lncli getnodeinfo ${myid} |jq -r '.total_capacity'`" -ge "$threshold" ];then
    echo "$myid" >> nlively.txt
    echo -n "v"
  else   echo -n "_";  fi
done < nxx.txt
comm -23 nlively.txt n1hop.txt > nyy.txt
comm -23 nyy.txt n2hop.txt > ntargets3.txt
comm -23 nyy.txt ntargets3.txt > ntargets2.txt
echo -e "\n\nFound $(wc -l nlively.txt | sed -e 's/ .*//') Lively Nodes with $threshold satoshi"
echo -e "$(( $(wc -l nlively.txt | sed -e 's/ .*//') - $(wc -l nyy.txt | sed -e 's/ .*//') )) 1 hop, $(wc -l ntargets2.txt | sed -e 's/ .*//') Nodes 2 hops away, $(wc -l ntargets3.txt | sed -e 's/ .*//') Are beyond :"
eval "./xaminechanneldata.sh 3"
eval "./xaminechanneldata.sh 2"
