
package 'apache2'

#Include, enable and start Apache
service 'apache2' do
  supports :status => true
  action [:enable, :start]
end


