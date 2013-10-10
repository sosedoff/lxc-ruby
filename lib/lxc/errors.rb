module LXC
  class Error              < StandardError ; end
  class ContainerError     < Error         ; end
  class ConfigurationError < Error         ; end
end