#!/bin/bash
curl --silent "https://1ml.com/node?order=nodeconnectednodecount&active=true&iponionservice=true" -o listofonionnodes.html

cat listofonionnodes.html | pup 'h2' text{} | sed 's/,//' >h2.tmp
cat listofonionnodes.html | pup 'strong[class="small selectable"]' text{} | sed 's/,//'>h1.tmp
cat listofonionnodes.html | pup 'ul[class="list-unstyled list-inline"] li:last-of-type strong:not([class="small selectable"])' text{}| sed 's/,//' >h3.tmp
paste -d, h1.tmp h2.tmp h3.tmp > listofonionnodes.csv

rm -Rf *.tmp
rm -Rf listofonionnodes.html

