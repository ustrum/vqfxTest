# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

    config.ssh.insert_key = false

    (1..2).each do |id|
        re_name  = ( "vqfx" + id.to_s ).to_sym

        ##########################
        ## Routing Engine  #######
        ##########################
        config.vm.define re_name do |vqfx|
            vqfx.vm.hostname = "vqfx#{id}"
            vqfx.vm.box = 'juniper/vqfx10k-re'
            # DO NOT REMOVE / NO VMtools installed
            vqfx.vm.synced_folder '.', '/vagrant', disabled: true

            # Management port (em1 / em2)
            vqfx.vm.network 'private_network', auto_config: false, nic_type: '82540EM', virtualbox__intnet: "vqfx_internal_#{id}"
            vqfx.vm.network 'private_network', auto_config: false, nic_type: '82540EM', virtualbox__intnet: "reserved-bridge"

            # Dataplane ports (em3)
            vqfx.vm.network 'private_network', auto_config: false, nic_type: '82540EM', virtualbox__intnet: "server_vqfx#{id}"

            # (em4, em5)
            (1..2).each do |seg_id|
                vqfx.vm.network 'private_network', auto_config: false, nic_type: '82540EM', virtualbox__intnet: "seg#{seg_id}"
            end
            vqfx.vm.network 'private_network', auto_config: false, nic_type: '82540EM', virtualbox__intnet: "seg_test"
        end


    end
	
	##########################
	## Server          #######
	##########################
	
    srv_name  = ( "srv1" ).to_sym
	config.vm.define srv_name do |srv|
		srv.vm.box = "ubuntu/xenial64"
		srv.vm.hostname = "server1-ubuntu"
		srv.vm.network 'private_network', ip: "10.255.255.201", virtualbox__intnet: "seg_test"
		srv.ssh.insert_key = true
		srv.vm.provision "file", source: "./id_rsa", destination: "/home/vagrant/.ssh/id_rsa"
		srv.vm.provision "file", source: "./id_rsa.pub", destination: "/home/vagrant/.ssh/id_rsa.pub"
		srv.vm.provision "shell",
		   inline: "sudo route add -net 10.10.0.0 netmask 255.255.0.0 gw 10.255.255.1"
		srv.vm.provision "shell",
		   inline: "chmod 400 ./.ssh/id_rsa"
		srv.vm.provision "shell",
		   inline: "chmod 400 ./.ssh/id_rsa.pub"
	end
    ##############################
    ## Box provisioning    #######
    ##############################
    if !Vagrant::Util::Platform.windows?
        config.vm.provision "ansible" do |ansible|
            ansible.groups = {
                "vqfx10k" => ["vqfx1", "vqfx2" ],
                "server"  => ["server1", "server2" ],
                "all:children" => ["vqfx10k", "server"]
            }
            ansible.playbook = "provisioning/deploy-config.p.yaml"
        end
    end
end