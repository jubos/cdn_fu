require 'rubygems'
require 'aws/s3'
require 'fileutils'
require 'stringio'
require 'zlib'


#Dir[File.join(File.dirname(__FILE__),"lib","*.rb")].each {|f| require f}
["minifiers","listers","uploaders"].each do |subdir|
  Dir[File.join(File.dirname(__FILE__),"lib",subdir, "*")].each {|f| require f}
end

ActionController::Base.class_eval do
  cattr_accessor :cdn_fu_config
end
ActionController::Base.cdn_fu_config= CdnFuConfig
