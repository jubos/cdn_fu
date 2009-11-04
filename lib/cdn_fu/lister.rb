module CdnFu
  class Lister
    def initialize
      @globs = []
      @files = []
    end
    def glob(name,options = {})
      options[:name] = name
      @globs << options
    end

    def file(name,options = {})
      options[:name] = name
      @files << options
    end

    def list
      file_infos ||= []
      asset_root = Config.config.asset_root_dir
      asset_root ||= Dir.pwd

      @globs.each do |glob|
        glob_str = glob[:name]
        Dir.glob(File.join(asset_root,glob_str)).each do |file|
          fi = FileInfo.new
          fi.local_path = File.expand_path(file)
          fi.gzip = glob[:gzip]
          fi.minify = glob[:minify]
          root_sub_path = fi.local_path.gsub(asset_root,'')
          glob_sub_path = root_sub_path.gsub(glob_str[0,glob_str.index('*')],'')
          fi.remote_path = glob[:path] ? File.join(glob[:path],glob_sub_path) : root_sub_path
          file_infos << fi
        end
      end

      @files.each do |file|
        fi = FileInfo.new
        fi.local_path = File.join(asset_root,file[:name])
        fi.gzip = file[:gzip]
        fi.minify = file[:minify]
        fi.remote_path = file[:path] ? file[:path] : fi.local_path.gsub(Config.config.asset_root_dir,'')
        file_infos << fi
      end
      file_infos
    end
  end
end
