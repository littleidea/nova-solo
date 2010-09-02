#
# Cookbook Name:: nova            
# Recipe:: network

%w{nova-network}.each do |pkg_name|
  package pkg_name
end

service "nova-network" do
  supports :status => true, :restart => true
  action [ :enable, :start ]
  running true
end