require File.expand_path('../lib/lxc/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = "lxc"
  s.version     = LXC::VERSION
  s.summary     = "Ruby wrapper to LXC"
  s.description = "Ruby wrapper to manage LXC (Linux Containers)."
  s.homepage    = "http://github.com/sosedoff/lxc"
  s.authors     = ["Dan Sosedoff"]
  s.email       = ["dan.sosedoff@gmail.com"]
  
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec',     '~> 2.6'
  s.add_development_dependency 'simplecov', '~> 0.4'
  s.add_development_dependency 'rack-test', '~> 0.6'
  s.add_development_dependency 'json'

  s.add_runtime_dependency 'sinatra', '~> 1.3'
  s.add_runtime_dependency 'multi_json', '~> 1.3'
  s.add_runtime_dependency 'thin'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{|f| File.basename(f)}
  s.require_paths = ["lib"]
end