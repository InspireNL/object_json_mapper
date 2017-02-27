module ActiveUMS
  module Local
    def self.included(base)
      base.extend(ClassMethods)
    end

    def local
      self.class.local.find_or_initialize_by(id: id)
    end

    def find_by_local(source, &scope)
      self.class.find_by_local(source, &scope)
    end

    module ClassMethods
      def local
        return @local if @local
        @local = Class.new(ActiveRecord::Base)
        @local.table_name = collection_name
        @local
      end

      # Allows you to apply filters from local model to remote data.
      #
      # @param source [ActiveUMS::Relation]
      # @param scope [Proc] scope to execute on local results
      # @return [ActiveUMS:Relation]
      #
      # @example
      #   class User < ActiveUMS::Base
      #     def self.local
      #       LocalUser
      #     end
      #   end
      #
      #   class LocalUser < ActiveRecord::Base
      #   end
      #
      #   User.find_by_local(User.all) do
      #     where(local_column: 'value')
      #   end
      #   # => GET http://example.com/users
      #   # => SELECT * FROM local_users WHERE local_column = 'value'
      def find_by_local(source, &scope)
        result = source.dup
        result_index = result.index_by(&:id)

        ActiveUMS::Wrapper.to_relation(
          result
            .locals
            .instance_exec(&scope)
            .pluck(:eid)
            .map { |eid| result_index[eid] }
        )
      end
    end
  end
end
