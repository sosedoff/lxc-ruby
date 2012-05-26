module LXC
  class Container
    include LXC::Shell

    attr_accessor :name     # Container name (alias)
    attr_reader   :state    # Current state
    attr_reader   :pid      # Current PID (-1 if not running)

    # Initialize a new LXC::Container instance
    # @param [name] container name
    # @return [LXC::Container] container instance
    def initialize(name)
      @name = name
    end

    # Get current status of container
    # @return [Hash] hash with :state and :pid attributes
    def status
      str    = lxc('info', '-n', name)
      @state = str.scan(/state:\s+([\w]+)/).flatten.first
      @pid   = str.scan(/pid:\s+([\d]+)/).flatten.first
      {:state => @state, :pid => @pid}
    end

    # Check if container exists
    # @return [Boolean]
    def exists?
      lxc('ls').split("\n").uniq.include?(name)
    end

    # Check if container is running
    # @return [Boolean]
    def running?
      status[:state] == 'RUNNING'
    end

    # Check if container is frozen
    # @return [Boolean]
    def frozen?
      status[:state] == 'FROZEN'
    end

    # Start container
    # @return [Hash] container status hash
    def start
      lxc('start', '-d', '-n', name)
      status
    end

    # Stop container
    # @return [Hash] container status hash
    def stop
      lxc('stop', '-n', name)
      status
    end

    # Freeze container
    # @return [Hash] container status hash
    def freeze
      lxc('freeze', '-n', name)
      status
    end

    # Unfreeze container
    # @return [Hash] container status hash
    def unfreeze
      lxc('unfreeze', '-n', name)
    end

    # Destroy the container 
    # @param [force] force deletion (false)
    def destroy(force=false)
      raise ContainerError, "Container does not exist." unless exists?
      raise ContainerError, "Container is running." if running?
      lxc('destroy', '-n', name)
      !exists?
    end
  end
end