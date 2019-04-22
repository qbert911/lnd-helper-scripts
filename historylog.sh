#!/bin/bash

currheight=`eval lncli getinfo| jq '.block_height|tonumber'`

echo "Age---Amount-----Fee-----Txns:  $(lncli listchaintxns | jq -r '[.transactions[]|.amount|tonumber]|add')"
lncli listchaintxns | jq -r '.transactions[]|[.num_confirmations,(.amount|tostring),.total_fees|tostring]|join("," )'|sort -grt, |column -ts, -n

echo "----- Forwarding: ------"
lncli fwdinghistory --start_time 5000 --end_time 50000000000000000|jq -c '.forwarding_events[]|[.amt_in,.amt_out,.fee,.fee_msat]'

echo "Age---Amount---Closed Channels-----Capacity--TimeLock-Remote-----------------Closing transaction hash--------------------------"
lncli closedchannels | jq -r '.channels[]|select(.settled_balance!="0")|['$currheight'-(.close_height|tonumber),.settled_balance,.close_type, .capacity,.time_locked_balance,(.capacity|tonumber)-(.settled_balance|tonumber),.closing_tx_hash|tostring]|join(",")'|column -ts,

echo "Age---Amount-------------Coins: $(lncli listunspent |jq -r '[.utxos[]|.amount_sat]|add')"
lncli listunspent |jq -r '.utxos[]|[.confirmations,.amount_sat|tostring]|join(",")'|sort -grt, |column -ts,

echo "-------- Costs: --------"
echo "$(lncli listchaintxns | jq -r '[.transactions[]|.total_fees|tonumber]|add') in channel opening fees"
echo "$(lncli closedchannels | jq -r '[.channels[]|select(.settled_balance!="0" and .close_type == "COOPERATIVE_CLOSE")|(.capacity|tonumber)-(.settled_balance|tonumber)]|add') in coop channel closing costs"
echo "$(lncli listpayments | jq -r '[.payments[]|.fee|tonumber]|add') in lightning payment fees"

echo "-------- Income: -------"
echo "$(lncli fwdinghistory --start_time 5000 --end_time 50000000000000000|jq -r '[.forwarding_events[]|(.fee_msat|tonumber)]|add') msats earned from lightning payment fees"

echo "------- Pending: -------"
lncli pendingchannels | jq -r '[.pending_open_channels[].channel.capacity]|add'

#commitfees=`eval lncli listchannels | jq -s '[.[].channels[]|select(.initiator==true) | .commit_fee|tonumber]|add'`
#echo "Mine---Fee---Lbs--P/kw-------------------------------------Committed: ${commitfees}"
#lncli listchannels | jq -r '.channels[] | [(.initiator|#tostring),.commit_fee,.commit_weight,.fee_per_kw,.local_balance,.remote_balance,.total_satoshis_sent,.total_satoshis_received] | join("," )'|column -ts,

#lncli listchaintxns | jq -r '.transactions[]|.amount|tostring'  ##raw
#lncli listchaintxns | jq -r '.transactions[]|.total_fees|tostring'  ##raw
