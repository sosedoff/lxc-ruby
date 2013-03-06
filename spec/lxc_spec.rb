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
      LXC.installed?.should be_true
    end

    it 'returns false on missing files' do
      FileUtils.rm("/tmp/lxc/lxc-version")
      LXC.installed?.should be_false
    end
  end

  describe '.version' do
    it 'returns installed LXC version' do
      stub_lxc('version') { fixture('lxc-version.txt') }
      LXC.version.should eq('0.7.5')
    end
  end

  describe '.config' do
    it 'returns config hash with attributes' do
      stub_lxc('checkconfig') { fixture('lxc-checkconfig.txt') }

      info = LXC.config
      info.should be_a Hash

      info['namespaces'].should be_true
      info['utsname_namespace'].should be_true
      info['ipc_namespace'].should be_true
      info['pid_namespace'].should be_true
      info['user_namespace'].should be_true
      info['network_namespace'].should be_true
      info['cgroup'].should be_true
      info['cgroup_clone_children_flag'].should be_true
      info['cgroup_device'].should be_true
      info['cgroup_sched'].should be_true
      info['cgroup_cpu_account'].should be_true
      info['cgroup_memory_controller'].should be_true
      info['cgroup_cpuset'].should be_true
      info['veth_pair_device'].should be_true
      info['macvlan'].should be_true
      info['vlan'].should be_true
      info['file_capabilities'].should be_true
    end
  end

  describe '.container' do
    it 'returns a container for name' do
      c = LXC.container('foo')

      c.should be_a LXC::Container
      c.name.should eq('foo')
    end
  end

  describe '.containers' do
    it 'returns all available containers' do
      stub_lxc('ls') { "vm0\nvm1\nvm0" }
    
      list = LXC.containers
      list.should be_an Array
      list.size.should eq(2)
      list.first.should be_a LXC::Container
      list.first.name.should eq('vm0')
    end

    context 'with argument' do
      it 'returns containers filtered by name' do
        stub_lxc('ls') { "vm0\nvm1\nfoo\n"}

        list = LXC.containers("vm")
        list.size.should eq(2)
      end
    end
  end

  describe '.sudo' do
    class Foo
      include LXC::Shell
    end

    before do
      LXC.use_sudo = true
    end

    it 'executes command using sudo' do
      LXC.use_sudo.should be_true

      bar = Foo.new
      bar.should_receive(:'`').with('sudo lxc-version').and_return(fixture('lxc-version.txt'))
      bar.run('version').should_not be_empty
    end
  end

  describe '.use_sudo' do
    class Bar
      include LXC::Shell
    end

    it 'should be true' do
      foo = Bar.new
      foo.use_sudo.should eq(true)
      LXC.use_sudo.should eq(true)
    end

    it 'should be false' do
      LXC.use_sudo = false
      foo = Bar.new

      LXC.use_sudo.should eq(false)
      foo.use_sudo.should eq(false)
    end
  end
end