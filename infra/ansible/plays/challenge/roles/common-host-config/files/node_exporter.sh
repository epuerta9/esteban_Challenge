#!/bin/bash



curl -LO  https://github.com/prometheus/node_exporter/releases/download/v0.18.1/node_exporter-0.18.1.linux-amd64.tar.gz

tar -xvf node_exporter-0.18.1.linux-amd64.tar.gz

mv node_exporter-0.18.1.linux-amd64/node_exporter /usr/local/bin/

useradd -rs /bin/false node_exporter

mv /home/ubuntu/node_exporter.service /etc/systemd/system/

systemctl daemon-reload
systemctl start node_exporter

systemctl status node_exporter
systemctl enable node_exporter

