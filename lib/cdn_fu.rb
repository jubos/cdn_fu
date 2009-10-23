dir = File.dirname(__FILE__)
$LOAD_PATH.unshift dir unless $LOAD_PATH.include?(dir)

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
