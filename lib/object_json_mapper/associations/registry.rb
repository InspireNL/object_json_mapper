module ObjectJSONMapper
  module Associations
    # Collection of model associations
    class Registry
      include Enumerable

      attr_reader :associations

      delegate :[],
               :[]=,
               :<<,
               to: :associations

      def initialize
        @associations = []
      end

      # @param name [Symbol]
      # @return [ObjectJSONMapper::Associations::Association]
      def find(name)
        associations.find { |a| a.name == name }
      end
    end
  end
end
