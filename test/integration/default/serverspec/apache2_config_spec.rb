require 'serverspec'

set :backend, :exec

describe package('apache2'), :if => os[:family] == 'ubuntu' do
  it { should be_installed }
end
describe service('apache2'), :if => os[:family] == 'ubuntu' do
  it { should be_enabled }
  it { should be_running }
end


describe port(80) do
  it { should be_listening }
end
describe file('/var/www/html/index.html') do
  it { should contain '<html>Automation for the People</html>' }
end

