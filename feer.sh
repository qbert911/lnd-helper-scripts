lncli feereport | jq -r '.channel_fees[]|[.channel_point,.base_fee_msat,.fee_per_mil,(.fee_rate|tostring)]|join(",")'
lncli feereport | jq -r '.month_fee_sum'
