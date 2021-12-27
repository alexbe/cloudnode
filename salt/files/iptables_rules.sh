#!/bin/bash

IPprefix_by_netmask () { 
   c=0 x=0$( printf '%o' ${1//./ } )
   while [ $x -gt 0 ]; do
       let c+=$((x%2)) 'x>>=1'
   done
   echo /$c ; }

CMD=${1:-iptables}
((${EUID:-0} || "$(id -u)")) && CMD="sudo $CMD"

VIRBR=br0
VBR_IP=$(ip -f inet a show ${VIRBR} | sed -En 's/^\s*inet\s+([./0-9]+)\s+brd.+/\1/p')
ETH=eth0

#NAT
$CMD -A FORWARD -o $ETH -j ACCEPT
$CMD -A FORWARD -i $ETH -m state --state RELATED,ESTABLISHED -j ACCEPT
$CMD -t nat -A POSTROUTING -o $ETH -j MASQUERADE
#NFS
$CMD -A INPUT -s $VBR_IP -d $VBR_IP -p tcp -m multiport --dports 10053,111,2049,32764:32769,875,892 -m state --state NEW,ESTABLISHED -j ACCEPT
$CMD -A INPUT -s $VBR_IP -d $VBR_IP -p udp -m multiport --dports 10053,111,2049,32764:32769,875,892 -m state --state NEW,ESTABLISHED -j ACCEPT
$CMD -A OUTPUT -s $VBR_IP -d $VBR_IP -p udp -m multiport --sports 10053,111,2049,32764:32769,875,892 -m state --state ESTABLISHED -j ACCEPT
$CMD -A OUTPUT -s $VBR_IP -d $VBR_IP -p tcp -m multiport --sports 10053,111,2049,32764:32769,875,892 -m state --state ESTABLISHED -j ACCEPT
