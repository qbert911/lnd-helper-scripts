#!/bin/bash
IFS=","

#eval lncli getinfo | jq -r '[.identity_pubkey,"0","0","0","ALL ME"]| join("," )' >> nodelist.txt  #add own node to list
 # mybalance=`cat rawout.txt | jq -s '[.[].channels[].local_balance|tonumber]|add'`	
	balance='6'


balance="        ${balance}";balance="${balance: -8}"
echo $balance
