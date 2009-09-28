class CdnFuUploader
  # These are class level methods, so that subclasses can do some light
  # metaprogramming to specify optional and required attributes
  class << self;
    def required_attributes( *arr ) 
      return @required_attributes if arr.size == 0
      @required_attributes ||= []
      arr.each do |a|
        @required_attributes << a.to_sym
        class_eval do 
          define_method(a.to_sym) do |*args|
            return instance_variable_get("@#{a}") if args.size == 0
            instance_variable_set("@#{a}",args[0])
          end
        end
      end
    end 

    def optional_attributes( *arr ) 
      return @optional_attributes if arr.size == 0
      @optional_attributes ||= []
      arr.each do |a|
        @optional_attributes << a.to_sym
        class_eval do 
          define_method(a.to_sym) do |*args|
            return instance_variable_get("@#{a}") if args.size == 0
            instance_variable_set("@#{a}",args[0])
          end
        end
      end
    end 

    # aliases just for syntactic sugar
    alias :required_attribute :required_attributes
    alias :optional_attribute :optional_attributes
  end

  def validate_and_upload(file_list)
    attribute_validate
    validate
    upload(file_list)
  end

  def attribute_validate
    if self.class.required_attributes
      self.class.required_attributes.each do |attr|
        res = self.send(attr)
        if res.blank?
          raise CdnFuConfigError, "#{attr} must be specified in the uploader configuration"
        end
      end
    end
  end

  def validate
  end
end
