require 'spec_helper'
require 'fileutils'

describe LXC do
  describe '.check_binaries' do
    LXC::Shell::BIN_PREFIX = '/tmp/lxc'

    before do
      FileUtils.mkdir_p('/tmp/lxc')
      LXC::Shell::BIN_FILES.each do |f|
        FileUtils.touch("/tmp/lxc/#{f}")
        FileUtils.chmod(0555, "/tmp/lxc/#{f}")
      end
    end

    after do
      FileUtils.rm_rf('/tmp/lxc')
    end

    it 'returns true if all files are found' do
      expect(LXC.installed?).to be_true
    end

    it 'returns false on missing files' do
      FileUtils.rm("/tmp/lxc/lxc-info")
      expect(LXC.installed?).to be_false
    end
  end

  describe '.version' do
    it 'returns installed LXC version' do
      stub_lxc('info', '--version') { fixture('lxc-info.txt') }
      expect(LXC.version).to eq('0.7.5')
    end
  end

  describe '.config' do
    it 'returns config hash with attributes' do
      stub_lxc('checkconfig') { fixture('lxc-checkconfig.txt') }

      info = LXC.config
      expect(info).to be_a(Hash)

      expect(info['namespaces']).to be_true
      expect(info['utsname_namespace']).to be_true
      expect(info['ipc_namespace']).to be_true
      expect(info['pid_namespace']).to be_true
      expect(info['user_namespace']).to be_true
      expect(info['network_namespace']).to be_true
      expect(info['cgroup']).to be_true
      expect(info['cgroup_clone_children_flag']).to be_true
      expect(info['cgroup_device']).to be_true
      expect(info['cgroup_sched']).to be_true
      expect(info['cgroup_cpu_account']).to be_true
      expect(info['cgroup_memory_controller']).to be_true
      expect(info['cgroup_cpuset']).to be_true
      expect(info['veth_pair_device']).to be_true
      expect(info['macvlan']).to be_true
      expect(info['vlan']).to be_true
      expect(info['file_capabilities']).to be_true
    end
  end

  describe '.container' do
    it 'returns a container for name' do
      c = LXC.container('foo')

      expect(c).to be_a LXC::Container
      expect(c.name).to eq('foo')
    end
  end

  describe ".containers" do
    it "returns all available containers" do
      stub_lxc('ls') { "vm0\nvm1\nvm0" }
    
      list = LXC.containers
      expect(list).to be_an Array
      expect(list.size).to eq(2)
      expect(list.first).to be_a LXC::Container
      expect(list.first.name).to eq('vm0')
    end

    context "with string filter" do
      before do
        stub_lxc("ls") { "vm0\nvm1\nfoo\n"}
      end

      it "returns matched containers" do
        expect(LXC.containers("vm").size).to eq 2
      end
    end

    context "with regexp filter" do
      before do
        stub_lxc("ls") { "vm0\nvm1\nfoo\n"}
      end

      it "returns matched container" do
        expect(LXC.containers(/vm/).size).to eq 2
      end
    end
  end

  describe '.sudo' do
    before { LXC.use_sudo = true }
    let(:result) do 
      klass = Struct.new(:out)
      klass.new(fixture('lxc-info.txt'))
    end

    it 'executes command using sudo' do
      expect(LXC.use_sudo).to be_true

      POSIX::Spawn::Child.stub(:new).
        with('sudo lxc-info --version').
        and_return(result)

      expect(LXC.run('info', '--version')).to eq "lxc version: 0.7.5"
    end
  end

  describe '.use_sudo' do
    class Bar ; include LXC::Shell ; end

    it 'should be true' do
      foo = Bar.new
      expect(foo.use_sudo).to be_true
      expect(LXC.use_sudo).to be_true
    end

    it 'should be false' do
      LXC.use_sudo = false
      foo = Bar.new

      expect(LXC.use_sudo).to be_false
      expect(foo.use_sudo).to be_false
    end
  end
end
