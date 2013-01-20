require File.expand_path('../lib/lxc/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = "lxc-ruby"
  s.version     = LXC::VERSION
  s.summary     = "Ruby wrapper to LXC"
  s.description = "Ruby wrapper to manage LXC (Linux Containers)."
  s.homepage    = "http://github.com/sosedoff/lxc-ruby"
  s.authors     = ["Dan Sosedoff"]
  s.email       = ["dan.sosedoff@gmail.com"]
  
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec',     '~> 2.6'
  s.add_development_dependency 'simplecov', '~> 0.4'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{|f| File.basename(f)}
  s.require_paths = ["lib"]
end