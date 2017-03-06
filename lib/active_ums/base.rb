module ActiveUMS
  class Base
    include ActiveModel::Validations
    include ActiveModel::Validations::Callbacks

    include Local
    include Conversion
    include Errors
    include Associations

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

    # @return [ActiveUMS::Base]
    def reload
      tap do |base|
        base.attributes = HTTP.parse_json(client.get.body) if reloadable?
      end
    end

    def reloadable?
      to_key.any?
    end

    def attributes=(value)
      @attributes = HashWithIndifferentAccess.new(value)
    end

    # TODO: remove (?)
    def method_missing(method_name, *args, &block)
      return attributes.fetch(method_name) if respond_to_missing?(method_name)
      super
    end

    # TODO: remove (?)
    def respond_to_missing?(name, *)
      attributes.key?(name)
    end

    # @return [ActiveUMS::Base,FalseClass]
    def save(*)
      return update(attributes) if persisted?

      response = self.class.client.post(attributes)

      result = if response.headers[:location]
                 RestClient.get(response.headers[:location], ActiveUMS.headers)
               else
                 response.body
               end

      persist
      errors.clear
      attributes.merge!(HTTP.parse_json(result))

      self
    rescue RestClient::ExceptionWithResponse => e
      raise e unless e.response.code == 422

      load_errors(HTTP.parse_json(e.response.body))

      false
    ensure
      validate
    end
    alias save! save

    # @param params [Hash]
    # @return [ActiveUMS::Base,FalseClass]
    def update(params = {})
      return false if new_record?

      client.patch(params)

      reload
      errors.clear

      self
    rescue RestClient::ExceptionWithResponse => e
      raise e unless e.response.code == 422

      load_errors(HTTP.parse_json(e.response.body))

      false
    end
    alias update_attributes update

    # @result [TrueClass,FalseClass]
    def destroy
      client.delete

      true
    rescue RestClient::ExceptionWithResponse
      false
    end
    alias delete destroy

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

      # @param name [Symbol]
      def path(name)
        warn '[DEPRECATION] Use `root`.'

        define_singleton_method(name) do
          where.tap do |relation|
            relation.path = client[name].url
          end
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

      # @param id [Integer]
      # @return [ActiveUMS::Base] current model instance
      def find(id)
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

      # @return [ActiveUMS::Relation<ActiveUMS::Base>] collection of model instances
      def all
        where
      end

      def none
        NullRelation.new(klass: self)
      end

      # @param params [Hash]
      # @return [ActiveUMS::Base] current model instance
      def create(params = {})
        response = client.post(params)

        result = if response.headers[:location]
                   RestClient.get(response.headers[:location], ActiveUMS.headers)
                 else
                   response.body
                 end

        persist(HTTP.parse_json(result))
      rescue RestClient::ExceptionWithResponse => e
        raise e unless e.response.code == 422

        new.tap do |base|
          base.load_errors(HTTP.parse_json(e.response.body))
        end
      end
    end
  end
end
