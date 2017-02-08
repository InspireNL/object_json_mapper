module ActiveUMS
  module Associations
    class HasOne < Association
      # @param object [ActiveUMS::Base]
      # @return [ActiveUMS::Base]
      def call(object)
        Wrapper.to_record(
          object.class.get(
            object.association_path(endpoint),
            params: params
          ),
          class_name
        )
      end
    end
  end
end
