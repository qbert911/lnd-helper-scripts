#!/bin/bash
START=$(date +%s)
if [ "$1" == "1" ];then
  dispfile="n1hop.txt" ; echo -e "\n$(wc -l $dispfile | sed -e 's/ .*//') Nodes 1 hop away :"
elif [ "$1" == "3" ];then
  dispfile="ntargets3.txt" ; echo -e "\n$(wc -l $dispfile | sed -e 's/ .*//') Nodes 3+ hops away :"
else
 dispfile="ntargets2.txt" ; echo -e "\n$(wc -l $dispfile | sed -e 's/ .*//') Nodes 2 hops away :"
fi
while read -r thisID extradata; do
  cat networkchannels.json |grep ${thisID} |awk '{gsub("'${thisID}'", "");print}' |tr -d '[",]'|sort -u -o nxx.txt
  comm -12 ntargets2.txt nxx.txt > nyy.txt
  comm -12 ntargets3.txt nxx.txt > nzz.txt
  score="$(wc -l nxx.txt | sed -e 's/ .*//')"
  score2="$(wc -l nyy.txt | sed -e 's/ .*//')"
  score3="$(wc -l nzz.txt | sed -e 's/ .*//')"
  tempnodeinfo=`eval lncli getnodeinfo ${thisID} |jq -r '[(.num_channels|tostring),.total_capacity,.node.alias]|join(":")'| tr -d "<')(>&|," |tr -d '"´'|tr -dc [:print:][:cntrl:]` 
  channels=`eval echo ${tempnodeinfo} | cut -d":" -f 1`
  capa=`eval echo ${tempnodeinfo} | cut -d":" -f 2`
  title=`eval echo ${tempnodeinfo} | cut -d":" -f 3`
	echo -e "$channels,$(echo "scale=8; $capa / 100000000" | bc -ql ),$score,$score2,$score3,$(( $score2 + $score3 )),$title ,$thisID" >> midway.txt 
  echo -en "\e[38;5;229m⚡"
done <${dispfile}
header="channels,capacity,good Channels,2hop,3hop,2+3,name,key"
echo -e "\e[0m"
echo -e "${header}\n`cat midway.txt |sort -g -r --field-separator=',' -k 6,6 -k 5,5 -k 4,4 -k 3 `" | column -ts,  
echo -e "\e[0m \n $(( $(date +%s) - $START )) seconds ";rm -f midway.txt nxx.txt nyy.txt nzz.txt
