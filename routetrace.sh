#!/bin/bash
IFS=","
  rm -f routelist.csv
  if [[ -z $1 ]];then 	t1="0232e20e7b68b9b673fb25f48322b151a93186bffe4550045040673797ceca43cf"
    else t1=${1};  fi
  if [[ -z $2 ]];then  	t2="1000000"
    else t2=${2};  fi
  titletarget=`eval lncli getnodeinfo ${t1} |jq -r '.node.alias'`
lncli queryroutes --num_max_routes 15 ${t1} ${t2} |jq -r '.routes[]|[(.total_fees,.hops[].pub_key)]|join(",")' >> routelist.csv

while read -r fees  thisID  thisID2  thisID3  thisID4 thisID5 extradata ; do
  : $((recs++))
  title=`eval lncli getnodeinfo ${thisID} |jq -r '.node.alias'`
  key=`eval lncli getnodeinfo ${thisID} |jq -r '.node.pub_key'`
  title2=`eval lncli getnodeinfo ${thisID2} |jq -r '.node.alias'`
	ip=`eval lncli getnodeinfo ${thisID} |jq -r 'first(.node.addresses[].addr)'`
  ip2=`eval lncli getnodeinfo ${thisID2} |jq -r 'first(.node.addresses[].addr)'`
  color="001m"; if [[ $ip == *"n:"* ]];then color="113m"; fi
  color2="001m"; if [[ $ip2 == *"n:"* ]];then color2="113m"; fi
  if [[ ${thisID2} == $t1 ]];then color2="122m"; fi
          echo -e -n "$key | fee: $fees \e[38;5;$color  $title\e[0m   -> \e[38;5;$color2 $title2\e[0m  "

if [[ -n "$thisID3" ]];then 
  title3=`eval lncli getnodeinfo ${thisID3} |jq -r '.node.alias'`
  ip3=`eval lncli getnodeinfo ${thisID3} |jq -r 'first(.node.addresses[].addr)'`
  color3="001m"; if [[ $ip3 == *"n:"* ]];then color3="113m"; fi
  if [[ ${thisID3} == $t1 ]];then color3="122m"; fi
  echo -e -n "  -> \e[38;5;$color3 $title3\e[0m"
fi
if [[ -n "$thisID4" ]];then 
  title4=`eval lncli getnodeinfo ${thisID4} |jq -r '.node.alias'`
  ip4=`eval lncli getnodeinfo ${thisID4} |jq -r 'first(.node.addresses[].addr)'`
  color4="001m"; if [[ $ip4 == *"n:"* ]];then color4="114m"; fi
  if [[ ${thisID4} == $t1 ]];then color4="122m"; fi
  echo -e -n "  -> \e[38;5;$color4 $title4\e[0m"
fi
if [[ -n "$thisID5" ]];then 
  title5=`eval lncli getnodeinfo ${thisID5} |jq -r '.node.alias'`
  ip5=`eval lncli getnodeinfo ${thisID5} |jq -r 'first(.node.addresses[].addr)'`
  color5="001m"; if [[ $ip5 == *"n:"* ]];then color5="114m"; fi
  if [[ ${thisID5} == $t1 ]];then color5="122m"; fi
  echo -e -n "  -> \e[38;5;$color5 $title5\e[0m"
fi
echo 
done <routelist.csv
echo -e "$recs routes sending ${t2} satoshi to \e[38;5;122m$titletarget\e[0m"
