# LXC Ruby Wrapper [![Build Status](https://secure.travis-ci.org/sosedoff/lxc-ruby.png?branch=master)](http://travis-ci.org/sosedoff/lxc-ruby)

Ruby library to manage linux containers (lxc) via ruby dsl or HTTP api.

HTTP api support is coming soon.

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
LXC.check_binaries

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

# Destroy container
c.destroy # => true
```

More examples and functionality on the way.

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