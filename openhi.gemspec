# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "openhi/version"

Gem::Specification.new do |s|
  s.name        = "openhi"
  s.version     = Openhi::VERSION
  s.authors     = ["Victor Stabile"]
  s.email       = ["contact@hichinaschool.com"]
  s.homepage    = ""
  s.summary     = %q{OpenHi gem}
  s.description = %q{OpenHi is an API for creating and joining online classrooms}

  s.rubyforge_project = "openhi"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
