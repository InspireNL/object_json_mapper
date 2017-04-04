module ActiveUMS
  module Associations
    class HasOne < Association
      # @param object [ActiveUMS::Base]
      # @return [ActiveUMS::Base]
      def call(object)
        class_name.classify.constantize.persist(
          HTTP.parse_json(object.client[endpoint.to_s.underscore].get.body)
        )
      end
    end
  end
end
