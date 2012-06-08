require 'spec_helper'

describe LXC::Container do
  subject { LXC::Container.new('app') }

  it { should respond_to(:name) }
  it { should respond_to(:state) }
  it { should respond_to(:pid) }

  it 'has proper default attributes' do
    subject.name.should eq('app')
    subject.state.should be_nil
    subject.pid.should be_nil
  end

  it 'should exist' do
    stub_lxc('ls') { "app\napp2" }
    subject.exists?.should be_true

    stub_lxc('ls') { "app2\napp3" }
    subject.exists?.should be_false
  end

  it 'returns STOPPED status' do
    stub_lxc('info', '-n', 'app') { fixture('lxc-info-stopped.txt') }
    subject.status.should eq({:state => 'STOPPED', :pid => '-1'})
  end

  it 'returns RUNNING status' do
    stub_lxc('info', '-n', 'app') { fixture('lxc-info-running.txt') }
    subject.status.should eq({:state => 'RUNNING', :pid => '2125'})
  end

  it 'returns the amount of used memory' do
    stub_lxc('cgroup', '-n', 'app', 'memory.usage_in_bytes') { '3280896' }
    subject.memory_usage.should eq('3280896')
  end

  it 'returns the memory limit' do
    stub_lxc('cgroup', '-n', 'app', 'memory.limit_in_bytes') { '268435456' }
    subject.memory_limit.should eq('268435456')
  end
end