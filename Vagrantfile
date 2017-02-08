tomcat_count = 2

$apache = <<SCRIPT
yum install httpd -y
cp /vagrant/mod_jk.so /etc/httpd/modules/
tee /etc/httpd/conf/workers.properties <<EOF
worker.list=lb
worker.lb.type=lb
worker.lb.balance_workers=
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
SCRIPT

$httpdr = <<SCRIPT
systemctl enable httpd
systemctl start httpd
SCRIPT

$cdir = <<SCRIPT
mkdir /usr/share/tomcat/webapps/devops/
touch /usr/share/tomcat/webapps/devops/index.html
SCRIPT

$java = <<SCRIPT
yum install java-1.8.0-openjdk -y
yum install java-1.8.0-openjdk-devel -y
SCRIPT

$git = <<SCRIPT
yum install git -y
SCRIPT

$tom = <<SCRIPT
yum install tomcat tomcat-webapps tomcat-admin-webapps -y
systemctl start tomcat
systemctl enable tomcat
SCRIPT

$jenkins = <<SCRIPT
wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo
rpm --import https://jenkins-ci.org/redhat/jenkins-ci.org.key
yum install jenkins -y
service jenkins start 
chkconfig jenkins on
SCRIPT

Vagrant.configure("2") do |config|
	config.vm.box = "bertvv/centos72"
	config.vm.provider "virtualbox" do |vb|
		vb.gui = false
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
		apache.vm.network "forwarded_port", guest: 8080, host: 28080
		apache.vm.network "forwarded_port", guest: 8081, host: 38080
		apache.vm.provision "yum", type: "shell", inline: $apache
		(1..tomcat_count).each do |i|
			apache.vm.provision "workers.properties#{i}", type: "shell", inline:
			"sed -i 's/^worker.lb.balance_workers=.*/&tomcat#{i},/' /etc/httpd/conf/workers.properties
			echo 'worker.tomcat#{i}.host=172.20.20.1#{i}' >> /etc/httpd/conf/workers.properties
			echo 'worker.tomcat#{i}.port=8009' >> /etc/httpd/conf/workers.properties
			echo 'worker.tomcat#{i}.type=ajp13' >> /etc/httpd/conf/workers.properties"
		end
		apache.vm.provision "httpdrestart", type: "shell", inline: $httpdr
		apache.vm.provision "java", type: "shell", inline: $java
		apache.vm.provision "jenkins", type: "shell", inline: $jenkins
		apache.vm.provision "jenkins", type: "shell", inline: $git
	end
	
	(1..tomcat_count).each do |i|
		config.vm.define "tomcat#{i}" do |tom|
		tom.vm.hostname = "tomcat#{i}"
		tom.vm.network "private_network", ip: "172.20.20.1#{i}"
		tom.vm.network "forwarded_port", guest: 8080, host: "1808#{i}"
		tom.vm.provision "java", type: "shell", inline: $java
		tom.vm.provision "tomcat", type: "shell", inline: $tom
		tom.vm.provision "cdir", type: "shell", inline: $cdir
		tom.vm.provision "index", type: "shell",
			inline: "echo 'the tomcat#{i}' > /usr/share/tomcat/webapps/devops/index.html"
		end
	end

end
