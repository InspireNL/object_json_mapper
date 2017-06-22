module ObjectJSONMapper
  module Conversion
    def to_model
      self
    end

    # @return [Array] all key attributes
    def to_key
      [].tap do |a|
        a << id if respond_to?(:id)
      end
    end

    # @return [String] object's key suitable for use in URLs
    def to_param
      id.to_s
    end

    def to_partial_path
      name = self.class.name.underscore
      [name.pluralize, name].join('/')
    end
  end
end
