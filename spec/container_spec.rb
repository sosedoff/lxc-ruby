require 'spec_helper'

describe LXC::Container do
  subject { LXC::Container.new('app') }

  it { should respond_to :name }
  it { should respond_to :status }
  it { should respond_to :state }
  it { should respond_to :pid }

  describe '#name' do
    it 'should be set to "app"' do
      expect(subject.name).to eq 'app'
    end
  end

  describe '#exists?' do
    context 'for existing container' do
      it 'returns true' do
        stub_lxc('ls') { "app\napp2" }
        expect(subject).to exist
      end
    end

    context 'for non-existing container' do
      it 'returns false' do
        stub_lxc('ls') { "app2\napp3" }
        expect(subject).to_not exist
      end
    end
  end

  describe '#status' do
    it 'returns STOPPED' do
      stub_lxc('info', '-n', 'app') { fixture('lxc-info-stopped.txt') }
      expect(subject.status).to eq LXC::Status.new('STOPPED', '-1')
    end

    it 'returns RUNNING' do
      stub_lxc('info', '-n', 'app') { fixture('lxc-info-running.txt') }
      expect(subject.status).to eq LXC::Status.new('RUNNING', '2125')
    end
  end

  describe "#create" do
    context "when container already exists" do
      before do
        stub_lxc("ls") { "app" }
      end

      it "raises error" do
        expect { subject.create("path") }.
          to raise_error LXC::ContainerError, "Container already exists."
      end
    end

    it "raises error if config path does not exist" do
      stub_lxc("ls") { "" }

      expect { subject.create("foobar") }.
        to raise_error ArgumentError, "File foobar does not exist."
    end

    it "creates a new container" do
      stub_lxc("ls") { "" }
      stub_lxc("create", "-n", "app", "-f", "/tmp") { "" }
      stub_lxc("ls") { "app" }

      expect(subject.create("/tmp")).to eq true
    end
  end

  describe '#destroy' do
    it 'raises error if container does not exist' do
      stub_lxc('ls') { "app2" }

      expect { 
        subject.destroy 
      }.to raise_error LXC::ContainerError, "Container does not exist."
    end

    it 'raises error if container is running' do
      subject.stub(:exists?).and_return(true)
      subject.stub(:running?).and_return(true)

      expect { 
        subject.destroy 
      }.to raise_error LXC::ContainerError, "Container is running. Stop it first or use force=true"  
    end

    context 'with force=true' do
      before do
        stub_lxc('ls') { 'app' }
        stub_lxc('info', '-n', 'app') { fixture 'lxc-info-running.txt' }
        stub_lxc('stop', '-n', 'app') { '' }
        stub_lxc('info', '-n', 'app') { fixture 'lxc-info-stopped.txt' }
        stub_lxc('destroy', '-n', 'app') { '' }
        stub_lxc('ls') { '' }
      end

      it 'stops and destroys container' do
        expect(subject.destroy(true)).to be_true
      end
    end
  end

  describe '#memory_usage' do
    it 'returns the amount of used memory' do
      stub_lxc('cgroup', '-n', 'app', 'memory.usage_in_bytes') { "3280896\n" }
      expect(subject.memory_usage).to eq(3280896)
    end
  end

  describe '#memory_limit' do
    it 'returns the memory limit' do
      stub_lxc('cgroup', '-n', 'app', 'memory.limit_in_bytes') { "268435456\n" }
      expect(subject.memory_limit).to eq(268435456)
    end
  end

  describe '#processes' do
    it 'raises error if container is not running' do
      stub_lxc('info', '-n', 'app') { fixture('lxc-info-stopped.txt') }

      expect { 
        subject.processes 
      }.to raise_error LXC::ContainerError, "Container is not running"
    end
 
    it 'returns list of all processes' do
      stub_lxc('info', '-n', 'app') { fixture('lxc-info-running.txt') }
      stub_lxc('ps', '-n', 'app', '--', '-eo pid,user,%cpu,%mem,args') { fixture('lxc-ps-aux.txt') }

      list = subject.processes
      expect(list).to be_an Array

      p = list.first
      expect(p).to be_a Hash
      expect(p).to have_key('pid')
      expect(p).to have_key('user')
      expect(p).to have_key('cpu')
      expect(p).to have_key('memory')
      expect(p).to have_key('command')
      expect(p).to have_key('args')
    end
  end

  describe '#stopped?' do
    context 'when container does not exist' do
      it 'returns false' do
        stub_lxc('ls') { "foo-app" }
        expect(subject).to_not be_stopped
      end
    end

    context 'when container exists' do
      it 'returns true if stopped' do
        stub_lxc('ls') { 'app' }
        stub_lxc('info', '-n', 'app') { fixture('lxc-info-stopped.txt') }

        expect(subject).to be_stopped
      end

      it 'returns false if running' do
        stub_lxc('ls') { 'app' }
        stub_lxc('info', '-n', 'app') { fixture('lxc-info-running.txt') }

        expect(subject).to_not be_stopped
      end
    end
  end

  describe '#cpu_shares' do
    context 'when container is running' do
      before do
        stub_lxc("cgroup", "-n", "app", "cpu.shares") { "1024\n" }
      end

      it 'returns cpu shares value' do
        expect(subject.cpu_shares).to eq 1024
      end
    end

    context 'when container is stopped' do
      before do
        stub_lxc("cgroup", "-n", "app", "cpu.shares") { "\n" }
      end

      it 'returns nil' do
        expect(subject.cpu_shares).to be_nil
      end
    end

    context 'when run command is nil' do
      before do
        subject.stub(:run).and_return(nil)
      end

      it 'should return nil' do
        expect(subject.cpu_shares).to be_nil
      end
    end
  end

  describe '#cpu_usage' do
    context 'when container is running' do
      before do
        stub_lxc("cgroup", "-n", "app", "cpuacct.usage") { "4239081939568\n" }
      end

      it 'returns usage in seconds' do
        expect(subject.cpu_usage).to eq 4239.0819
      end
    end

    context 'when container is stopped' do
      before do
        stub_lxc("cgroup", "-n", "app", "cpuacct.usage") { "\n" }
      end

      it 'returns nil' do
        expect(subject.cpu_usage).to be_nil
      end
    end

    context 'when run command is nil' do
      before do
        subject.stub(:run).and_return(nil)
      end

      it 'should return nil' do
        expect(subject.cpu_usage).to be_nil
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
      expect(subject.info).to eq "info"
    end
  end
end
