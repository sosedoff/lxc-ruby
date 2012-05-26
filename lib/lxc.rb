require 'lxc/version'
require 'lxc/errors'
require 'lxc/shell'
require 'lxc/container'

module LXC
  class << self
    include LXC::Shell

    # Check if all binaries are present in the system
    # @return [Boolean] - true if everything is in place
    def check_binaries
      !BIN_FILES.map { |n| system("which #{n} > /dev/null") }.uniq.include?(false)
    end

    # Get LXC configuration info
    # @return [Hash] hash containing config groups
    def config
      str = lxc('checkconfig') { 'sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g"' }
      data = str.scan(/^([\w\s]+): (enabled|disabled)$/).map { |r|
        [r.first.downcase.gsub(' ', '_'), r.last == 'enabled']
      }
      Hash[data]
    end

    # Get container information record
    # @param [name] container name
    # @return [LXC::Container]
    def container(name)
      LXC::Container.new(name)
    end

    # Get a list of all available containers
    # @return [Array] array of LXC::Containers
    def containers
      lxc('ls').split("\n").uniq.map { |name| Container.new(name) }
    end

    # Get current LXC version
    # @return [String]
    def version
      lxc('version').strip.split(' ').last
    end
  end
end