#
# Cookbook Name:: simple-webapp
# Recipe:: default
#

#Set apt-get to update nightly
apt_update 'Update the apt cache on a periodic basis (default 1 day)' do
  frequency 86_400
  action :periodic
end


#include our web server recipe, in this case Apache
include_recipe 'simple-webapp::apache'


#Write the super secret message to the default index.html page
file '/var/www/html/index.html' do
  content '<html>Automation for the People</html>'
  mode '0755'
  owner 'www-data'
  group 'www-data'
end


#restart Apache
execute 'apache_graceful' do
  user "root"
  command '/usr/sbin/apachectl graceful'
end
