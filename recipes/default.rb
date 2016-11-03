#
# Cookbook Name:: simple-webapp
# Recipe:: default
#

apt_update 'Update the apt cache on a periodic basis (default 1 day)' do
  frequency 86_400
  action :periodic
end


include_recipe 'simple-webapp::apache'


file '/var/www/html/index.html' do
  content '<html>This is a placeholder for the home page.</html>'
  mode '0755'
  owner 'www-data'
  group 'www-data'
end



execute 'apache_graceful' do
  user "root"
  command '/usr/sbin/apachectl graceful'
end
