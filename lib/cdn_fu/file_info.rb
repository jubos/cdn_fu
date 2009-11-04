module CdnFu
  class FileInfo
    attr_accessor :local_path,:minified_path,:remote_path
    attr_writer :gzip,:minify

    def gzip?
      @gzip
    end

    def minify?
      @minify
    end
  end
end
