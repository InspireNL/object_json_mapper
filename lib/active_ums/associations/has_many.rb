module ActiveUMS
  module Associations
    class HasMany < Association
      # @param object [ActiveUMS::Base]
      # @return [ActiveUMS::Relation]
      def call(object)
        Wrapper.to_relation(
          object.class.get(
            object.class.association_path(
              object.to_param,
              endpoint.to_s.underscore.pluralize
            ),
            params: params
          ),
          class_name
        )
      end
    end
  end
end
