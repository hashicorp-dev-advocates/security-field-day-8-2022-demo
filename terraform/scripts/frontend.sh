#!/bin/sh

apt-get update -y
apt-get upgrade -y
apt-get install -y unzip jq
sudo apt install postgresql-client-common

# Install vault agent

wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install vault


mkdir -p -m 777 -v /home/boundaryadmin/vault

touch /home/boundaryadmin/vault/agent-config.hcl


# Install Consul
cd /tmp
wget https://releases.hashicorp.com/consul/1.8.0/consul_1.8.0_linux_amd64.zip -O consul.zip
unzip ./consul.zip
mv ./consul /usr/bin/consul

mkdir -p /etc/consul/config

cat <<EOF > /etc/consul/ca.pem
${ca}
EOF

cat <<EOF > /etc/consul/config/frontend.hcl
service {
  name = "frontend"
  id = "frontend-1"
  port = 9090
  connect {
    sidecar_service {
      proxy {
      }
    }
  }
}
EOF

# Generate the consul startup script
#!/bin/sh -e

cat <<EOF > /etc/consul/consul_start.sh
#!/bin/bash -e
# Get JWT token from the metadata service and write it to a file
curl 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fmanagement.azure.com%2F' -H Metadata:true -s | jq -r .access_token > ./meta.token
# Use the token to log into the Consul server, we need a valid ACL token to join the cluster and setup autoencrypt
CONSUL_HTTP_ADDR=https://${consul_join_addr} consul login -method my-jwt -bearer-token-file ./meta.token -token-sink-file /etc/consul/consul.token
# Generate the Consul Config which includes the token so Consul can join the cluster
cat <<EOC > /etc/consul/config/consul.json
{
  "acl":{
    "enabled":true,
    "down_policy":"async-cache",
    "default_policy":"deny",
    "tokens": {
      "default":"\$(cat /etc/consul/consul.token)"
    }
  },
  "ca_file":"/etc/consul/ca.pem",
  "verify_outgoing":true,
  "datacenter":"${consul_datacenter}",
  "encrypt":"${consul_gossip_key}",
  "server":false,
  "log_level":"INFO",
  "ui":true,
  "retry_join":[
    "${consul_join_addr}"
  ],
  "ports": {
    "grpc": 8502
  },
  "auto_encrypt":{
    "tls":true
  }
}
EOC
# Run Consul
/usr/bin/consul agent -node=payments -config-dir=/etc/consul/config/ -data-dir=/etc/consul/data
EOF

chmod +x /etc/consul/consul_start.sh

# Setup Consul agent in SystemD
cat <<EOF > /etc/systemd/system/consul.service
[Unit]
Description=Consul Agent
After=network-online.target
[Service]
WorkingDirectory=/etc/consul
ExecStart=/etc/consul/consul_start.sh
Restart=always
RestartSec=5
StartLimitIntervalSec=0
[Install]
WantedBy=multi-user.target
EOF

# Install Envoy

#sudo apt update
#sudo apt install apt-transport-https gnupg2 curl lsb-release
#curl -sL 'https://deb.dl.getenvoy.io/public/gpg.8115BA8E629CC074.key' | sudo gpg --dearmor -o /usr/share/keyrings/getenvoy-keyring.gpg
#echo a077cb587a1b622e03aa4bf2f3689de14658a9497a9af2c427bba5f4cc3c4723 /usr/share/keyrings/getenvoy-keyring.gpg | sha256sum --check
#echo "deb [arch=amd64 signed-by=/usr/share/keyrings/getenvoy-keyring.gpg] https://deb.dl.getenvoy.io/public/deb/ubuntu $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/getenvoy.list
#sudo apt update
#sudo apt install -y getenvoy-envoy

curl -L https://getenvoy.io/cli | bash -s -- -b /usr/local/bin
getenvoy fetch standard:1.12.6
cp /root/.getenvoy/builds/standard/1.12.6/linux_glibc/bin/envoy /usr/bin/envoy

# Setup Envoy Service in SystemD
cat <<EOF > /etc/systemd/system/envoy.service
[Unit]
Description=Envoy
After=network-online.target
Wants=consul.service
[Service]
ExecStart=/usr/bin/consul connect envoy -sidecar-for payments-1 -envoy-binary /usr/bin/envoy -- -l debug
Environment="CONSUL_HTTP_TOKEN_FILE=/etc/consul/consul.token"
Restart=always
RestartSec=5
StartLimitIntervalSec=0
[Install]
WantedBy=multi-user.target
EOF


# Restart SystemD
systemctl daemon-reload

systemctl enable consul
systemctl enable envoy

systemctl restart consul
systemctl restart envoy
