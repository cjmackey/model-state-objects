
$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), 'lib'))

require 'model-state-objects/version'

Gem::Specification.new do |s|
  s.name = "Model State Objects"
  s.version = ModelStateObjects::VERSION
  
  s.add_development_dependency "rspec", "~>2.11.0"
  s.add_development_dependency "guard-rspec", "~>2.1.0"
  
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
