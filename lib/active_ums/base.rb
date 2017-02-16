module ActiveUMS
  class Base
    include ActiveModel::Validations
    include ActiveModel::Validations::Callbacks

    include Local
    include Conversion
    include Routes
    include Errors
    include Associations

    extend ActiveModel::Callbacks

    attr_accessor :persisted, :attributes

    define_model_callbacks :save, :create, :update, :destroy, :validation

    delegate :slice, :[]=, to: :attributes

    def initialize(attributes = {})
      self.attributes = attributes
      self.persisted = false
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
      self.attributes = HTTP.get(element_path) if reloadable?

      self
    end

    def reloadable?
      to_key.any?
    end

    def attributes=(value)
      @attributes = HashWithIndifferentAccess.new(value)
    end

    def [](name)
      public_send(name)
    end

    # TODO: remove (?)
    def method_missing(method_name, *args, &block)
      super(method_name, *args, &block) unless respond_to_missing?(method_name)

      attributes.fetch(method_name)
    end

    # TODO: remove (?)
    def respond_to_missing?(name, *)
      attributes.key?(name)
    end

    # @return [ActiveUMS::Base,FalseClass]
    def save(*)
      return update(attributes) if persisted?

      response = RestClient.post(self.class.collection_path, attributes)

      result = if response.headers[:location]
        HTTP.get(response.headers[:location])
      else
        HTTP.parse_json(response.body)
      end

      persist
      errors.clear
      attributes.merge!(result)

      self
    rescue RestClient::ExceptionWithResponse => e
      raise e unless e.response.code == 422

      load_errors(
        HTTP.parse_json(e.response.body)
      )

      false
    ensure
      validate
    end
    alias save! save

    # @param params [Hash]
    # @return [ActiveUMS::Base,FalseClass]
    def update(params = {})
      return false if new_record?

      RestClient.patch(self.class.element_path(id), params)

      reload
      errors.clear

      self
    rescue RestClient::ExceptionWithResponse => e
      raise e unless e.response.code == 422

      load_errors(
        HTTP.parse_json(e.response.body)
      )

      false
    end
    alias update_attributes update

    # @result [TrueClass,FalseClass]
    def destroy
      RestClient.delete(self.class.element_path(id))

      true
    rescue RestClient::ExceptionWithResponse
      false
    end
    alias delete destroy

    def ==(other)
      attributes == other.attributes && persisted == other.persisted
    end

    class << self
      # @param name [Symbol]
      # @param type [Dry::Types::Constructor]
      # @param default [Proc]
      def attribute(name, type: nil, default: nil)
        define_method name do
          return default.call if attributes.exclude?(name) && default
          return type.call(attributes[name]) if type

          attributes[name]
        end

        define_method "#{name}=" do |value|
          attributes[name] = value
        end
      end

      # @param name [Symbol]
      # @param block [Proc]
      def scope(name, block)
        define_singleton_method(name) do
          where.tap do |relation|
            relation.instance_exec(&block)
          end
        end
      end

      # @param name [Symbol]
      def path(name)
        define_singleton_method(name) do
          where.tap do |relation|
            relation.path = File.join(collection_path, name.to_s)
          end
        end
      end

      # Same as `new` but for persisted records
      # @param attributes [Hash]
      # @return [ActiveUMS::Base]
      def persist(attributes = {})
        instance = new(attributes)
        instance.persisted = true
        instance
      end

      # @param conditions [Hash]
      # @return [ActiveUMS::Relation<ActiveUMS::Base>] collection of model instances
      def where(conditions = {})
        Relation.new(klass: self).where(conditions)
      end

      # @param id [Integer]
      # @return [ActiveUMS::Base] current model instance
      def find(id)
        result = HTTP.get(element_path(id))

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

      # @param params [Hash]
      # @return [ActiveUMS::Base] current model instance
      def create(params = {})
        response = RestClient.post(collection_path, params)

        result = if response.headers[:location]
                   HTTP.get(response.headers[:location])
                 else
                   HTTP.parse_json(response.body)
                 end

        persist(result)
      rescue RestClient::ExceptionWithResponse => e
        raise e unless e.response.code == 422

        result = new

        result.load_errors(
          HTTP.parse_json(e.response.body)
        )

        result
      end
    end
  end
end
