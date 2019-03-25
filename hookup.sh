#!/bin/bash
if [[  "$1" == "n" ]];then
  echo "nodeconnectednodecount"
  curl --silent "https://1ml.com/node?order=nodeconnectednodecount&active=true&iponionservice=true" -o listofonionnodes.html
  cat listofonionnodes.html | pup 'strong[class="small selectable"]' text{} | sed 's/,//'>listofonionnodes.txt
else [[ "$1" == "c" ]];then
  echo "capacity"
  curl --silent "https://1ml.com/node?order=capacity&active=true&iponionservice=true" -o listofonionnodes.html
  cat listofonionnodes.html | pup 'strong[class="small selectable"]' text{} | sed 's/,//'>listofonionnodes.txt
fi
  rm -Rf listofonionnodes.html