module ObjectJSONMapper
  module Associations
    class HasOne < Association
      # @param object [ObjectJSONMapper::Base]
      # @return [ObjectJSONMapper::Base]
      def call(object)
        klass.persist(
          HTTP.parse_json(object.client[endpoint].get.body)
        )
      end
    end
  end
end
