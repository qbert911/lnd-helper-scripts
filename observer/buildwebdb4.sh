#!/bin/bash
PS1=$
PROMPT_COMMAND=
echo -en "\033]0;Web Data Fetcher\a"
IFS=","
#display=true
mkdir -p pages;rm -f nodelist-temp.txt webdatanew.txt
while : ;do
  cp nodelist.txt nodelist-temp.txt
  myrecs=$(wc -l nodelist-temp.txt | sed -e 's/ .*//')
  if [ "$myrecs" = 0 ];then sleep 1; continue; fi  #make sure list is not empty
#-----------------
dirty=false
while read thisID f2 f3 f4 f5; do
    if ! test -f "pages/$thisID.html" || test "`find pages/$thisID.html -mmin +30`" || test -f "mismatch.txt" || ! test -f "webdata.txt" ;then  #freshness check
      dirty=true;fi
done < nodelist-temp.txt
if [ "$dirty" = true ];then
  echo "Downloading data for $myrecs nodes: "`date`
  echo -ne "[-----------+-----------+-----------+-----------+----------50%----------+-----------+-----------+-----------+------------]\033[121D"
  barlen=$(( 120 )) #DO MORE
  for (( c=1; c<=$(( $barlen - ( $(( $barlen  / $myrecs )) * $myrecs ) )); c++ )); do echo -ne "=";done        #fill in gap bars segments
  while read thisID f2 f3 f4 f5; do
      if ! test -f "pages/$thisID.html" || test "`find pages/$thisID.html -mmin +30`";then  #freshness check
        eval curl -s https://1ml.com/node/$thisID/channels?order=capacity -o pages/$thisID.html
        for (( c=1; c<=$(( $barlen  / $myrecs / 2 )); c++ )); do echo -n -e "\e[38;5;54m=\e[0m";done          #draw bar segment
      else
        for (( c=1; c<=$(( $barlen  / $myrecs / 2 )); c++ )); do echo -n -e "\e[38;5;235m=\e[0m";done          #draw bar segment
      fi #download html
      if eval head -n 200 "pages/$thisID.html" | grep -q 'globe';then
        thisgeodata=`eval head -n 200 pages/$thisID.html|grep -A4 "globe"|pup a,li text{}| tr '\n' ','`
      else thisgeodata=" ,--,--,";fi
        hex=`eval head -n 200 pages/$thisID.html| grep -A1 '<h5>Color</h5>' | pup span text{} | jq -r -R '.[1:7]'`
        r=$(printf '0x%0.2s' "$hex"); g=$(printf '0x%0.2s' ${hex#??}); b=$(printf '0x%0.2s' ${hex#????})  #hex to anso color conversion
      thiscolor=$(echo -e `printf "%03d" "$(((r<75?0:(r-35)/40)*6*6+(g<75?0:(g-35)/40)*6+(b<75?0:(b-35)/40)+16))"`)"m"
      thisnode=`eval head -n 200 pages/$thisID.html|grep     "<h1>Node" |pup h1 text{}| tr -d '()'`
      thiscapacity=`eval head -n 200 pages/$thisID.html|grep -A1 "<h5>Capacity" |pup span text{}`
      thisconnectedcount=`eval head -n 200 pages/$thisID.html|grep -A1 "<h5>Connected Node Count</h5>" |pup span text{}| sed 's/,//'`
      thisage=`eval head -n 300 pages/$thisID.html| grep -A1 '<h5>Age</h5>' | pup span text{}`
      avgchancap=`eval cat pages/$thisID.html| grep -A1 '<h5 class="inline">Capacity</h5>'| pup span text{} | jq -r -R '.[0:-4]' | jq -s add/length`
      thisbiggestchan=`eval cat pages/$thisID.html| grep -A1 '<h5 class="inline">Capacity</h5>'| pup span text{} | jq -r -R '.[0:-4]' | jq -s max`
      eval echo "${thisID},${thisnode:15:80},${thiscapacity:0:-4},${thisconnectedcount},${avgchancap},${thisbiggestchan},${thisage},${thiscolor},${thisgeodata:0:-1}" >> webdatanew.txt  #write line to file
      for (( c=1; c<=$(( ( $barlen  / $myrecs ) - $(( $barlen  / $myrecs / 2 )) )); c++ )); do echo -ne "\e[38;5;99m=\e[0m";done     #draw bar segment
  done < nodelist-temp.txt
  echo ""
  if [ "$display" = true ];then echo -e `eval cat webdatanew.txt|sort --field-separator=',' -k1 -k7 -k6 -k2| column -ts,`;fi
  sort webdatanew.txt -o webdata.txt
  rm -f webdatanew.txt mismatch.txt
fi   #clean
  rm -f nodelist-temp.txt
  secso=$((3));while [ $secso -gt -1 ]; do    #----------------countdown
  secsi=$((59));while [ $secsi -gt -1 ]; do echo -ne "$secso:$secsi\033[0K\r";! test -f "mismatch.txt" || break;sleep 1;: $((secsi--));done; : $((secso--));done
done
