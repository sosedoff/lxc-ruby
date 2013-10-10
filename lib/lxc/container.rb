module LXC
  class Container
    attr_accessor :name

    # Initialize a new LXC::Container instance
    # @param [String] name container name
    # @return [LXC::Container] container instance
    def initialize(name)
      @name = name
    end

    # Get container attributes hash
    # @return [Hash]
    def to_hash
      status.to_hash.merge("name" => name)
    end

    # Get current status of container
    # @return [Hash] hash with :state and :pid attributes
    def status
      output = run("info")
      result = output.scan(/^state:\s+([\w]+)|pid:\s+(-?[\d]+)$/).flatten

      LXC::Status.new(result.first, result.last)
    end

    # Get state of the container
    # @return [String]
    def state
      status.state
    end

    # Get PID of the container
    # @return [Integer]
    def pid
      status.pid
    end

    # Check if container exists
    # @return [Boolean]
    def exists?
      LXC.run("ls").split("\n").uniq.include?(name)
    end

    # Check if container is running
    # @return [Boolean]
    def running?
      status.state == "running"
    end

    # Check if container is frozen
    # @return [Boolean]
    def frozen?
      status.state == "frozen"
    end

    # Check if container is stopped
    # @return [Boolean]
    def stopped?
      exists? && status.state == "stopped"
    end

    # Start container
    # @return [Hash] container status hash
    def start
      run("start", "-d")
      status
    end

    # Stop container
    # @return [Hash] container status hash
    def stop
      run("stop")
      status
    end

    # Restart container
    # @return [Hash] container status hash
    def restart
      stop ; start
      status
    end

    # Freeze container
    # @return [Hash] container status hash
    def freeze
      run("freeze")
      status
    end

    # Unfreeze container
    # @return [Hash] container status hash
    def unfreeze
      run("unfreeze")
      status
    end

    # Wait for container to change status
    # @param [String] state name
    def wait(state)
      if !LXC::Shell.valid_state?(status.state)
        raise ArgumentError, "Invalid container state: #{state}"
      end

      run("wait", "-s", state)
    end

    # Get container memory usage in bytes
    # @return [Integer]
    def memory_usage
      run("cgroup", "memory.usage_in_bytes").strip.to_i
    end

    # Get container memory limit in bytes
    # @return [Integer]
    def memory_limit
      run("cgroup", "memory.limit_in_bytes").strip.to_i
    end

    # Get container cpu shares
    # @return [Integer]
    def cpu_shares
      result = run("cgroup", "cpu.shares").to_s.strip
      result.empty? ? nil : result.to_i
    end

    # Get container cpu usage in seconds
    # @return [Float]
    def cpu_usage
      result = run("cgroup", "cpuacct.usage").to_s.strip
      result.empty? ? nil : Float("%.4f" % (result.to_i / 1E9))
    end

    # Get container processes
    # @return [Array] list of all processes
    def processes
      raise ContainerError, "Container is not running" if !running?

      str = run("ps", "--", "-eo pid,user,%cpu,%mem,args").strip
      lines = str.split("\n") ; lines.delete_at(0)
      lines.map { |l| parse_process_line(l) }
    end

    # Create a new container
    # @param [String] path path to container config file or [Hash] options
    # @return [Boolean]
    def create(path)
      raise ContainerError, "Container already exists." if exists?

      if path.is_a?(Hash)
        args = "-n #{name}"

        if !!path[:config_file]
          unless File.exists?(path[:config_file])
            raise ArgumentError, "File #{path[:config_file]} does not exist."
          end
          args += " -f #{path[:config_file]}"
        end

        if !!path[:template]
          template_dir =  path[:template_dir] || "/usr/lib/lxc/templates"
          template_path = File.join(template_dir,"lxc-#{path[:template]}")
          unless File.exists?(template_path)
            raise ArgumentError, "Template #{path[:template]} does not exist."
          end
          args += " -t #{path[:template]} "
        end

        args += " -B #{path[:backingstore]}" if !!path[:backingstore]
        args += " -- #{path[:template_options].join(" ")}".strip if !!path[:template_options]

        LXC.run("create", args)
        exists?
      else
        unless File.exists?(path)
          raise ArgumentError, "File #{path} does not exist."
        end

        LXC.run("create", "-n", name, "-f", path)
        exists?
      end
    end

    # Clone to a new container from self
    # @param [String] target name of new container
    # @return [LXC::Container] new container instance
    def clone_to(target)
      raise ContainerError, "Container does not exist." unless exists?

      if LXC.container(target).exists?
        raise ContainerError, "New container already exists."
      end

      LXC.run("clone", "-o", name, "-n", target)
      LXC.container(target)
    end

    # Create a new container from an existing container
    # @param [String] source name of existing container
    # @return [Boolean]
    def clone_from(source)
      raise ContainerError, "Container already exists." if exists?

      unless LXC.container(source).exists?
        raise ContainerError, "Source container does not exist."
      end

      run("clone", "-o", source)
      exists?
    end

    # Destroy the container 
    # @param [Boolean] force force destruction
    # @return [Boolean] true if container was destroyed
    #
    # If container is running and `force` parameter is true
    # it will be stopped first. Otherwise it will raise exception.
    #
    def destroy(force=false)
      unless exists?
        raise ContainerError, "Container does not exist."
      end

      if running?
        if force == true
          stop
        else
          raise ContainerError, "Container is running. Stop it first or use force=true"
        end  
      end

      run("destroy")

      !exists?
    end

    private

    def run(command, *args)
      LXC.run(command, "-n", name, *args)
    end

    def parse_process_line(line)
      chunks = line.split(" ")
      chunks.delete_at(0)

      {
        "pid"     => chunks.shift,
        "user"    => chunks.shift,
        "cpu"     => chunks.shift,
        "memory"  => chunks.shift,
        "command" => chunks.shift,
        "args"    => chunks.join(" ")
      }
    end
  end
end
