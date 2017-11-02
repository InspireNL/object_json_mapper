module ObjectJSONMapper
  module Associations
    class HasOne < Association
      # @param object [ObjectJSONMapper::Base]
      # @return [ObjectJSONMapper::Base]
      def call(object)
        attributes = object[name]
        attributes ||= HTTP.parse_json(object.client[endpoint].get.body)

        klass.persist(attributes)
      end
    end
  end
end
