dir = File.dirname(__FILE__)
$LOAD_PATH.unshift dir unless $LOAD_PATH.include?(dir)

module CdnFu
  def self.init_rails(binding)
    cdn_fu_config_file = File.join(RAILS_ROOT,'config','cdn_fu.rb')
    if File.exists?(cdn_fu_config_file)
      eval(File.open(cdn_fu_config_file).read)
    end
  end
end

require 'core/config_error'
require 'core/config'
require 'core/executor'
require 'core/file_info.rb'
require 'core/lister.rb'
require 'core/minifier.rb'
require 'core/uploader.rb'
["minifiers","listers","uploaders"].each do |subdir|
  Dir[File.join(File.dirname(__FILE__),subdir, "*")].each {|f| require f}
end
