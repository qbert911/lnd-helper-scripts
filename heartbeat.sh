#!/bin/bash
tblok=$(curl -s --user bongos:goobers --data-binary '{"method": "getblockchaininfo", "params": [] }' http://192.168.1.26:8332/ | jq '.result.blocks')
nmempool=$(curl -s --user bongos:goobers --data-binary '{"method": "getmempoolinfo", "params": [] }' http://192.168.1.26:8332/ | jq '.result.size')
maxbarlen=$((120)) 
while : ;do
  START=$(date +%s)
  oldblok=$tblok
  while [[ "$tblok" = "$oldblok" ]]; do
    mempool=$(curl -s --user bongos:goobers --data-binary '{"method": "getmempoolinfo", "params": [] }' http://192.168.1.26:8332/ | jq '.result.size')
    RUNTIME=$(( $(date +%s) - $START ))
    case "$((RUNTIME/60%60/10))$((RUNTIME/60%10))" in
     (0[0-7])      cola="\e[38;5;070m";colb="\e[38;5;229m";;
     (1[2-9])      cola="\e[38;5;229m";colb="\e[38;5;094m";;
     ([2-9][0-9])  cola="\e[38;5;088m";colb="\e[38;5;088m";;
     ( *	)        cola="\e[38;5;229m";colb="\e[38;5;229m";;
    esac 
    out="\033[1K\r\e[?25l$(( $tblok + 1 )) \e[38;5;229m$(printf "$cola%01d$colb%01d\e[38;5;229m:%02d" $((RUNTIME/60%100/10)) $((RUNTIME/60%10)) $((RUNTIME%60)))\e[0m $(printf "%05d" $mempool) "
    nscale=$(( (($mempool/10000)+1)*(10000/$maxbarlen) ))
    if [ "$nscale" != "$scale" ];then
      scale=$nscale
      oldbarlen=$(( $nmempool / $scale ))
    fi
    currbarlen=$(( $mempool / $scale )) 
    scalevel=$(( ($mempool/10000)+1 ))
    for (( c=1; c<=$(( $oldbarlen )); c++ )); do 
      if   [[ "$scalevel" = "1" ]] || [ "$c" -lt "$((1*$maxbarlen/$scalevel))" ];then
        mychar="-";myblank=" ";       if [[ "$scalevel" -gt "1" ]];then mychar="—";myblank='.';fi
      elif [[ "$scalevel" = "2" ]] || [ "$c" -lt "$((2*$maxbarlen/$scalevel))" ]; then
        mychar="=";myblank='.' 
      elif [[ "$scalevel" = "3" ]] || [ "$c" -lt "$((3*$maxbarlen/$scalevel))" ]; then
        mychar="≡";                   if [[ "$scalevel" -gt "4" ]];then myblank='…';fi
      elif [[ "$scalevel" = "4" ]] || [ "$c" -lt "$((4*$maxbarlen/$scalevel))" ]; then
        mychar="‡" 
      elif [[ "$scalevel" = "5" ]] || [ "$c" -lt "$((5*$maxbarlen/$scalevel))" ]; then
        mychar="5" 
      elif [[ "$scalevel" = "6" ]] || [ "$c" -lt "$((6*$maxbarlen/$scalevel))" ]; then
        mychar="6" 
      elif [[ "$scalevel" = "7" ]] || [ "$c" -lt "$((7*$maxbarlen/$scalevel))" ]; then
        mychar="7" 
      elif [[ "$scalevel" = "8" ]] || [ "$c" -lt "$((8*$maxbarlen/$scalevel))" ]; then
        mychar="8" 
      elif [[ "$scalevel" = "9" ]] || [ "$c" -lt "$((9*$maxbarlen/$scalevel))" ]; then
        mychar="9" 
      else 
        mychar="z";myblank='…'
      fi
      out+=$mychar
    done
    for (( c=1; c<=$(( $currbarlen - $oldbarlen )); c++ )); do out+="#";done
    for (( c=1; c<=$(( $maxbarlen - $currbarlen )); c++ )); do 
      if [ "$(( ($c + $currbarlen) % ($maxbarlen / 10 / $scalevel ) ))" == "0" ];then out+="+";else out+=${myblank}; fi;  done
    if [[ "$((RUNTIME%60%10))" -eq "0" ]];then
      usdprice=$(curl -s "https://min-api.cryptocompare.com/data/price?fsym=BTC&tsyms=USD&api_key=5dded183e815cb37c820616548b1985591285aa786c8367ba955887eb57aec5f"|jq -r ".USD")
    fi
    echo -en "${out} \$$usdprice"
    sleep 1
    tblok=$(curl -s --user bongos:goobers --data-binary '{"method":"getblockchaininfo","params":[]}' http://192.168.1.26:8332/ | jq '.result.blocks')
  done 
#------------------------------------------------------------------------------
  nmempool=$(curl -s --user bongos:goobers --data-binary '{"method": "getmempoolinfo", "params": [] }' http://192.168.1.26:8332/ | jq '.result.size')
#  while [ "$mempool" -lt "$nmempool" ] && [ "$RUNTIME" -gt "10" ]; do 
#    sleep 1;aplay -q sms2.wav;  aplay -q sms2.wav;  aplay -q sms2.wav
#    nmempool=$(curl -s --user bongos:goobers --data-binary '{"method": "getmempoolinfo", "params": [] }' http://192.168.1.26:8332/ | jq '.result.size')
#  done
  oldbarlen=$(( $nmempool / $scale ))
  txsinblock=$(( $currbarlen - $oldbarlen ))
  bakedin=$(( $mempool - $nmempool ))
  echo -en "\033[1K\r\e[?25l${out:0:$(( ${#out} - $txsinblock - $(( $maxbarlen - $currbarlen )) ))}" 
  case "${bakedin}" in
    ([5-9][0-9][0-9][0-9])  echo -en "\e[38;5;163m";;
    (4[5-9][0-9][0-9])      echo -en "\e[38;5;076m";;
    (4[0-4][0-9][0-9])      echo -en "\e[38;5;114m";;
    (3[5-9][0-9][0-9])      echo -en "\e[38;5;070m";;
    (3[0-4][0-9][0-9])      echo -en "\e[38;5;064m";;
    (2[5-9][0-9][0-9])      echo -en "\e[38;5;106m";;
    (2[0-4][0-9][0-9])      echo -en "\e[38;5;100m";;
    (1[5-9][0-9][0-9])      echo -en "\e[38;5;058m";;
    (1[0-4][0-9][0-9])      echo -en "\e[38;5;094m";;
     ([5-9][0-9][0-9])      echo -en "\e[38;5;088m";;
    ( *	)                   echo -en "\e[38;5;052m";;
  esac 
  for (( c=1; c<=$(( $txsinblock )); c++ )); do echo -n "O";done
  echo -en "\e[0m"
  for (( c=1; c<=$(( $maxbarlen - $currbarlen )); c++ )); do 
    if [ "$(( ($c + $currbarlen) % ( $maxbarlen / 10 / $scalevel ) ))" == "0" ];then echo -n "+";else echo -n "${myblank}"; fi;  done
  echo -e "\e[0m  $(printf "%04d" ${bakedin}) tx ($mempool - $nmempool)"
  if [ -f "sms2.wav" ]; then aplay -q sms2.wav ; fi
done
