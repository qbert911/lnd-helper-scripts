#!/bin/bash
cat networkgraph.json | jq -r '.edges[]|[.channel_id,.capacity,.node1_policy.min_htlc,.node1_policy.fee_base_msat,.node1_policy.fee_rate_milli_msat,.node2_policy.min_htlc,.node2_policy.fee_base_msat,.node2_policy.fee_rate_milli_msat]|@csv' > nedgedata.csv