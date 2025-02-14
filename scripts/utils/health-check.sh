#!/bin/bash
echo "Checking Elasticsearch..."
curl -s localhost:9200/_cluster/health | grep status

echo "Checking Logstash..."
systemctl status logstash | grep Active

echo "Checking Kibana..."
curl -s localhost:5601/api/status | grep status 

echo "Checking Filebeat..."
systemctl status filebeat | grep Active