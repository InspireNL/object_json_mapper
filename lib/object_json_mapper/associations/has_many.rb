module ObjectJSONMapper
  module Associations
    class HasMany < Association
      # @param object [ObjectJSONMapper::Base]
      # @return [ObjectJSONMapper::Relation]
      def call(object)
        klass.where.tap do |relation|
          relation.path = object.client[endpoint].url
        end
      end
    end
  end
end
