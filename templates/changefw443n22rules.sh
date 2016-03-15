#!/bin/bash

# Written by Johan Guldmyr @ CSC 2014 to change default firewall rules on a perfsonar machine.
# There are some PS scripts that reset iptables persistent config..

##HTTP
        NEWRULE=3
        NEWV6RULE=3
        V4NETS="{{ trusted_public_networks | replace(' ', ',') }}"
        V6NETS="{{ trusted_public_ipv6_networks | replace(' ', ',') }}"
#	echo "https v4"
        iptables -I perfSONAR $NEWRULE -s $V4NETS -p tcp -m tcp --dport 443 -m state --state NEW,ESTABLISHED -j ACCEPT
        FINDV4RULE="$(iptables -L -n --line-numbers|grep dpt:443|grep "0.0.0.0/0.*0.0.0.0/0"|awk '{print $1}')"
        iptables -D perfSONAR $FINDV4RULE
#	echo "https v6"
        ip6tables -I perfSONAR $NEWRULE -s $V6NETS -p tcp -m tcp --dport 443 -m state --state NEW,ESTABLISHED -j ACCEPT
#	echo "https v6-2"
        FINDV6RULE="$(ip6tables -L -n --line-numbers|grep dpt:443|grep "::/0.*::/0"|awk '{print $1}')"
#	echo "https v6-3"
        ip6tables -D perfSONAR $FINDV6RULE
##SSH
#	echo "ssh v4"
        iptables -I INPUT $NEWRULE -s $V4NETS -p tcp -m tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
        FINDV4RULE1="$(iptables -L -n --line-numbers|grep dpt:22|grep ACCEPT|grep -v fail2ban-SSH|grep "0.0.0.0/0.*0.0.0.0/0"|awk '{print $1}')"
        iptables -D INPUT $FINDV4RULE1
#	echo "ssh v6"
        ip6tables -I INPUT $NEWV6RULE -s $V6NETS -p tcp -m tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
#	echo "ssh v6-2"
        FINDV6RULE1="$(ip6tables -L -n --line-numbers|grep dpt:22|grep "::/0.*::/0"|grep -v fail2ban-SSH|awk '{print $1}')"
#	echo "ssh v6-3"
        ip6tables -D INPUT $FINDV6RULE1
##NAGIOS
        iptables -I perfSONAR -p tcp -m state --state NEW,ESTABLISHED -m tcp --dport 5666 -s {{ nagios_allowed_hosts }} -j ACCEPT
        ip6tables -I perfSONAR -p tcp -m state --state NEW,ESTABLISHED -m tcp --dport 5666 -s {{ nagios_allowed_hosts_ipv6 }} -j ACCEPT

echo "Removed all world firewall rules and allows only $V4NETS and $V6NETS to access port 443/22. See /etc/rc.local."
