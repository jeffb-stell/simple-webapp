# Overview
This is a sample recipe to provision a web server and write content to the default index.html. 

The vagrant driver is configured by default to allow for local testing via Test Kitchen.

#Pre-requisites

* Virtualbox
* Vagrant
* Chefdk


I use homebrew to maintain packages, if you want to do that. Install homebrew if it isn't already installed.
```bash
~$ /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```
Install dependencies
```bash
~$ brew cask install virtualbox
~$ brew cask install virtualbox-extension-pack
~$ brew cask install vagrant
~$ brew cask install chefdk
```

#Installation
```bash
~$ git clone git@github.com:louissimps/simple-webapp.git
~$ cd simple-webapp
~$ bundle install
~$ kitchen create
~$ 
~$ 
~$ 
~$ 
~$ 

```


    