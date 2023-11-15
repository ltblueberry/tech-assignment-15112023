#!/bin/bash
load_balancer_dns_name=$1

echo "Checking load balancer at ${load_balancer_dns_name}..."
for i in {1..20}
do
    curl http://$load_balancer_dns_name
    echo ""
done


