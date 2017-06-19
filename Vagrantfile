# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
 
  config.vm.box = "centos/7"

  config.vm.provider "virtualbox" do |vb|
      vb.name = "hybris-tutorial-vm"
      vb.memory = "4096" 
    end 

  ##config.vm.network :private_network, ip: '192.168.9.99'  
  #Open Hybris's default ports 9001 and 9002
  config.vm.network "forwarded_port", guest: 9001, host: 9001, host_ip: "localhost"
  config.vm.network "forwarded_port", guest: 9002, host: 9002, host_ip: "localhost" 
  
  config.ssh.forward_agent = true

  #set up the synch folder between the host and the guest
  config.vm.synced_folder ".", "/vagrant", type: "virtualbox"

  config.vm.post_up_message = "
              
              ###############################
              #                             #
              #       Hybris has been       #
              #     succesfully installed   #
              ###############################                           

                  HybrisArchitect.com
  "
  #The primary shell script that will install SAP Hybris and its dependencies
  config.vm.provision "shell", path: "bootstrap.sh", privileged: true
 
 

end
