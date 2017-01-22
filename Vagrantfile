# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.

$apache = <<SCRIPT
yum install httpd -y
cp /vagrant/mod_jk.so /etc/httpd/modules/
systemctl enable httpd
systemctl start httpd
cat << EOF > /etc/httpd/conf/workers.properties
worker.list=lb
worker.lb.type=lb
worker.lb.balance_workers=tomcat1, tomcat2
worker.tomcat1.host=172.20.20.11
worker.tomcat1.port=8009
worker.tomcat1.type=ajp13
worker.tomcat2.host=172.20.20.12
worker.tomcat2.port=8009
worker.tomcat2.type=ajp13
worker.list=status
worker.status.type=status
EOF
tee -a /etc/httpd/conf/httpd.conf <<EOF
LoadModule jk_module modules/mod_jk.so
JkWorkersFile conf/workers.properties
JkShmFile /tmp/shm
JkLogFile logs/mod_jk.log
JkLogLevel info
JkMount /devops* lb
JkMount /jk-status status
EOF
systemctl restart httpd
SCRIPT

$java = <<SCRIPT
yum install java-1.8.0-openjdk -y
SCRIPT

$tom = <<SCRIPT
yum install tomcat tomcat-webapps tomcat-admin-webapps -y
systemctl start tomcat
systemctl enable tomcat
SCRIPT

$cdir = <<SCRIPT
mkdir /usr/share/tomcat/webapps/devops/
touch /usr/share/tomcat/webapps/devops/index.html
SCRIPT

Vagrant.configure("2") do |config|
	config.vm.box = "bertvv/centos72"
	config.vm.provider "virtualbox" do |vb|
		vb.gui = true
		vb.customize ['modifyvm', :id, '--cableconnected1', 'on']
	end
	config.vm.provision "firewall", type: "shell", inline: <<-SHELL
		systemctl stop firewalld
		systemctl disable firewalld
	SHELL
	
	config.vm.define "apache" do |apache|
		apache.vm.hostname = "apache"
		apache.vm.network "private_network", ip: "172.20.20.10"
		apache.vm.network "forwarded_port", guest: 80, host: 18080
		apache.vm.provision "yum", type: "shell", inline: $apache
	end
	
	config.vm.define "tomcat1" do |tomcat1|
		tomcat1.vm.hostname = "tomcat1"
		tomcat1.vm.network "private_network", ip: "172.20.20.11"
		tomcat1.vm.network "forwarded_port", guest: 8080, host: 18081
		tomcat1.vm.provision "java", type: "shell", inline: $java
		tomcat1.vm.provision "tomcat", type: "shell", inline: $tom
		tomcat1.vm.provision "cdir", type: "shell", inline: $cdir
		tomcat1.vm.provision "index", type: "shell",
			inline: "echo 'the first tomcat' > /usr/share/tomcat/webapps/devops/index.html"
	end
	
	config.vm.define "tomcat2" do |tomcat2|
		tomcat2.vm.hostname = "tomcat2"
		tomcat2.vm.network "private_network", ip: "172.20.20.12"
		tomcat2.vm.network "forwarded_port", guest: 8080, host: 18082
		tomcat2.vm.provision "java", type: "shell", inline: $java
		tomcat2.vm.provision "tomcat", type: "shell", inline: $tom
		tomcat2.vm.provision "cdir", type: "shell", inline: $cdir
		tomcat2.vm.provision "index", type: "shell",
			inline: "echo 'the second tomcat' > /usr/share/tomcat/webapps/devops/index.html"
	end
	
	
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  
  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Define a Vagrant Push strategy for pushing to Atlas. Other push strategies
  # such as FTP and Heroku are also available. See the documentation at
  # https://docs.vagrantup.com/v2/push/atlas.html for more information.
  # config.push.define "atlas" do |push|
  #   push.app = "YOUR_ATLAS_USERNAME/YOUR_APPLICATION_NAME"
  # end

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   apt-get update
  #   apt-get install -y apache2
  # SHELL
end
