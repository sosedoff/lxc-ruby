require 'posix/spawn'

require 'lxc/version'
require 'lxc/errors'
require 'lxc/shell'
require 'lxc/configuration_options'
require 'lxc/configuration'
require 'lxc/container'

module LXC
  # Check if binary file is installed
  # @param [String] binary filename
  # @return [Boolean] true if installed
  def self.binary_installed?(name)
    path = File.join(LXC::Shell::BIN_PREFIX, name)
    File.exists?(path)
  end

  # Check if all binaries are present in the system
  # @return [Boolean] true if binary files are found
  def self.installed?
    !BIN_FILES.map { |f| binary_installed?(f) }.uniq.include?(false)
  end

  # Get LXC configuration info
  # @return [Hash] hash containing config groups
  def self.config
    str = LXC.run('checkconfig') { LXC::Shell::REMOVE_COLORS }
    data = str.scan(/^([\w\s]+): (enabled|disabled)$/).map { |r|
      [r.first.downcase.gsub(' ', '_'), r.last == 'enabled']
    }
    Hash[data]
  end

  # Get a single container instance
  # @param [String] name of the container
  # @return [LXC::Container] container instance
  def self.container(name)
    LXC::Container.new(name)
  end

  # Get a list of all available containers
  # @param [String] select containers that match string
  # @return [Array] array of LXC::Containers
  def self.containers(filter=nil)
    names = LXC.run('ls').split("\n").uniq
    names.delete_if { |v| !v.include?(filter) } if filter.kind_of?(String)
    names.map { |name| Container.new(name) }
  end

  # Get currently installeded LXC version
  # @return [String] current LXC version
  def self.version
    LXC.run('version').strip.split(' ').last
  end
end