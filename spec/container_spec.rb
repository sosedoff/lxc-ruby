require 'spec_helper'

describe LXC::Container do
  subject { LXC::Container.new('app') }

  it { should respond_to :name }
  it { should respond_to :status }

  it 'has proper default attributes' do
    subject.name.should eq 'app'
  end

  describe '#exists?' do
    context 'for existing container' do
      it 'returns true' do
        stub_lxc('ls') { "app\napp2" }
        subject.exists?.should be_true
      end
    end

    context 'for non-existing container' do
      it 'returns false' do
        stub_lxc('ls') { "app2\napp3" }
        subject.exists?.should be_false
      end
    end
  end

  describe '#status' do
    it 'returns STOPPED' do
      stub_lxc('info', '-n', 'app') { fixture('lxc-info-stopped.txt') }
      subject.status.should eq LXC::Status.new('STOPPED', '-1')
    end

    it 'returns RUNNING' do
      stub_lxc('info', '-n', 'app') { fixture('lxc-info-running.txt') }
      subject.status.should eq LXC::Status.new('RUNNING', '2125')
    end
  end

  describe '#destroy' do
    it 'raises error if container does not exist' do
      stub_lxc('ls') { "app2" }
      proc { subject.destroy }.
        should raise_error LXC::ContainerError, "Container does not exist."
    end

    it 'raises error if container is running' do
      stub_lxc('ls') { "app" }
      stub_lxc('info', '-n', 'app') { fixture('lxc-info-running.txt') }
      proc { subject.destroy }.
        should raise_error LXC::ContainerError, "Container is running. Stop it first or use force=true"
    end
  end

  describe '#memory_usage' do
    it 'returns the amount of used memory' do
      stub_lxc('cgroup', '-n', 'app', 'memory.usage_in_bytes') { "3280896\n" }
      subject.memory_usage.should eq(3280896)
    end
  end

  describe '#memory_limit' do
    it 'returns the memory limit' do
      stub_lxc('cgroup', '-n', 'app', 'memory.limit_in_bytes') { "268435456\n" }
      subject.memory_limit.should eq(268435456)
    end
  end

  describe '#processes' do
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

  describe '#stopped?' do
    context 'when container does not exist' do
      it 'returns false' do
        stub_lxc('ls') { "foo-app" }
        subject.stopped?.should be_false
      end
    end

    context 'when container exists' do
      it 'returns true if stopped' do
        stub_lxc('ls') { 'app' }
        stub_lxc('info', '-n', 'app') { fixture('lxc-info-stopped.txt') }

        subject.stopped?.should be_true
      end

      it 'returns false if running' do
        stub_lxc('ls') { 'app' }
        stub_lxc('info', '-n', 'app') { fixture('lxc-info-running.txt') }

        subject.stopped?.should be_false
      end
    end
  end

  describe '#cpu_shares' do
    context 'when container is running' do
      before do
        stub_lxc("cgroup", "-n", "app", "cpu.shares") { "1024\n" }
      end

      it 'returns cpu shares value' do
        subject.cpu_shares.should eq 1024
      end
    end

    context 'when container is stopped' do
      before do
        stub_lxc("cgroup", "-n", "app", "cpu.shares") { "\n" }
      end

      it 'returns nil' do
        subject.cpu_shares.should be_nil
      end
    end

    context 'when run command is nil' do
      before do
        subject.stub!(:run).and_return(nil)
      end

      it 'should return nil' do
        subject.cpu_shares.should be_nil
      end
    end
  end

  describe '#cpu_usage' do
    context 'when container is running' do
      before do
        stub_lxc("cgroup", "-n", "app", "cpuacct.usage") { "4239081939568\n" }
      end

      it 'returns usage in seconds' do
        subject.cpu_usage.should eq 4239.0819
      end
    end

    context 'when container is stopped' do
      before do
        stub_lxc("cgroup", "-n", "app", "cpuacct.usage") { "\n" }
      end

      it 'returns nil' do
        subject.cpu_usage.should be_nil
      end
    end

    context 'when run command is nil' do
      before do
        subject.stub!(:run).and_return(nil)
      end

      it 'should return nil' do
        subject.cpu_usage.should be_nil
      end
    end
  end

  describe '#run' do
    let(:subject) do
      class Kontainer < LXC::Container
        def info
          run('info')
        end
      end

      Kontainer.new('app')
    end

    it 'executes a command with container name' do
      stub_lxc("info", "-n", "app") { "info" }
      subject.info.should eq "info"
    end
  end
end
