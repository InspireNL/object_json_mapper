module ActiveUMS
  class Relation
    include Enumerable

    attr_accessor :conditions, :klass, :path

    delegate :each,
             :map,
             :first,
             :last,
             :empty?,
             :select!,
             :to_ary,
             :+,
             :inspect,
             to: :collection

    def initialize(options = {})
      @klass      ||= options[:klass]
      @collection ||= options.fetch(:collection, [])
      @conditions ||= options.fetch(:conditions, {})
      @path       ||= options.fetch(:path, klass.collection_path)
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
      deep_clone.tap { |relation| relation.conditions.merge!(conditions) }
    end

    # @return [Array,Array<Array>]
    def pluck(*attributes)
      map { |record| record.slice(*attributes).values }
        .tap { |result| result.flatten! if attributes.size == 1 }
    end

    def collection
      response = RestClient.get(path, params: conditions)

      @total_count = response.headers[:total].to_i
      @limit_value = response.headers[:per_page].to_i

      HTTP.parse_json(response.body).map { |attributes| klass.persist(attributes) }
    end

    def deep_clone
      clone.tap do |object|
        object.conditions = conditions.clone
      end
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
