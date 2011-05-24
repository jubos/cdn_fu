$:.push File.expand_path("../lib", __FILE__)
require "cdn_fu/version"
Gem::Specification.new do |s|
  s.name = %q{cdn_fu}
  s.version = CdnFu::VERSION
  s.authors = ["Curtis Spencer"]
  s.email       = ["curtis@sevenforge.com"]
  s.summary = %q{CDN Fu is a framework for making minification and deployment of static assets easy}
  s.description = <<-EOF
CDN Fu is a framework for making listing, minification and deployment of static
assets easy.  It allows you to use it standalone on the command line for non
Rails project and it can be used as a Rails plugin to add useful rake tasks and
sensible defaults.
EOF

  s.rubyforge_project = %q{cdn_fu}

  s.add_dependency('rake', '>=0.8')
  s.add_dependency('aws-s3', '>=0.6.2')

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end

