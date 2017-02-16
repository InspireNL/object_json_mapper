module ActiveUMS
  module Associations
    class HasOne < Association
      # @param object [ActiveUMS::Base]
      # @return [ActiveUMS::Base]
      def call(object)
        attributes = HTTP.get(object.association_path(endpoint), params)

        class_name.classify.constantize.new(attributes)
      end
    end
  end
end
