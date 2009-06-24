# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{dm-mongo-adapter}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Shane Hanna"]
  s.date = %q{2009-06-24}
  s.email = %q{shane.hanna@gmail.com}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION.yml",
     "dm-mongo-adapter.gemspec",
     "lib/dm-mongo-adapter.rb",
     "spec/adapter_spec.rb",
     "spec/spec.opts",
     "spec/spec_helper.rb"
  ]
  s.homepage = %q{http://github.com/shanna/dm-mongo-adapter}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.4}
  s.summary = %q{Mongo DataMapper Adapter.}
  s.test_files = [
    "spec/adapter_spec.rb",
     "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<dm-core>, ["~> 0.10.0"])
      s.add_runtime_dependency(%q<mongo>, ["~> 0.8"])
    else
      s.add_dependency(%q<dm-core>, ["~> 0.10.0"])
      s.add_dependency(%q<mongo>, ["~> 0.8"])
    end
  else
    s.add_dependency(%q<dm-core>, ["~> 0.10.0"])
    s.add_dependency(%q<mongo>, ["~> 0.8"])
  end
end
