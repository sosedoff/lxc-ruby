module LXC
  class Container
    attr_accessor :name     # Container name (alias)
    attr_reader   :state    # Current state
    attr_reader   :pid      # Current PID (-1 if not running)

    # Initialize a new LXC::Container instance
    # @param [name] container name
    # @return [LXC::Container] container instance
    def initialize(name)
      @name = name
    end

    # Get container as hash
    # @return [Hash]
    def to_hash
      status
      {'name' => name, 'state' => state, 'pid' => pid}
    end

    # Get current status of container
    # @return [Hash] hash with :state and :pid attributes
    def status
      str    = LXC.run('info', '-n', name)
      @state = str.scan(/state:\s+([\w]+)/).flatten.first
      @pid   = str.scan(/pid:\s+(-?[\d]+)/).flatten.first
      {:state => @state, :pid => @pid}
    end

    # Check if container exists
    # @return [Boolean]
    def exists?
      LXC.run('ls').split("\n").uniq.include?(name)
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
      LXC.run('start', '-d', '-n', name)
      status
    end

    # Stop container
    # @return [Hash] container status hash
    def stop
      LXC.run('stop', '-n', name)
      status
    end

    # Freeze container
    # @return [Hash] container status hash
    def freeze
      LXC.run('freeze', '-n', name)
      status
    end

    # Unfreeze container
    # @return [Hash] container status hash
    def unfreeze
      LXC.run('unfreeze', '-n', name)
      status
    end

    # Get container memory usage in bytes
    # @return [Integer]
    def memory_usage
      LXC.run('cgroup', '-n', name, 'memory.usage_in_bytes').strip.to_i
    end

    # Get container memory limit in bytes
    # @return [Integer]
    def memory_limit
      LXC.run('cgroup', '-n', name, 'memory.limit_in_bytes').strip.to_i
    end

    # Get container processes
    def processes
      raise ContainerError, "Container is not running" if !running?
      str = LXC.run('ps', '-n', name, '--', 'aux').strip
      # TODO: Parse process list
      str.split("\n")
    end

    # Create a new container
    # @param [String] path to container config file
    def create(path)
      raise ArgumentError, "File #{path} does not exist." if !File.exists?(path)
      raise ContainerError, "Container already exists." if exists?
      LXC.run('create', '-n', name, '-f', config_path)
    end

    # Destroy the container 
    # @param [force] force deletion (false)
    def destroy(force=false)
      raise ContainerError, "Container does not exist." unless exists?
      raise ContainerError, "Container is running." if running?
      LXC.run('destroy', '-n', name)
      !exists?
    end
  end
end