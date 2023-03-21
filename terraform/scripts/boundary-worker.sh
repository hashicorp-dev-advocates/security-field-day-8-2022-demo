#!/bin/sh

mkdir -p -m 777 -v /home/boundaryadmin/boundary

wget https://releases.hashicorp.com/boundary-worker/0.10.5+hcp/boundary-worker_0.10.5+hcp_linux_amd64.zip ;\
sudo apt-get update && sudo apt-get install unzip
unzip *.zip

touch /home/boundaryadmin/boundary/pki-worker.hcl

cat << EOF > /home/boundaryadmin/boundary/pki-worker.hcl
disable_mlock = true

hcp_boundary_cluster_id = "${BOUNDARY_CLUSTER_ID}"

listener "tcp" {
  address = "0.0.0.0:9202"
  purpose = "proxy"
}

worker {
  public_addr = "${BOUNDARY_IP_ADDR}"
  auth_storage_path = "/home/boundaryadmin/boundary/worker1"
  tags {
    type = ["worker", "dev"]
  }
}

EOF

sudo mv boundary-worker /usr/local/bin/

cat << EOF > /etc/systemd/system/boundary-worker.service

[Unit]
Description=boundary-worker
After=network.target
StartLimitIntervalSec=0
[Service]
Type=simple
Restart=always
RestartSec=1
User=boundaryadmin
ExecStart=/usr/local/bin/boundary-worker server -config=/home/boundaryadmin/boundary/pki-worker.hcl
KillMode=process
KillSignal=SIGINT
Restart=on-failure
RestartSec=5
TimeoutStopSec=30
StartLimitIntervalSec=60
StartLimitBurst=3
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target

EOF
