export ANSIBLE_HOST_KEY_CHECKING=False

# terraform init
# terraform apply


# ./jenkins-post-install.sh
# split to 2 scripts, run each with ansible

ansible-playbook  consul_servers_configuration_playbook.yaml   -i inventory_aws_ec2.yaml
ansible-playbook  ellastic_servers_configuration_playbook.yaml   -i inventory_aws_ec2.yaml
ansible-playbook  jenkins_servers_configuration_playbook.yaml   -i inventory_aws_ec2.yaml
ansible-playbook  k8s_configuration_playbook.yaml   -i inventory_aws_ec2.yaml