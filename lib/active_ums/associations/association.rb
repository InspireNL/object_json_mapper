module ActiveUMS
  module Associations
    # Base class for association builders
    #
    # @abstract
    class Association
      attr_reader :name, :class_name, :endpoint, :params

      # @param name [Symbol]
      # @param options [Hash]
      # @option options [Symbol] :class_name
      # @option options [Symbol] :endpoint
      # @option options [Hash] :params
      def initialize(name, options = {})
        @name       = name
        @class_name = options.fetch(:class_name, name.to_s)
        @endpoint   = options.fetch(:endpoint, name.to_s)
        @params     = options.fetch(:params, {})
      end

      def call(*)
        raise NotImplementedError
      end
    end
  end
end
