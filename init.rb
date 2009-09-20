require 'rubygems'
require 'aws/s3'
require 'fileutils'
require 'stringio'
require 'zlib'

ActionController::Base.class_eval do
  cattr_accessor :cdn_fu_config
end
ActionController::Base.cdn_fu_config= CdnFuConfig
