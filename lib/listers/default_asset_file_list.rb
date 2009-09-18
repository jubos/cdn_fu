# The DefaultAssetFileList looks at the RAILS_ROOT/public directory and gets
# all of the .css and .js and image files.  It gives them default virtual paths
# of /stylesheets, /javascripts, and /images respectively
# Also it defaults to minification and gziping of js and css files
class DefaultAssetFileList
  def self.list
    file_list = []
    start_dir = Dir.pwd
    dirs = ["public/stylesheets","public/javascripts","public/images"]
    dirs.each do |dir|
      full_dir = File.join(RAILS_ROOT,dir)
      Dir.chdir(full_dir)
      Dir.glob("**/*").each do |path|
        if File.file?(path)
          cf_file = CdnFuFile.new
          cf_file.local_path = File.join(full_dir,path)
          cf_file.remote_path = File.basename(full_dir) + "/" + path
          if path =~ /(\.css$)|(.js$)/
            cf_file.minify = true
            cf_file.gzip = true
          end
          file_list << cf_file
        end
      end
    end
    file_list
  end
end
