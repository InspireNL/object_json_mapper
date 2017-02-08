module ActiveUMS
  # Helper methods to generate `ActiveUMS::Relation` and `ActiveUMS::Base` objects
  module Wrapper
    # Use for collection of records
    # @param collection [Array<Hash>,Array<ActiveUMS::Base>] in case of `Array<Hash>`,
    # attribute `class_name` should be provided.
    # @param class_name [String] name of the `ActiveUMS::Base` model
    # @return [ActiveUMS::Relation<ActiveUMS::Base>]
    def self.to_relation(collection, class_name = nil)
      return Relation.new(collection) unless class_name

      Relation.new(
        collection.map { |attributes| to_record(attributes, class_name) }
      )
    end

    # Use for single record
    # @param attributes [Hash]
    # @param class_name [String] name of the `ActiveUMS::Base` model
    # @return [ActiveUMS::Base]
    def self.to_record(attributes, class_name)
      class_name.to_s.classify.constantize.persist(attributes)
    end
  end
end
