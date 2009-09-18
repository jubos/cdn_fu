class YuiMinifier < CdnFuMinifier
  required_attribute :yui_jar_path

  # Essentially iterate through through the files and if minify is specified call it.
  def self.minify(file_list)
    file_list.each do |cf_file|
      one_minification(cf_file) if cf_file.minify?
    end
  end

  # Custom validate method ensures that the jar specified will actually work.
  def self.validate
    if YuiMinifier.yui_jar_path
      if File.exists?(YuiMinifier.yui_jar_path)
        output = `java -jar #{YuiMinifier.yui_jar_path}`
        if output !~ /java -jar yuicompressor-x\.y\.z\.jar/
          raise CdnFuConfigError,"Invalid YUI Compressor jar specified in cdn_fu.rb"
        end
      else
        raise CdnFuConfigError,"YUI Compressor jar specified in cdn_fu.rb does not exist"
      end
    else
      raise CdnFuConfigError,"You must specify a yui_jar_path for YUI Compressor"
    end
  end

  private

  def self.one_minification(file)
    modified_path = File.join(CdnFuConfig.tmp_dir,"minified_#{File.basename(file.local_path)}")
    `java -jar #{YuiMinifier.yui_jar_path} #{file.local_path} > #{modified_path}`
    puts "[minify] #{file.local_path}"
    file.minified_path = modified_path
  end
end
