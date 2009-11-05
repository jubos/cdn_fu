module CdnFu
  # This is just a storage class for the configuration for CdnFu
  class Config
    def self.configure(&block)
      @@cfg ||= Config.new
      @@cfg.instance_eval &block if block_given?
      @@cfg
    end

    def self.clear
      @@cfg = nil
    end

    def self.config
      @@cfg ||= Config.new
      @@cfg
    end

    # Make a lister object 
    def initialize
      @lister = Lister.new
    end

    # Accessors
    def asset_id(*args)
      return @asset_id if args.size == 0
      @asset_id = args[0]
    end

    def verbose(*args)
      return @verbose if args.size == 0
      @verbose = args[0]
    end

    def asset_root_dir(*args)
      return @asset_root_dir if args.size == 0
      asset_root = args.first
      # TODO add default separator so it works on windows
      if asset_root[0,1] == '/'
        @asset_root_dir = File.expand_path(asset_root)
      else
        @asset_root_dir = File.expand_path(File.join(Dir.pwd,asset_root))
      end
    end

    def tmp_dir(*args)
      return @tmp_dir if args.size == 0
      @tmp_dir = args[0]
    end

    def prepare_and_upload
      @tmp_dir ||= "/tmp"
      FileUtils.mkdir_p(@tmp_dir)

      case @preprocessor
      when Proc
        @preprocessor.call
      when Class
        @preprocessor.preprocess
      end

      file_list = @lister.list

      case @minifier
      when Proc
        @minifier.call(file_list)
      when CdnFu::Minifier
        @minifier.validate_and_minify(file_list)
      end

      case @uploader
      when Proc
        @uploader.call(file_list)
      when CdnFu::Uploader
        @uploader.validate_and_upload(file_list)
      end
    end

    def preprocess
      if block_given?
        @preprocessor = proc
      else 
        raise ConfigError,"No preprocess block given"
      end
    end

    def preprocessor(klass)
      @preprocessor = klass
      yield @preprocessor if block_given?
    end

    def files(&block)
      if block_given?
        @lister.instance_eval &block
      else
        @lister.list
      end
    end

    def minify(&block)
      if block_given?
        @minifier = block 
      else
        raise ConfigError,"No minify block given"
      end
    end

    def minifier(*args,&block)
      return @minifier if args.size == 0
      minifier_class = args[0]
      @minifier = minifier_class.new
      @minifier.instance_eval &block if block_given?
    end

    def upload(&block)
      if block_given?
        @uploader = block
      else
        raise CdnFuConfigError,"No upload block given"
      end
    end

    def uploader(*args,&block)
      return @uploader if args.size == 0
      uploader_class = args[0]
      @uploader = uploader_class.new
      @uploader.instance_eval &block if block_given?
    end
  end
end

# Here we read in the config file
#cf_config_path = File.join(RAILS_ROOT,"config/cdn_fu.rb")
#if File.exists?(cf_config_path)
#  require cf_config_path
#else
#  puts "Please make a cdn_fu.rb file in RAILS_ROOT/config/ using rake cdn:init"
#end
