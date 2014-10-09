# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  #vagrant box add ubuntu/trusty https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box
  #vagrant init ubuntu/trusty
  config.vm.box = "ubuntu/trusty64"
  config.vm.network "forwarded_port", guest: 8000, host: 2708
  config.vm.network "forwarded_port", guest: 80, host: 2780
  config.vm.network "forwarded_port", guest: 8080, host: 2788
  config.vm.synced_folder "setup", "/setup"
  config.vm.provider "virtualbox" do |vb|
    vb.gui = true
  
    vb.customize ["modifyvm", :id, "--memory", "2048"]
  end

  config.vm.provision :shell, :path => "geonode-2.4alpha.sh"
  config.vm.provision :shell, :path => "imio-geonode-0.1.sh"
end
