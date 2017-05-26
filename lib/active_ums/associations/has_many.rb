module ActiveUMS
  module Associations
    class HasMany < Association
      # @param object [ActiveUMS::Base]
      # @return [ActiveUMS::Relation]
      def call(object)
        klass.where.tap do |relation|
          relation.path = object.client[endpoint].url
        end
      end
    end
  end
end
