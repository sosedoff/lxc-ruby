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
      'STOPPING',
      'ABORTING',
      'FREEZING',
      'FROZEN'
    ]

    @@use_sudo = false

    # Check if LXC is using sudo to run commands
    # @return [Boolean] current sudo flag value
    def use_sudo
      @@use_sudo
    end

    # Set LXC to execute commands with sudo
    # @param val [Boolean] true for sudo usage
    # @return [Boolean] new sudo flag value
    def use_sudo=(val)
      @@use_sudo = val
      val
    end

    # Check if container state is valid
    # @param name [String] container name
    # @return [Boolean]
    def valid_state?(name)
      CONTAINER_STATES.include?(name)
    end

    # Execute a LXC command
    # @param [String] name command name
    # @param [Array] args command arguments
    # @return [String] execution result
    #
    # If you would like to use pipe command you'll need to 
    # provide a block that returns string
    def run(command, *args)
      command_name = "lxc-#{command}"
      unless BIN_FILES.include?(command_name)
        raise ArgumentError, "Invalid command: #{command_name}."
      end

      cmd = ""
      cmd += "sudo " if use_sudo == true
      cmd += "#{command_name} #{args.join(' ')}".strip
      cmd += " | #{yield}" if block_given?
      `#{cmd.strip}`
    end
  end
end