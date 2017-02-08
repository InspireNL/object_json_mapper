module ActiveUMS
  module Errors
    # @param messages [Hash]
    # @example
    #   load_errors(
    #     {
    #       "email": ["can't be blank"]
    #     }
    #   )
    def load_errors(messages)
      errors.clear

      messages.each do |key, value|
        errors.add(key.to_sym, value.first)
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
