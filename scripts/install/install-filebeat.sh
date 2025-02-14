#!/bin/bash
apt-get install -y filebeat
systemctl enable filebeat
systemctl start filebeat