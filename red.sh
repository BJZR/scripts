#!/bin/sh

echo "=== Información de Red ==="

# IP local
local_ip=$(hostname -I 2>/dev/null | awk '{print $1}')
echo "IP local: ${local_ip:-No detectada}"

# IP pública
public_ip=$(curl -s https://ipinfo.io/ip)
echo "IP pública: ${public_ip:-No detectada}"

# DNS actual
dns=$(systemd-resolve --status 2>/dev/null | grep 'DNS Servers' | head -n1 | awk '{print $3}')
[ -z "$dns" ] && dns=$(grep 'nameserver' /etc/resolv.conf | awk '{print $2}' | head -n1)
echo "DNS: ${dns:-No detectado}"

# Ping promedio a google.com
ping_avg=$(ping -c 3 google.com 2>/dev/null | tail -1 | awk -F '/' '{print $5}')
echo "Ping promedio a google.com: ${ping_avg:-No disponible} ms"
