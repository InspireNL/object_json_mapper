module ActiveUMS
  class Relation
    include Enumerable

    attr_reader :collection

    delegate :each,
             :first,
             :last,
             :empty?,
             :select!,
             :to_ary,
             :+,
             to: :collection

    def initialize(collection)
      @collection = collection
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

    # Find and return relation of local records by `eid`
    # @return [ActiveRecord::Relation]
    def locals
      return if collection.empty?

      klass = collection.first.class.local
      klass.where(eid: collection.map(&:id))
    end
  end
end
