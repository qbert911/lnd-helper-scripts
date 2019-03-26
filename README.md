# lnd-helper-scripts

Bash scripts to facilitate use of The Lightning Network Daemon 
[(lnd)](https://github.com/lightningnetwork/lnd "lnd github")

Set channel fees to default:
lncli updatechanpolicy 1000 .000001 144

Set channel fees to rock bottom:
lncli updatechanpolicy 0 .000001 144