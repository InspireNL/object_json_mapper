module ActiveUMS
  module Associations
    class HasMany < Association
      # @param object [ActiveUMS::Base]
      # @return [ActiveUMS::Relation]
      def call(object)
        class_name.classify.constantize.where.tap do |relation|
          relation.path = object.client[endpoint.to_s.underscore.pluralize].url
        end
      end
    end
  end
end
