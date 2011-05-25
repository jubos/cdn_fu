module CdnFu
  class FileInfo
    attr_accessor :local_path,:minified_path,:remote_path,:processed_path
    attr_writer :gzip,:minify,:preprocess

    def gzip?
      @gzip
    end

    def minify?
      @minify
    end

    def preprocess?
      @preprocess
    end
  end
end
