class CdnFuMinifier
  class << self
    def validate_and_minify(file_list)
      attribute_validate
      validate
      minify(file_list)
    end

    def attribute_validate
      if @required_attributes
        @required_attributes.each do |attr|
          res = self.send(attr)
          if res.blank?
            raise CdnFuConfigError, "#{attr} must be specified in the configuration"
          end
        end
      end
    end

    def validate
    end

    def optional_attributes(*args)
      @optional_attributes ||= []
      @optional_attributes += args
      args.each do |arg|
        cattr_accessor arg.to_sym
      end
    end
    alias :optional_attribute :optional_attributes

    def required_attributes(*args)
      @required_attributes ||= []
      @required_attributes += args
      args.each do |arg|
        cattr_accessor arg.to_sym
      end
    end
    alias :required_attribute :required_attributes
  end
end
