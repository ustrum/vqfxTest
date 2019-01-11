#!/bin/sh

chmod 400 /home/vagrant/.ssh/id_rsa
chmod 400 /home/vagrant/.ssh/id_rsa.pub
chmod 400 /home/vagrant/.ssh/known_hosts
sudo yum install git
sudo yum install ansible -y
sudo yum install epel-release -y
sudo yum install python-pip -y
sudo pip install --upgrade pip
sudo pip install jxmlease
sudo pip install junos-eznc
sudo ansible-galaxy install Juniper.junos
