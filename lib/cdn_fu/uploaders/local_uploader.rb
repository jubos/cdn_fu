require 'fileutils'
require 'pathname'
class LocalUploader < CdnFu::Uploader
  required_attribute :path

  def validate
    path = @path
    if !@path
      raise CdnFu::ConfigError, "Please specify a path for LocalUploader"
    end

    @path_obj = Pathname.new(@path)
    if !@path_obj.absolute?
      raise CdnFu::ConfigError, "Please specify an absolute path"
    end

    if File.exists?(@path) and !FileTest.directory?(@path)
      raise CdnFu::ConfigError, "LocalUploader path must be a directory"
    end

  end

  # Here we just iterate through the files
  def upload(file_list)
    FileUtils.mkdir_p(@path) if !File.exists?(@path)
    file_list.each do |file|
      path_to_copy = file.minified_path
      path_to_copy ||= file.local_path
      destination = File.join(@path,file.remote_path)
      dest_dir = File.dirname(destination)
      FileUtils.mkdir_p(dest_dir) if !File.exists?(dest_dir)
      FileUtils.cp path_to_copy,dest_dir
    end
  end
end
