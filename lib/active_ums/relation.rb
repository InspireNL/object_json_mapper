module ActiveUMS
  class Relation
    include Enumerable

    attr_accessor :collection, :conditions, :klass, :path

    delegate :each,
             :map,
             :first,
             :last,
             :empty?,
             :select,
             :select!,
             :to_ary,
             :+,
             :inspect,
             to: :collection

    def initialize(options = {})
      @klass      ||= options[:klass]
      @path       ||= options[:path]
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
      deep_clone.tap { |relation| relation.conditions.merge!(conditions) }
    end

    # @return [Array,Array<Array>]
    def pluck(*attributes)
      map { |record| record.slice(*attributes).values }
        .tap { |result| result.flatten! if attributes.size == 1 }
    end

    # TODO: refactor
    def collection
      return @collection if @collection.any? && conditions.empty?

      response = RestClient.get(path,
        (ActiveUMS.headers || {}).merge(params: prepare_params(conditions)))

      @total_count = response.headers[:total].to_i
      @limit_value = response.headers[:per_page].to_i

      @collection = HTTP.parse_json(response.body)
                        .map { |attributes| klass.persist(attributes) }
    end

    def deep_clone
      clone.tap do |object|
        object.conditions = conditions.clone
        object.collection = @collection.clone
      end
    end

    def none
      NullRelation.new(klass: klass, conditions: conditions)
    end

    # Find and return relation of local records by `eid`
    # @return [ActiveRecord::Relation]
    def locals
      return [] if collection.empty?

      klass.where(id: collection.map(&:id))
    end

    private

      def prepare_params(conditions)
        conditions.deep_merge(conditions) do |_, _, value|
          case value
          when Array
            value.join(',')
          else
            value
          end
        end
      end

      def path
        @path || klass.client.url
      end
  end
end
