# Overview
This is a sample recipe to provision a web server and write content to the default index.html. 

The vagrant driver is configured by default to allow for local testing via Test Kitchen.

There are both bats tests as well as serverspec tests to ensure the desired state has been achieved.

#Pre-requisites

* Virtualbox
* Vagrant
* Chefdk


I use homebrew to maintain packages, if you want to do that. Install homebrew if it isn't already installed.

```
~$ /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

Install dependencies

	~$ brew cask install virtualbox
	~$ brew cask install virtualbox-extension-pack
	~$ brew cask install vagrant
	~$ brew cask install chefdk


#Installation

	~$ git clone git@github.com:louissimps/simple-webapp.git
	~$ cd simple-webapp
	~$ bundle install


#Running the tests
	~$ kitchen verify

For the bats tests we just check for the apachectl binary to be in our path.
You should see the following results for the bats test

	-----> Running bats test suite
	 ✓ apachectl binary is found in PATH

The serverspec tests make sure Apache is installed, enabled and running. It also tests to make sure port 80 is open and whether the updated index.html file exists where its supposed to.

Those results look like this.

	-----> serverspec installed (version 2.37.2)
       /opt/chef/embedded/bin/ruby -I/tmp/verifier/suites/serverspec -I/tmp/verifier/gems/gems/rspec-support-3.5.0/lib:/tmp/verifier/gems/gems/rspec-core-3.5.4/lib /opt/chef/embedded/bin/rspec --pattern /tmp/verifier/suites/serverspec/\*\*/\*_spec.rb --color --format documentation --default-path /tmp/verifier/suites/serverspec
       
       Package "apache2"
         should be installed
       
       Service "apache2"
         should be enabled
         should be running
       
       Port "80"
         should be listening
       
       File "/var/www/html/index.html"
         should contain "<html>This is a placeholder for the home page.</html>"
       
       Port "22"
         should be listening       
       
       Finished in 0.11901 seconds (files took 0.54442 seconds to load)
       6 examples, 0 failures

Ok we can destroy our env.

	~$ kitchen destroy

###Deploying to AWS

For the purposes of this demonstration I already had a security group created with port 80 and port 22 open for ingress. I also used an existing public subnet that matches the region and availability zone configured above. 

I also generated a keypair with the [AWS CLI](http://docs.aws.amazon.com/cli/latest/reference/ec2/create-key-pair.html "AWS CLI"). Which I then used to set the value of aws_ssh_key_id and transport.ssh_key

	aws ec2 create-key-pair --key-name louie | ruby -e "require 'json'; puts JSON.parse(STDIN.read)['KeyMaterial']" > ~/.ssh/louie
	sudo chmod 400 ~/.ssh/louie
	export AWS_SSH_KEY_ID=louie


Change the driver section in  .kitchen.yml to look like

	driver:
	  #name: vagrant
	  name: ec2
	  aws_ssh_key_id: louie
	  transport.ssh_key: ~/.ssh/louie
	  transport.username: ubuntu
	  region: us-west-2
	  availability_zone: us-west-2b
	  require_chef_omnibus: true
	  security_group_ids: sg-dce191a5
	  subnet_id: subnet-cc2bd3ba
	  associate_public_ip: true
	  interface: dns



Now when running 

	~$ kitchen verify

It should result in something like this

	-----> Starting Kitchen (v1.13.2)
	-----> Creating <default-ubuntu-1404>...
	       instance_type not specified. Using free tier t2.micro instance ...
	       Detected platform: ubuntu version 14.04 on x86_64. Instance Type: t2.micro. Default username: ubuntu (default).
	       If you are not using an account that qualifies under the AWS
	free-tier, you may be charged to run these suites. The charge
	should be minimal, but neither Test Kitchen nor its maintainers
	are responsible for your incurred costs.

	       Instance <i-0dc9ab01dbf5237bd> requested.
	       Polling AWS for existence, attempt 0...
	       Attempting to tag the instance, 0 retries
	       EC2 instance <i-0dc9ab01dbf5237bd> created.
	       Waited 0/300s for instance <i-0dc9ab01dbf5237bd> to become ready.
	       Waited 5/300s for instance <i-0dc9ab01dbf5237bd> to become ready.
	       Waited 10/300s for instance <i-0dc9ab01dbf5237bd> to become ready.
	       Waited 15/300s for instance <i-0dc9ab01dbf5237bd> to become ready.
	       Waited 20/300s for instance <i-0dc9ab01dbf5237bd> to become ready.
	       Waited 25/300s for instance <i-0dc9ab01dbf5237bd> to become ready.
	       Waited 30/300s for instance <i-0dc9ab01dbf5237bd> to become ready.
.......
.......
	-----> Kitchen is finished. (1m7.13s)



Now we should very similar results as our vagrant run.

	-----> Running bats test suite
	 ✓ apachectl binary is found in PATH
	       
	       1 test, 0 failures
	-----> Running serverspec test suite
	-----> Installing Serverspec..
	Fetching: diff-lcs-1.2.5.gem (100%)
	Fetching: rspec-expectations-3.5.0.gem (100%)
	Fetching: rspec-mocks-3.5.0.gem (100%)
	Fetching: rspec-3.5.0.gem (100%)
	Fetching: rspec-its-1.2.0.gem (100%)
	Fetching: multi_json-1.12.1.gem (100%)
	Fetching: net-ssh-3.2.0.gem (100%)
	Fetching: net-scp-1.2.1.gem (100%)
	Fetching: net-telnet-0.1.1.gem (100%)
	Fetching: sfl-2.3.gem (100%)
	Fetching: specinfra-2.64.0.gem (100%)
	Fetching: serverspec-2.37.2.gem (100%)
	-----> serverspec installed (version 2.37.2)
	       /opt/chef/embedded/bin/ruby -I/tmp/verifier/suites/serverspec -I/tmp/verifier/gems/gems/rspec-support-3.5.0/lib:/tmp/verifier/gems/gems/rspec-core-3.5.4/lib /opt/chef/embedded/bin/rspec --pattern /tmp/verifier/suites/serverspec/\*\*/\*_spec.rb --color --format documentation --default-path /tmp/verifier/suites/serverspec
	       
	       Package "apache2"
	         should be installed
	       
	       Service "apache2"
	         should be enabled
	         should be running
	       
	       Port "80"
	         should be listening
	       
	       File "/var/www/html/index.html"
	         should contain "<html>Automation for the People</html>"
	       
	       Port "22"
	         should be listening
	       
	       Finished in 0.06 seconds (files took 0.36624 seconds to load)
	       6 examples, 0 failures



Now let's get the public dns to the new instance.

	~$ kitchen diagnose 1404

Look for 

    state_file:
      hostname: ec2-54-212-240-248.us-west-2.compute.amazonaws.com


Your actual hostname will vary.

Copy and paste to a browser and you should see.

	Automation for the People


Now we can destroy our env.

	~$ kitchen destroy

