module ObjectJSONMapper
  module Associations
    # Base class for association builders
    #
    # @abstract
    class Association
      attr_reader :name, :params

      # @param name [Symbol]
      # @param options [Hash]
      # @option options [Object] :klass
      # @option options [String] :endpoint
      # @option options [Hash] :params
      def initialize(name, options = {})
        @name     = name
        @klass    = options.fetch(:class_name, name)
        @endpoint = options.fetch(:endpoint, name)
        @params   = options.fetch(:params, {})
      end

      def call(*)
        raise NotImplementedError
      end

      def klass
        return @klass.to_s.classify.constantize if @klass.is_a?(Symbol)

        @klass
      end

      def endpoint
        @endpoint.to_s.underscore
      end
    end
  end
end
