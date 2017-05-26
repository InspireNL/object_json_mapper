module ActiveUMS
  module Associations
    class HasOne < Association
      # @param object [ActiveUMS::Base]
      # @return [ActiveUMS::Base]
      def call(object)
        klass.persist(
          HTTP.parse_json(object.client[endpoint].get.body)
        )
      end
    end
  end
end
