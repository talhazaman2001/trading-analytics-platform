#!/bin/bash
apt-get install -y kibana
systemctl enable kibana
systemctl start kibana
