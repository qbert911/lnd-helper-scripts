#!/bin/bash
IFS=","

  while read -r title thisID channels; do
    : $((recs++))

	echo "$title,$thisID,$channels"
  done <listofonionnodes.csv
        
