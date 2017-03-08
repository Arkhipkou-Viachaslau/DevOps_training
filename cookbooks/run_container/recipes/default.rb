#
# Cookbook:: run_container
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.
bash 'run_container' do
	cwd '/'
	code <<-EOH
	ccID=$(docker ps --format "{{.ID}}")
	ccPort=$(docker ps --format "{{.Ports}}")
	if [ "${ccPort}" = "0.0.0.0:8080->8080/tcp" ]
		then
			sudo docker pull #{node.default['task7']['reglink']}/task7:#{node.default['task7']['version']}
			sudo docker run -d -p 8081:8080 #{node.default['task7']['reglink']}/task4:#{node.default['task7']['version']}
			sudo docker stop ${ccID}
			sudo docker rm ${ccID}
		else
			sudo docker pull #{node.default['task7']['reglink']}/task7:#{node.default['task7']['version']}
			sudo docker run -d -p 8080:8080 #{node.default['task7']['reglink']}/task4:#{node.default['task7']['version']}
			sudo docker stop ${ccID}
			sudo docker rm ${ccID}
	fi
	EOH
end