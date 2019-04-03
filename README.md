# Lightning Network Daemon ([LND](https://github.com/lightningnetwork/lnd "lnd github")) Helper Scripts 
Bash scripts to facilitate use of The Lightning Network Daemon (Depends on [jq](https://stedolan.github.io/jq/download/) to parse json)
```sh
sudo apt-get install jq
git clone https://github.com/qbert911/lnd-helper-scripts.git
```
If you like my work please consider connecting to my (secure tor) node to provide some inbound liquidity:
`02419ef2aa268f21606cdc725f08d5ddf2365de96b2606b5852e4155c0f24260e3@lcmy4wbbgymxypp4vozfdhsv5stnk4nssfpl6eimqnarcvea6uu6lgid.onion:9735`
### Fleshed Out
- feereview.sh  
- historylog.sh  
- inferonions.sh  
- routetrace.sh
- sendtomyroute.sh *(in progress)*
### Middle
- jackingin.sh  
- openchan.sh
### Skeletal
- address.sh  
- closechan.sh  
- debugset.sh  
- explorechanneldata.sh  
- pay.sh
#### Notes 
Set channel fees to default:
lncli updatechanpolicy 1000 .000001 144

Set channel fees to rock bottom:
lncli updatechanpolicy 0 .000001 144
