#!/bin/bash
echo
lncli newaddress p2wkh |jq -r '.address'
echo
