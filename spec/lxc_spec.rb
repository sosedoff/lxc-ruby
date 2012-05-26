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
      LXC.check_binaries.should be_true
    end

    it 'returns false on missing files' do
      FileUtils.rm("/tmp/lxc/lxc-version")
      LXC.check_binaries.should be_false
    end
  end

  it 'returns installed version' do
    stub_lxc_with_fixture('version', 'lxc-version.txt')
    LXC.version.should eq('0.7.5')
  end

  it 'returns config hash with attributes' do
    stub_lxc_with_fixture('checkconfig', 'lxc-checkconfig.txt')

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

  it 'returns a single container' do
    c = LXC.container('foo')
    c.should be_a LXC::Container
    c.name.should eq('foo')
  end

  it 'returns all available containers' do
    stub_lxc('ls', "vm0\nvm1\nvm0")
    list = LXC.containers
    list.should be_an Array
    list.size.should eq(2)
    list.first.should be_a LXC::Container
    list.first.name.should eq('vm0')
  end
end