# lxc-ruby

Ruby wrapper for [Linux Containers](http://lxc.sourceforge.net/) tools.

[![Build Status](https://secure.travis-ci.org/sosedoff/lxc-ruby.png?branch=master)](http://travis-ci.org/sosedoff/lxc-ruby)

## Requirements

Supported LXC versions:

- 0.7.5
- 0.8.0
- 0.9.0

For testing purposes you can use [Vagrant](http://vagrantup.com/) with [VirtualBox](https://www.virtualbox.org/). 
Most of the functionality was tested on 64-bit Ubuntu 12.04.
Additional boxes could be found [here](http://www.vagrantbox.es/).

## Installation

Add it to your `Gemfile`:

```
gem 'lxc-ruby'
```

Or install it manually:

```
gem install lxc-ruby
```

## Usage

You should have LXC already installed on your system before using the library.

Example:

```ruby
require 'lxc'

# Check if all lxc binaries are installed
LXC.installed?

# Get LXC version
LXC.version

# Get current LXC configuration
LXC.config

# Get a list of all containers
LXC.containers

# Get a single container by name
LXC.container('name')
```

Container instance is a simple abstaction for lxc's container tools:

```ruby
c = LXC.container('foo')

# Get current status of container
c.state  # => 'running'
c.pid    # => 1234
c.status # => <LXC::Status @state='running' @pid=123456>

# Check if container exists?
#
# This is needed since lxc does not raise any errors if container is
# not present in the system, and returns the same result as if container
# is actually stopped
c.exists? # => true

# Status helpers
c.running? # => true
c.stopped? # => false
c.frozen?  # => false

# Start and stop containers
c.start # will be started in daemonized mode
c.stop

# Free and unfreeze (also returns current status)
c.freeze
c.unfreeze

# Destroy container
c.destroy # => true
```

Container metrics:

```ruby
# Get container memory usage (in bytes)
c.memory_usage
c.memory_limit

# Get container cpu shares and usage (in seconds)
c.cpu_shares # => 1024
c.cpu_usage  # => 4312.08

# Get running processes
c.processes 
# => 
#[{"pid"=>"27404",
#   "user"=>"root",
#   "cpu"=>"0.0",
#   "memory"=>"0.1",
#   "command"=>"/sbin/init",
#   "args"=>""}]
```

To create a new container:

``` ruby
c = LXC::Container.new('foo')
c.create(path_to_lxc_config)
```

This method invokes ```lxc-create -n NAME -f CONFIG``` command. It *DOES NOT* create 
any rootfs images or configures anything.

### Running with sudo

By default LXC does not allow to run its command under unprivileged user. There are
two ways to make it work: 

**Using sudo**

```ruby
LXC.use_sudo = true
```

**Using lxc-setcap**

If you want to make container usable by non-root users, run lxc-setcap as root, 
and some capabilities will be set so that normal users will be able to use the 
container utils. This is not done by default, though, and you have to 
explicitly allow it.

## Testing

To run the test suite execute:

```
rake test
```

## License

Copyright (c) 2012-2013 Dan Sosedoff.

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
