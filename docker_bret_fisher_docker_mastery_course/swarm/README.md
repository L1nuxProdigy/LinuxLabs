3 node Docker Swarm lab.

Prerequisites
- Terraform
- AWS Account

1. cloen this repository and cd into this location.
2. use the "terraform init" command
3. add the values for the following variables in the tf file in the upper variable section:
    (1) vpc_id_string, get the id of the vpc the deployment will happen in
    (2) subnet_id_string, the subnet id in the vpc
    (3) aws_keypair_name, the name of your keypair

post deployment the machines internal resolveable FQDNs will be:
- swarm_node_1.swarm.local
- swarm_node_2.swarm.local
- swarm_node_3.swarm.local

each machine is installed with:
- docker-ce
- docker-ce-cli
- containerd.io
- docker-compose
