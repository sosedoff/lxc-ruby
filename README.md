# LXC Ruby Wrapper [![Build Status](https://secure.travis-ci.org/sosedoff/lxc-ruby.png?branch=master)](http://travis-ci.org/sosedoff/lxc-ruby)

Ruby wrapper to [LXC](http://lxc.sourceforge.net/) cli tools. 

Provides a simple ruby dsl and json API to manage containers. 

## Requirements

Supported LXC versions:

- 0.7.5
- 0.8.0-rc1
- 0.8.0-rc2 - in works  

For testing purposes you can use [Vagrant](http://vagrantup.com/) or [VirtualBox](https://www.virtualbox.org/). Most of functionality
was tested on Ubuntu 11.04 / 11.10. Additional boxes could be found [here](http://www.vagrantbox.es/)

## Installation

As for now this gem is not released yet, so use gem install task:

```
rake build
rake install
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
c.status # => {:state => 'RUNNING', :pid => 1234}

# Check if container exists?
# this is needed since lxc does not raise any errors if container is
# not present in the system, and returns the same result as if container
# is actually stopped
c.exists? # => true

# Status helpers
c.running? # => true
c.frozen?  # => false

# Start and stop containers
c.start  # => {:state => 'RUNNING', :pid => 1234}
c.stop   # => {:state => 'STOPPED', :pid => -1}

# Free and unfreeze (also returns current status)
c.freeze
c.unfreeze

# Get container memory usage (in bytes)
c.memory_usage
c.memory_limit

# Get running processes
c.processes 
# => 
#[{"pid"=>"27404",
#   "user"=>"root",
#   "cpu"=>"0.0",
#   "memory"=>"0.1",
#   "command"=>"/sbin/init",
#   "args"=>""}]

# Destroy container
c.destroy # => true
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

1. Using sudo

```ruby
LXC.use_sudo = true
```

2. Using lxc-setcap

If you want to make container usable by non-root users, run lxc-setcap as root, and some capabilities will be set so that normal users will be able to use the container utils. This is not done by default, though, and you have to explicitly allow it.

## LXC Server

This library includes a HTTP API implementation for container management. 

To start server:

```
lxc-server
```

Or view more options:

```
Usage: lxc-server [options]
    -v, --version                    Show version
    -b, --bind INTERFACE             Bind server to interface (default: 0.0.0.0)
    -p, --port PORT                  Start server on port (default: 27000)
```

### Endpoints

General:

    GET /                  # Get current time
    GET /version           # Current gem version
    GET /lxc_version       # Installed LXC version
    GET /containers        # Get container list 
    GET /containers/:name  # Get a single container information

Processes:

    GET /containers/:name/processes # Get a list of all running processes

Management:

    POST /container/:name/create
    POST /container/:name/destroy

Status change operations:

    POST /container/:name/start 
    POST /container/:name/stop
    POST /container/:name/freeze
    POST /container/:name/unfreeze

## Testing

To run the test suite execute:

```
rake test
```

## License

Copyright (c) 2012 Dan Sosedoff.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.