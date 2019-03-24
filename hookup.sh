#!/bin/bash
if [[  "$1" == "n" ]];then
  echo "nodeconnectednodecount"
  curl --silent "https://1ml.com/node?order=nodeconnectednodecount&active=true&iponionservice=true" -o listofonionnodes.html
  cat listofonionnodes.html | pup 'strong[class="small selectable"]' text{} | sed 's/,//'>listofonionnodes.csv
elif [[ "$1" == "a" ]];then
  echo "all nodes in list"
  lncli describegraph > networkgraph.json 
  cat networkgraph.json | jq -r '[.nodes[]|select(.addresses[].addr|contains("onion"))|.pub_key]|unique|.[]' > listofonionnodes.csv
else 
  echo "capacity"
  curl --silent "https://1ml.com/node?order=capacity&active=true&iponionservice=true" -o listofonionnodes.html
  cat listofonionnodes.html | pup 'strong[class="small selectable"]' text{} | sed 's/,//'>listofonionnodes.csv
fi
  rm -Rf listofonionnodes.html