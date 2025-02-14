#!/bin/bash
wget -q0 - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | tee /etc/apt/asources.list.d/elastic-7.x.list
apt-get update
apt-get install -y elasticsearch
systemctl enable elasticsearch
systemctl start elasticsearch