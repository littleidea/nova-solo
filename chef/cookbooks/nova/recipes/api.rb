#
# Cookbook Name:: nova            
# Recipe:: api

%w{nova-api}.each do |pkg_name|
  package pkg_name
end

service "nova-api" do
  supports :status => true, :restart => true
  action [ :enable, :start ]
  running true
end

execute "Add EC2_URL to Nova API" do
  command "echo --ec2_url=http://" + node[:ipaddress] + ":8773/services/Cloud >> /etc/nova/nova-api.conf" 
  not_if { `cat /etc/nova/nova-api.conf` =~ /--ec2_url=#{node[:ipaddress]}/ }
  notifies :restart, resources(:service => "nova-api")
end

execute "Add S3_HOST setting to Nova API" do
  command "echo --s3_host=#{node[:ipaddress]} >> /etc/nova/nova-api.conf" 
  not_if { `cat /etc/nova/nova-api.conf` =~ /--s3_host=#{node[:ipaddress]}/ }
  notifies :restart, resources(:service => "nova-api")
end
