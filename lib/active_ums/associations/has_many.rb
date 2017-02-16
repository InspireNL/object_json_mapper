module ActiveUMS
  module Associations
    class HasMany < Association
      # @param object [ActiveUMS::Base]
      # @return [ActiveUMS::Relation]
      def call(object)
        class_name.classify.constantize.where.tap do |relation|
          relation.path = object.association_path(
            endpoint.to_s.underscore.pluralize
          )
        end
      end
    end
  end
end
