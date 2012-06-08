$:.unshift File.expand_path("../..", __FILE__)

require 'rack/test'
require 'json'

require 'lib/lxc'
require 'lib/lxc/server'

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
end

def fixture_path(filename=nil)
  path = File.expand_path("../fixtures", __FILE__)
  filename.nil? ? path : File.join(path, filename)
end

def fixture(file)
  File.read(File.join(fixture_path, file))
end

def stub_lxc(command, *args)
  output = yield
  LXC.should_receive(:run).with(command, *args).and_return(output)
end

def app
  LXC::Server
end

def parse_json(data)
  JSON.parse(data)
end