require 'serverspec'

set :backend, :exec


describe port(22) do
  it { should be_listening }
end