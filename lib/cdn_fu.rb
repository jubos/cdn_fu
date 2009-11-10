dir = File.dirname(__FILE__)
$LOAD_PATH.unshift dir unless $LOAD_PATH.include?(dir)

module CdnFu
  VERSION = 0.5
  # Do some sensible defaults for rails
  def self.init_rails(binding)
    cfg = CdnFu::Config.config
    cfg.asset_root_dir(File.join(RAILS_ROOT,'public'))
    cfg.tmp_dir(File.join(RAILS_ROOT,'tmp'))
    # If there is a RAILS_ASSET_ID use that.
    begin
      cfg.asset_id(RAILS_ASSET_ID)
    rescue NameError
    end
  end

  def self.load_rails_config
    cdn_fu_config_file = File.join(RAILS_ROOT,'config','cdn_fu.rb')
    if File.exists?(cdn_fu_config_file)
      eval(File.open(cdn_fu_config_file).read)
    end
  end
end

require 'cdn_fu/config_error'
require 'cdn_fu/config'
require 'cdn_fu/executor'
require 'cdn_fu/file_info.rb'
require 'cdn_fu/lister.rb'
require 'cdn_fu/minifier.rb'
require 'cdn_fu/uploader.rb'
["minifiers","listers","uploaders"].each do |subdir|
  Dir[File.join(File.dirname(__FILE__),'cdn_fu',subdir, "*")].each {|f| require f}
end
