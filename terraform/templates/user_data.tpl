#!/bin/bash

# System Updates
apt-get update
apt-get upgrade -y

# Install essential tools
apt-get install -y \
    awscli \
    jq \
    unzip \
    curl \
    gnupg2 \
    apt-transport-https \
    ca-certificates \
    software-properties-common \
    openjdk-11-jdk

# Install SSM Agent for Ubuntu
sudo snap install amazon-ssm-agent --classic
sudo systemctl enable snap.amazon-ssm-agent.amazon-ssm-agent.service
sudo systemctl start snap.amazon-ssm-agent.amazon-ssm-agent.service

# Add Elasticsearch repository
wget -qO /usr/share/keyrings/elasticsearch-keyring.gpg https://artifacts.elastic.co/GPG-KEY-elasticsearch
echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/7.x/apt stable main" | tee /etc/apt/sources.list.d/elastic-7.x.list

# Update package list
apt-get update

# Install ELK Stack
apt-get install -y elasticsearch kibana logstash

# Configure Elasticsearch
cat <<EOF > /etc/elasticsearch/elasticsearch.yml
cluster.name: "${cluster_name}"
node.name: "$(hostname)"
path.data: /var/lib/elasticsearch
path.logs: /var/log/elasticsearch
network.host: 0.0.0.0
discovery.type: single-node
xpack.security.enabled: true
EOF

# Set JVM options for Elasticsearch
cat <<EOF > /etc/elasticsearch/jvm.options.d/heap.options
-Xms1g
-Xmx1g
EOF

# Configure Kibana
cat <<EOF > /etc/kibana/kibana.yml
server.host: "0.0.0.0"
server.port: 5601
elasticsearch.hosts: ["http://localhost:9200"]
EOF

# Configure Logstash
cat <<EOF > /etc/logstash/logstash.yml
path.data: /var/lib/logstash
path.logs: /var/log/logstash
xpack.monitoring.enabled: true
EOF

# Install and configure Filebeat
apt-get install -y filebeat

cat <<EOF > /etc/filebeat/filebeat.yml
filebeat.inputs:
- type: s3
  enabled: true
  var.queue_url: "${s3_sqs_queue_url}"

output.logstash:
  hosts: ["localhost:5044"]
EOF

# Start services
systemctl daemon-reload

for service in elasticsearch kibana logstash filebeat; do
    systemctl enable $service
    systemctl start $service
    
    # Check service status
    if ! systemctl is-active --quiet $service; then
        echo "$service failed to start"
        exit 1
    fi
done

# Wait for Elasticsearch to be ready
until curl -s localhost:9200 > /dev/null; do
    echo "Waiting for Elasticsearch to start..."
    sleep 10
done

# Set up passwords
/usr/share/elasticsearch/bin/elasticsearch-setup-passwords auto -b > /root/elastic_passwords.txt

if [ ! -f /root/elastic_passwords.txt ]; then
    echo "Failed to generate Elasticsearch passwords"
    exit 1
fi

# Extract passwords
ELASTIC_PASSWORD=$(grep "elastic = " /root/elastic_passwords.txt | awk '{print $3}')

# Update Kibana config with password
sed -i "s/#elasticsearch.username: .*/elasticsearch.username: elastic/" /etc/kibana/kibana.yml
sed -i "s/#elasticsearch.password: .*/elasticsearch.password: $ELASTIC_PASSWORD/" /etc/kibana/kibana.yml

# Restart Kibana to apply password
systemctl restart kibana.service

# Store password in Parameter Store
aws ssm put-parameter \
    --region "${aws_region}" \
    --name "/${cluster_name}/elastic_password" \
    --value "$ELASTIC_PASSWORD" \
    --type SecureString \
    --overwrite

# Install monitoring
apt-get install -y prometheus-node-exporter

# Cleanup
rm -f /root/elastic_passwords.txt

echo "ELK Stack installation completed successfully"