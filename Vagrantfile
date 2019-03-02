# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

    config.ssh.insert_key = false

    (1..2).each do |id|
        re_name  = ( "vqfx" + id.to_s ).to_sym
        pfe_name  = ( "vqfx" + id.to_s + "_pfe").to_sym

        ##########################
        ## Routing Engine  #######
        ##########################
        config.vm.define re_name do |vqfx|
            vqfx.vm.hostname = "vqfxre#{id}"
            vqfx.vm.box = 'juniper/vqfx10k-re'
            # DO NOT REMOVE / NO VMtools installed
            vqfx.vm.synced_folder '.', '/vagrant', disabled: true

            # Management port (first interface is used by vagrant (em0, hidden here) / second interface is used to connect to the PFE VM (em1))
            vqfx.vm.network 'private_network', auto_config: false, nic_type: '82540EM', virtualbox__intnet: "RE_TO_PFE_#{id}"

            # third interface is a management port not used (em2) -> We will use it to connect our "mgmt station"
            vqfx.vm.network 'private_network', auto_config: false, nic_type: '82540EM', virtualbox__intnet: "mgmt"
            
			# Data ports -> Virtualbox only support 8 interfaces by default, 3 mgmt defined + this 5. xe-0/0/[0-4]. Each one will sit on its own vnet
			(1..5).each do |int_id|
			    vqfx.vm.network 'private_network', auto_config: false, nic_type: '82540EM', virtualbox__intnet: "seg_#{id}_#{int_id}"
			end
        end
        ###############################
        ## Packet Forwarding Engine  ##
        ###############################
        config.vm.define pfe_name do |vqfxpfe|
            vqfxpfe.vm.box = 'juniper/vqfx10k-pfe'
            # DO NOT REMOVE / NO VMtools installed
            vqfxpfe.vm.synced_folder '.', '/vagrant', disabled: true

            # Management port (first interface is used by vagrant (em0) / second interface is used to connect to the RE VM (em1))
            vqfxpfe.vm.network 'private_network', auto_config: false, nic_type: '82540EM', virtualbox__intnet: "RE_TO_PFE_#{id}"

            # A maximum of 2 interfaces are supported:
        end

    end
	
	##########################
	## Server          #######
	##########################
	
    srv_name  = ( "srv1" ).to_sym
	config.vm.define srv_name do |srv|
		srv.vm.box = "centos/7"
		srv.vm.hostname = "#{srv_name}"
		srv.vm.network 'private_network', ip: "10.255.255.201", virtualbox__intnet: "mgmt"
		srv.ssh.insert_key = true
		srv.vm.provision "file", source: "./known_hosts", destination: "/home/vagrant/.ssh/known_hosts"
		srv.vm.provision "file", source: "./id_rsa", destination: "/home/vagrant/.ssh/id_rsa"
		srv.vm.provision "file", source: "./id_rsa.pub", destination: "/home/vagrant/.ssh/id_rsa.pub"
		srv.vm.provision :shell, path: "bootstrap.sh"
	end
    ##############################
    ## Box provisioning    #######
    ##############################
    if !Vagrant::Util::Platform.windows?
        config.vm.provision "ansible" do |ansible|
            ansible.groups = {
                "vqfx10k" => ["vqfx1", "vqfx2" ],
                "server"  => ["srv1"],
                "all:children" => ["vqfx10k", "server"]
            }
            ansible.playbook = "provisioning/deploy-config.p.yaml"
        end
    end
end