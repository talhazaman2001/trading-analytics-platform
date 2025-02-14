#!/bin/bash
apt-get install -y logstash
systemctl enable logstash
systemctl start logstash 
