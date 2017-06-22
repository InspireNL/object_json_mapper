module ObjectJSONMapper
  module Errors
    # @param messages [Hash]
    # @example
    #   load_errors(
    #     {
    #       "email": ["blank"]
    #     }
    #   )
    def load_errors(messages)
      errors.clear
      messages.each do |key, values|
        values.each do |value|
          case value
          when String
            errors.add(key, value)
          when Hash
            errors.add(key, value[:error].to_sym, value.except(:error))
          end
        end
      end
    end

    # In comparison with `ActiveModel::Validations#valid?`
    # we should not clear errors because it would clear remote errors as well,
    # but we can remove duplicates in the error messages
    # @return [TrueClass,FalseClass]
    def valid?(context = nil)
      current_context, self.validation_context = validation_context, context
      run_validations!
    ensure
      errors.messages.each { |_, v| v.uniq! }
      self.validation_context = current_context
    end
    alias validate valid?
  end
end
