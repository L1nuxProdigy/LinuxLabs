3 node Docker Swarm lab.

Prerequisites
- Terraform
- AWS Account

1. clone this repository and cd into this location.
2. use the "terraform init" command
3. add the values for the following variables in the tf file in the upper variable section:
    (1) vpc_id_string, id of the vpc in which the deployment will happen
    (2) subnet_id_string, the subnet id in the vpc
    (3) aws_keypair_name, the name of your keypair

post deployment the machines can be resolved internally with the following FQDNs:
- node1.swarm
- node2.swarm
- node2.swarm

each machine is installed with:
- docker-ce
- docker-ce-cli
- containerd.io
- docker-compose

####### Manual lab configuration #######

to configure the swarm do:
- SSH to one of the machines and run:
    (1) docker swarm init
    (2) docker swarm join-token manager

- SSH to the other machines and paste the join command output that you ran in the first machine