module ActiveUMS
  module Associations
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      # rubocop:disable Style/PredicateName
      #
      # @param association_name [Symbol]
      # @param class_name [Symbol]
      # @return [ActiveUMS::Relation<ActiveUMS::Base>]
      #
      # @example Basic usage
      #   class User < ActiveUMS::Base
      #     has_many :products
      #   end
      #
      #   User.find(1).products
      #   # GET http://localhost:3000/v1/users/1/products
      #   # => #<ActiveUMS::Relation @collection=[<Product>...]>
      #
      # @example With class_name
      #   class User < ActiveUMS::Base
      #     has_many :things, class_name: :products
      #   end
      #
      #   User.find(1).things
      #   # GET http://localhost:3000/v1/users/1/things
      #   # => #<ActiveUMS::Relation @collection=[<Product>...]>
      #
      # @example With endpoint
      #   class User < ActiveUMS::Base
      #     has_many :products, endpoint: :things
      #   end
      #
      #   User.find(1).products
      #   # GET http://localhost:3000/v1/users/1/things
      #   # => #<ActiveUMS::Relation @collection=[<Product>...]>
      #
      # @example With params
      #   class User < ActiveUMS::Base
      #     has_many :products, params: { status: :active }
      #   end
      #
      #   User.find(1).products
      #   # GET http://localhost:3000/v1/users/1/products?status=active
      #   # => #<ActiveUMS::Relation @collection=[<Product>...]>
      def has_many(name, options = {})
        associations << HasMany.new(name, options)

        define_method(name) do |reload = false|
          cache_name = :"@#{__method__}"

          if instance_variable_defined?(cache_name) && reload == false
            return instance_variable_get(cache_name)
          end

          instance_variable_set(
            cache_name,
            self.class.associations.find(__method__).call(self)
          )
        end
      end

      # @param association_name [Symbol]
      # @return [ActiveUMS::Base]
      #
      # @example Basic usage
      #   class User < ActiveUMS::Base
      #     has_one :profile
      #   end
      #
      #   User.find(1).profile
      #   # GET http://localhost:3000/v1/users/1/profile
      #   # => #<ActiveUMS::Base @attributes={...}>
      def has_one(name, options = {})
        associations << HasOne.new(name, options)

        define_method(name) do |reload = false|
          cache_name = :"@#{__method__}"

          if instance_variable_defined?(cache_name) && reload == false
            return instance_variable_get(cache_name)
          end

          instance_variable_set(
            cache_name,
            self.class.associations.find(__method__).call(self)
          )
        end
      end
      alias belongs_to has_one
    end
  end
end
