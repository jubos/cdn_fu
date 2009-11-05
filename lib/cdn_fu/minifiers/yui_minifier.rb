class YuiMinifier < CdnFu::Minifier
  required_attribute :yui_jar_path

  # Essentially iterate through through the files and if minify is specified call it.
  def minify(file_list)
    file_list.each do |cf_file|
      one_minification(cf_file) if cf_file.minify?
    end
  end

  # Custom validate method ensures that the jar specified will actually work.
  def validate
    if @yui_jar_path
      if File.exists?(@yui_jar_path)
        output = `java -jar #{@yui_jar_path}`
        if output !~ /java -jar yuicompressor-x\.y\.z\.jar/
          raise CdnFu::ConfigError,"Invalid YUI Compressor jar specified in cdn_fu.rb"
        end
      else
        raise CdnFu::ConfigError,"YUI Compressor jar specified in cdn_fu.rb does not exist"
      end
    else
      raise CdnFu::ConfigError,"You must specify a yui_jar_path for YUI Compressor"
    end
  end

  private

  def one_minification(file)
    modified_path = File.join(CdnFu::Config.config.tmp_dir,"minified_#{File.basename(file.local_path)}")
    `java -jar #{@yui_jar_path} #{file.local_path} > #{modified_path}`
    puts "[minify] #{file.local_path}" if CdnFu::Config.config.verbose
    file.minified_path = modified_path
  end
end
