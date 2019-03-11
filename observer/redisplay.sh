#!/bin/bash
while : ; do
  OUTPUTME=`cat combined-header.txt myout.txt | column -tns,`
  clear
  echo -e "${OUTPUTME}"
  ball=$((139))
  full=$((232))
  empt=$((122))

  sizesleep=$((1))
  size=$((4))
  time=$((30))
  secsi=$time
  while [ $secsi -gt -1 ]; do
echo -ne "   \e[38;5;$ball""mO\e[38;5;$empt""m"
for (( c=1; c<=$(( ($time - $secsi) * $size / 2 )); c++ )); do echo -n -e "=";done
echo -ne "\e[38;5;$full""m"
for (( c=1; c<=$(( $secsi * $size )); c++ )); do echo -n -e "-";done
echo -ne "\e[38;5;$empt""m"
for (( c=1; c<=$(( ( $time * $size ) - (($time - $secsi) * $size / 2) - ( $secsi * $size ) )); c++ )); do echo -n -e "=";done
  echo -ne "\e[38;5;$ball""mO\e[0m  \033[0K  \r"
  sleep $sizesleep; : $((secsi--));done   #countdown
done
