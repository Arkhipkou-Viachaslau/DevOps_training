#
# Cookbook:: install_docker
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.
yum_package 'docker' do
  action :install
end
bash 'docker_edit' do
	cwd '/'
	code <<-EOH
	sudo systemctl enable docker
	sudo systemctl stop docker
	sudo sed -i 's/.INSECURE_REGISTRY/--insecure-registry #{node.default['task5']['reglink']}/g' /usr/lib/systemd/system/docker.service
	sudo systemctl daemon-reload
	sudo systemctl start docker
	EOH
end