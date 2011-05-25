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
        output = `java -jar #{@yui_jar_path} 2>&1`
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
    minified_dir = File.join(CdnFu::Config.config.tmp_dir,"cdnfu_minified",File.dirname(file.local_path))
    FileUtils.mkdir_p(minified_dir)
    minified_path = File.join(minified_dir,"minified_#{File.basename(file.local_path)}")
    input_path = file.processed_path ? file.processed_path : file.local_path
    `java -jar #{@yui_jar_path} #{input_path} > #{minified_path}`
    puts "[minify] #{input_path} to #{minified_path}" if CdnFu::Config.config.verbose
    file.minified_path = minified_path 
  end
end
