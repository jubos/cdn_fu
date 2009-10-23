module CdnFu
  class Minifier
    class << self

      def optional_attributes(*arr)
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
      alias :optional_attribute :optional_attributes

      def required_attributes(*arr)
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
      alias :required_attribute :required_attributes
    end

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
  end
end
