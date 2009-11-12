require 'rake'
Gem::Specification.new do |s|
  s.name = %q{cdn_fu}
  s.version = "0.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Curtis Spencer"]
  s.date = %q{2009-11-04}
  s.summary = %q{CDN Fu is a framework for making minification and deployment of static assets easy}
  s.description = <<-EOF
CDN Fu is a framework for making listing, minification and deployment of static
assets easy.  It allows you to use it standalone on the command line for non
Rails project and it can be used as a Rails plugin to add useful rake tasks and
sensible defaults.
EOF
  s.email = %q{curtis@sevenforge.com}
  s.files = FileList.new("README.md","MIT-LICENSE","bin/*","lib/**/*", "rails/*", "tasks/*").to_a
  s.has_rdoc = false
  #s.files = ["README.md", "MIT-LICENSE", "init.rb", "bin/cdnfu", "lib/listers/", "lib/grit/actor.rb", "lib/grit/blame.rb", "lib/grit/blob.rb", "lib/grit/commit.rb", "lib/grit/commit_stats.rb", "lib/grit/config.rb", "lib/grit/diff.rb", "lib/grit/errors.rb", "lib/grit/git-ruby", "lib/grit/git-ruby/commit_db.rb", "lib/grit/git-ruby/file_index.rb", "lib/grit/git-ruby/git_object.rb", "lib/grit/git-ruby/internal", "lib/grit/git-ruby/internal/file_window.rb", "lib/grit/git-ruby/internal/loose.rb", "lib/grit/git-ruby/internal/pack.rb", "lib/grit/git-ruby/internal/raw_object.rb", "lib/grit/git-ruby/object.rb", "lib/grit/git-ruby/repository.rb", "lib/grit/git-ruby.rb", "lib/grit/git.rb", "lib/grit/index.rb", "lib/grit/lazy.rb", "lib/grit/merge.rb", "lib/grit/ref.rb", "lib/grit/repo.rb", "lib/grit/ruby1.9.rb", "lib/grit/status.rb", "lib/grit/submodule.rb", "lib/grit/tag.rb", "lib/grit/tree.rb", "lib/grit.rb", "lib/open3_detach.rb", "LICENSE"]
  #s.extra_rdoc_files = ["README.md", "LICENSE"]
  s.homepage = %q{http://www.sevenforge.com/cdn_fu}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{cdn_fu}
  s.rubygems_version = %q{0.3}

  s.executables = ['cdnfu']

  s.add_dependency('rake', '>=0.8')
  s.add_dependency('aws-s3', '>=0.6.2')
end

