# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

bundle
rails db:create
rails db:migrate




Ubuntu
Ubuntu 17+
sudo apt install libtool libffi-dev ruby ruby-dev make

gem install --user-install iruby
iruby register --force
Ubuntu 16
The latest IRuby requires Ruby >= 2.4 while Ubuntu's official Ruby package is version 2.3. So you need to install Ruby >= 2.4 by yourself before preparing IRuby. We recommend to use rbenv.

sudo apt install libtool libffi-dev ruby ruby-dev make
gem install --user-install iruby
iruby register --force
Fedora
Fedora 36
sudo dnf install ruby ruby-dev make zeromq-devel

gem install --user-install iruby
iruby register --force
Windows
DevKit is necessary for building RubyGems with native C-based extensions.

gem install iruby
iruby register --force
macOS
Install ruby with rbenv or rvm. Install Jupyter.

Homebrew
gem install iruby
iruby register --force
MacPorts
If you are using macports, run the following commands.

port install libtool autoconf automake autogen
gem install iruby
iruby register --force