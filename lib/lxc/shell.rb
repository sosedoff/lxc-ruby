module LXC
  module Shell
    extend self

    BIN_PREFIX = '/usr/bin'

    BIN_FILES = [
      'lxc-attach',
      'lxc-cgroup',
      'lxc-checkconfig',
      'lxc-checkpoint',
      'lxc-clone',
      'lxc-console',
      'lxc-create',
      'lxc-destroy',
      'lxc-execute',
      'lxc-freeze',
      'lxc-info',
      'lxc-kill',
      'lxc-ls',
      'lxc-monitor',
      'lxc-netstat',
      'lxc-ps',
      'lxc-restart',
      'lxc-setcap',
      'lxc-setuid',
      'lxc-start',
      'lxc-start-ephemeral',
      'lxc-stop',
      'lxc-unfreeze',
      'lxc-unshare',
      'lxc-version',
      'lxc-wait'
    ]

    CONTAINER_STATES = [
      'STOPPED',
      'STARTING',
      'RUNNING',
      'ABORTING',
      'STOPPING'
    ]

    # Execute a LXC command
    # To use pipe command just provide a block 
    # @param [name] command name
    # @param [args] command arguments
    # @return [String]
    def lxc(command, *args)
      command_name = "lxc-#{command}"
      unless BIN_FILES.include?(command_name)
        raise ArgumentError, "Invalid command: #{command_name}."
      end
      cmd = "#{command_name} #{args.join(' ')}".strip
      cmd += " | #{yield}" if block_given?
      `#{cmd.strip}`
    end

    alias :run :lxc
  end
end