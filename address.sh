#!/bin/bash
  echo
if [[ -z $1 ]];then 	
  lncli newaddress  p2wkh |jq -r '.address'
else
  lncli newaddress np2wkh |jq -r '.address'
fi
  echo