module ActiveUMS
  class Relation
    include Enumerable

    attr_accessor :conditions, :klass

    delegate :each,
             :first,
             :last,
             :empty?,
             :select!,
             :to_ary,
             :+,
             to: :collection

    def initialize(options = {})
      @klass      ||= options[:klass]
      @collection ||= options.fetch(:collection, [])
      @conditions ||= options.fetch(:conditions, {})
    end

    def find_by(conditions = {})
      collection.find do |record|
        conditions.all? { |k, v| record.public_send(k) == v }
      end
    end

    def find(id)
      find_by(id: id.to_i)
    end

    def exists?(id)
      find(id).present?
    end

    def where(conditions = {})
      clone.tap { |relation| relation.conditions.merge!(conditions) }
    end

    def inspect
      collection.inspect
    end

    def collection
      HTTP.get(klass.collection_path, params: conditions)
          .map { |attributes| klass.persist(attributes) }
    end

    # Find and return relation of local records by `eid`
    # @return [ActiveRecord::Relation]
    def locals
      return if collection.empty?

      klass = collection.first.class.local
      klass.where(eid: collection.map(&:id))
    end
  end
end
