$:.unshift File.expand_path("../..", __FILE__)

require 'lib/lxc'

def fixture_path
  File.expand_path("../fixtures", __FILE__)
end

def fixture(file)
  File.read(File.join(fixture_path, file))
end

def stub_lxc(command, output)
  LXC.should_receive(:lxc).with(command).and_return(output)
end

def stub_lxc_with_fixture(command, path)
  stub_lxc(command, fixture(path))
end