#
# Cookbook:: run_container
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.
bash 'run_container' do
	cwd '/'
	code <<-EOH
	sudo docker pull #{node.default['task5']['reglink']}/task4:#{node.default['task5']['version']}
	sudo docker run -d -p 8080:8080 --name=task5 #{node.default['task5']['reglink']}/task4:#{node.default['task5']['version']}
	EOH
end