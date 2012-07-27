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

  context '.status' do
    it 'returns STOPPED' do
      stub_lxc('info', '-n', 'app') { fixture('lxc-info-stopped.txt') }
      subject.status.should eq({:state => 'STOPPED', :pid => '-1'})
    end

    it 'returns RUNNING' do
      stub_lxc('info', '-n', 'app') { fixture('lxc-info-running.txt') }
      subject.status.should eq({:state => 'RUNNING', :pid => '2125'})
    end
  end

  context '.destroy' do
    context 'on non-existing container' do
      it 'raises ContainerError' do
        stub_lxc('ls') { "app2" }
        proc { subject.destroy }.should raise_error LXC::ContainerError, "Container does not exist."
      end
    end
  end

  it 'returns the amount of used memory' do
    stub_lxc('cgroup', '-n', 'app', 'memory.usage_in_bytes') { "3280896\n" }
    subject.memory_usage.should eq(3280896)
  end

  it 'returns the memory limit' do
    stub_lxc('cgroup', '-n', 'app', 'memory.limit_in_bytes') { "268435456\n" }
    subject.memory_limit.should eq(268435456)
  end

  context '.processes' do
    it 'raises error if container is not running' do
      stub_lxc('info', '-n', 'app') { fixture('lxc-info-stopped.txt') }

      proc { subject.processes }.
        should raise_error LXC::ContainerError, "Container is not running"
    end
 
    it 'returns list of all processes' do
      stub_lxc('info', '-n', 'app') { fixture('lxc-info-running.txt') }
      stub_lxc('ps', '-n', 'app', '--', '-eo pid,user,%cpu,%mem,args') { fixture('lxc-ps-aux.txt') }

      list = subject.processes
      list.should be_an Array

      p = list.first
      p.should be_a Hash
      p.should have_key('pid')
      p.should have_key('user')
      p.should have_key('cpu')
      p.should have_key('memory')
      p.should have_key('command')
      p.should have_key('args')
    end
  end
end