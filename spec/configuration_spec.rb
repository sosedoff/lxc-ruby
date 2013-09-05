require 'spec_helper'

describe LXC::Configuration do
  it 'parses config data' do
    conf = LXC::Configuration.new(fixture('configuration.txt')) 
    expect(conf.content).to be_a Hash
    expect(conf.attributes).to be_an Array
    expect(conf.attributes).to_not be_empty
    expect(conf.utsname).to_not be_nil
    expect(conf['utsname']).to_not be_nil
    expect(conf[:utsname]).to_not be_nil
    expect(conf.network_ipv4).to_not be_nil
  end

  it 'saves config data into file' do
    conf = LXC::Configuration.new(fixture('configuration.txt')) 
    conf.save_to_file('/tmp/lxc.txt')
    c1 = LXC::Configuration.new(fixture('configuration.txt')) 
    c2 = LXC::Configuration.new(File.read('/tmp/lxc.txt'))
    expect(c1.content).to eq(c2.content)
  end
end
