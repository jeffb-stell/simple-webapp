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

The serverspec tests make sure Apache us installed, enabled and running. It also tests to make sure port 80 is open and whether the updated index.html file exists where its supposed to.

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
       
       Finished in 0.11901 seconds (files took 0.54442 seconds to load)
       5 examples, 0 failures

Ok we can destroy our env.

	~$ kitchen destroy

In order to deploy to AWS. Change the driver section in  .kitchen.yml to look like

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



For the purposes of this demonstration I already had a security group created with port 80 and port 22 for ingress. I also used an existing public subnet that matches the region and availability zone configured above. 

I also generated a keypair with the [AWS CLI](http://docs.aws.amazon.com/cli/latest/reference/ec2/create-key-pair.html "AWS CLI"). Which I then used to set the value of aws_ssh_key_id and transport.ssh_key

No when running 

	~$ kitchen create

It should result in something like this

	-----> Starting Kitchen (v1.13.2)
	-----> Creating <default-ubuntu-1404>...
	       instance_type not specified. Using free tier t2.micro instance ...
	       Detected platform: ubuntu version 14.04 on x86_64. Instance Type: t2.micro. Default username: ubuntu (default).
	       If you are not using an account that qualifies under the AWS
	free-tier, you may be charged to run these suites. The charge
	should be minimal, but neither Test Kitchen nor its maintainers
	are responsible for your incurred costs.

	       Instance <i-0712b5d3e8614e42e> requested.
	       Polling AWS for existence, attempt 0...
	       Attempting to tag the instance, 0 retries
	       EC2 instance <i-0712b5d3e8614e42e> created.
	       Waited 0/300s for instance <i-0712b5d3e8614e42e> to become ready.
	       Waited 5/300s for instance <i-0712b5d3e8614e42e> to become ready.
	       Waited 10/300s for instance <i-0712b5d3e8614e42e> to become ready.
	       Waited 15/300s for instance <i-0712b5d3e8614e42e> to become ready.
	       Waited 20/300s for instance <i-0712b5d3e8614e42e> to become ready.
	       Waited 25/300s for instance <i-0712b5d3e8614e42e> to become ready.
	       EC2 instance <i-0712b5d3e8614e42e> ready.
	       Waiting for SSH service on ec2-54-212-240-248.us-west-2.compute.amazonaws.com:22, retrying in 3 seconds
	       Waiting for SSH service on ec2-54-212-240-248.us-west-2.compute.amazonaws.com:22, retrying in 3 seconds
	       Waiting for SSH service on ec2-54-212-240-248.us-west-2.compute.amazonaws.com:22, retrying in 3 seconds
	       Waiting for SSH service on ec2-54-212-240-248.us-west-2.compute.amazonaws.com:22, retrying in 3 seconds
	       [SSH] Established
	       Finished creating <default-ubuntu-1404> (1m4.06s).
	-----> Kitchen is finished. (1m7.13s)

This creates the initial env running on AWS.

Let's run the tests.

	~$ kitchen verify

Now we should very similar results as our vagrant run.

Now let's get the public dns to the new instance.

	~$ kitchen diagnose 1404

Look for 

    state_file:
      hostname: ec2-54-212-240-248.us-west-2.compute.amazonaws.com


Your actual hostname will vary.

Copy and paste to a browser and you should see.

	This is a placeholder for the home page.


Now we can destroy our env.

	~$ kitchen destroy

