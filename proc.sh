#!/bin/sh

echo "=== Procesos que más CPU consumen ==="
ps -eo pid,comm,%cpu --sort=-%cpu | head -n 6

echo
echo "=== Procesos que más RAM consumen ==="
ps -eo pid,comm,%mem --sort=-%mem | head -n 6

echo
echo "=== Memoria y swap ==="
free -h | awk 'NR==1{print} NR==2{print} NR==3{print}'
