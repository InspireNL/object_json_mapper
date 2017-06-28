module ActiveUMS
  class Base
    include ActiveModel::Validations
    include ActiveModel::Validations::Callbacks

    include Local
    include Conversion
    include Serialization
    include Errors
    include Associations
    include Persistence

    extend ActiveModel::Callbacks

    attr_accessor :persisted, :attributes

    define_model_callbacks :save, :create, :update, :destroy, :validation

    delegate :slice, :[], :[]=, to: :attributes

    def initialize(attributes = {})
      self.attributes = attributes
      @persisted = false
    end

    alias persisted? persisted

    def new_record?
      !persisted?
    end

    def persist
      @persisted = true
    end

    def reloadable?
      to_key.any?
    end

    # @param value [Hash]
    def attributes=(value)
      @attributes = HashWithIndifferentAccess.new(value)

      @attributes.each do |method_name, _|
        define_singleton_method(method_name) do
          @attributes[method_name]
        end
      end
    end

    def ==(other)
      attributes == other.attributes && persisted == other.persisted
    end

    def client
      self.class.client[id]
    end

    class << self
      attr_accessor :associations, :relation, :root_url

      def inherited(base)
        base.root_url     = base.name.underscore.pluralize
        base.associations = Associations::Registry.new
        base.relation     = Relation.new(klass: base)
      end

      def client
        RestClient::Resource.new(
          URI.join(ActiveUMS.base_url, root_url).to_s,
          headers: ActiveUMS.headers
        )
      end

      def configure
        yield self
      end

      def name=(value)
        @name = value.to_s
      end

      def name
        @name || super
      end

      # @param name [Symbol]
      # @param type [Dry::Types::Constructor]
      # @param default [Proc]
      def attribute(name, type: nil, default: nil)
        define_method(name) do
          return default.call if attributes.exclude?(name) && default
          return type.call(attributes[name]) if type

          attributes[name]
        end

        define_method("#{name}=") do |value|
          attributes[name] = value
        end
      end

      # @param name [Symbol]
      # @param block [Proc]
      def scope(name, block)
        define_singleton_method(name) do
          relation.deep_clone.instance_exec(&block)
        end

        relation.define_singleton_method(name) do
          instance_exec(&block)
        end
      end

      def root(value)
        clone.tap do |base|
          base.name     = name
          base.root_url = value.to_s
        end
      end

      # Same as `new` but for persisted records
      # @param attributes [Hash]
      # @return [ActiveUMS::Base]
      def persist(attributes = {})
        new(attributes).tap do |base|
          base.persisted = true
        end
      end

      # @param conditions [Hash]
      # @return [ActiveUMS::Relation<ActiveUMS::Base>] collection of model instances
      def where(conditions = {})
        relation.tap { |relation| relation.klass = self }.where(conditions)
      end
      alias all where

      # @param id [Integer]
      # @return [ActiveUMS::Base] current model instance
      def find(id)
        raise ActiveRecord::RecordNotFound if id.nil?

        result = HTTP.parse_json(client[id].get.body)

        persist(result)
      rescue RestClient::ExceptionWithResponse
        raise ActiveRecord::RecordNotFound
      end

      # rubocop:disable Rails/FindBy
      #
      # @param conditions [Hash]
      # @return [ActiveUMS::Base] current model instance
      def find_by(conditions = {})
        where(conditions).first
      end

      def none
        NullRelation.new(klass: self)
      end
    end
  end
end
