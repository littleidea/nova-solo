#
# Cookbook Name:: nova            
# Recipe:: default

include_recipe "apt"

##########################################################################
# We are using Nova Core Packages from 
# https://launchpad.net/~nova-core/+archive/ppa
##########################################################################
execute "Download Soren's Launchpad GPG key" do
  command "gpg --keyserver hkp://keys.gnupg.net --recv-keys AB0188513FD35B23" 
  not_if { `gpg -a --export AB0188513FD35B23` =~ /BEGIN PGP/ }
end

execute "Import Soren's Launchpad GPG key" do
  command "gpg -a --export AB0188513FD35B23 | apt-key add -"
  not_if { `apt-key list` =~ /3FD35B23/ }
end

execute "Download Nova Core Launchpad GPG key" do
  command "gpg --keyserver hkp://keys.gnupg.net --recv-keys 1EBA3D372A2356C9" 
  not_if { `gpg -a --export 1EBA3D372A2356C9` =~ /BEGIN PGP/ }
end

execute "Import Nova Core Launchpad GPG key" do
  command "gpg -a --export 1EBA3D372A2356C9 | apt-key add -"
  not_if { `apt-key list` =~ /2A2356C9/ }
end

template "/etc/apt/sources.list.d/openstack-nova.list" do
  source "openstack-nova.list.erb"
#  variables ( {
#    :url1 => "http://192.168.122.1/repos/ppa.launchpad.net/soren/nova/ubuntu",
#    :url2 => "http://192.168.122.1/repos/173.203.107.207/ubuntu"
#  } )
  variables ( {
    :url1 => "http://ppa.launchpad.net/soren/nova/ubuntu",
    :url2 => "http://ppa.launchpad.net/nova-core/ppa/ubuntu"
  } )
  notifies :run, resources(:execute => "apt-get update"), :immediate
end


# Install common Nova packages
%w{python-mox screen python-libxml2 python-ldap euca2ools unzip parted python-setuptools python-dev python-pycurl python-m2crypto strace}.each do |pkg_name|
  package pkg_name
end

# Disable Apparmor since it can really mess with us
service "apparmor" do
  action :disable
end

include_recipe "nova::controller"
include_recipe "nova::objectstore"
include_recipe "nova::api"
include_recipe "nova::volumestore"
include_recipe "nova::network"
include_recipe "nova::compute"