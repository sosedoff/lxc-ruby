require 'spec_helper'

describe LXC::Configuration do
  it 'parses config data' do
    conf = LXC::Configuration.new(fixture('configuration.txt')) 
    conf.content.should be_a Hash
    conf.attributes.should be_an Array
    conf.attributes.should_not be_empty
    conf.utsname.should_not be_nil
    conf['utsname'].should_not be_nil
    conf[:utsname].should_not be_nil
    conf.network_ipv4.should_not be_nil
  end

  it 'saves config data into file' do
    conf = LXC::Configuration.new(fixture('configuration.txt')) 
    conf.save_to_file('/tmp/lxc.txt')
    c1 = LXC::Configuration.new(fixture('configuration.txt')) 
    c2 = LXC::Configuration.new(File.read('/tmp/lxc.txt'))
    c1.content.should eq(c2.content)
  end
end