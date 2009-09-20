#Since CdnFuConfig is the entry point to the library from rails, make sure we
#have everything else required here
Dir[File.join(File.dirname(__FILE__),"*.rb")].each {|f| require f if f !~ /cdn_fu_config.rb/}
["minifiers","listers","uploaders"].each do |subdir|
  Dir[File.join(File.dirname(__FILE__),subdir, "*")].each {|f| require f}
end

class Object
  def cdn_metaclass
    class << self
      self
    end
  end

  def cdn_meta_eval(&block)
    puts "Evaling in #{self.class}"
    cdn_metaclass.class_eval(&block)
  end
end

# This is just a storage class for the configuration for CdnFu
class CdnFuConfig
  cattr_accessor :asset_id,:tmp_dir

  def self.configure
    yield self
  end

  def self.prepare_and_upload
    self.tmp_dir ||= File.join(RAILS_ROOT,"tmp","minified")
    FileUtils.mkdir_p(self.tmp_dir)

    case @preprocessor
    when Proc
      @preprocessor.call
    when Class
      @preprocessor.preprocess
    end

    # We have a default file lister for Rails Assets
    @lister ||= Proc.new { DefaultAssetFileList.list }
    file_list = []
    case @lister
    when Proc
      file_list = @lister.call
    when Class
      file_list = @lister.list
    end

    case @minifier
    when Proc
      @minifier.call(file_list)
    when Class
      @minifier.validate_and_minify(file_list)
    end

    case @uploader
    when Proc
      @uploader.call(file_list)
    when Class
      @uploader.validate_and_upload(file_list)
    end
  end

  # Do some metaprogramming here for setting up different behaviors
  class << self
    def preprocess
      if block_given?
        @preprocessor = proc
      else 
        raise CdnFuConfigError,"No preprocess block given"
      end
    end

    def preprocessor(klass)
      @preprocessor = klass
      yield @preprocessor if block_given?
    end

    def list
      if block_given?
        @lister = proc
      else
        raise CdnFuConfigError,"No Block Given"
      end
    end

    def lister=(lister_class)
      @lister = lister_class
    end

    def minify
      if block_given?
        @minifier = proc
      else
        raise CdnFuConfigError,"No Block Given for Minifier"
      end
    end

    def minifier(minifier_class)
      @minifier = minifier_class
      yield @minifier if block_given?
    end

    def upload
      if block_given?
        @uploader = proc
      else
        raise CdnFuConfigError,"No Block Given"
      end
    end

    def uploader(uploader_class)
      @uploader = uploader_class
      yield @uploader if block_given?
    end
  end
end

# Here we read in the config file
cf_config_path = File.join(RAILS_ROOT,"config/cdn_fu.rb")
if File.exists?(cf_config_path)
  require cf_config_path
else
  puts "Please make a cdn_fu.rb file in RAILS_ROOT/config/ using rake cdn:init"
end
