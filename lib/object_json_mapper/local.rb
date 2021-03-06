module ObjectJSONMapper
  module Local
    def self.included(base)
      base.extend(ClassMethods)
    end

    def local
      @local ||= self.class.local.find_or_initialize_by(id: id)
      # sometimes local fetched before remote was saved, thus there is no id
      @local.id ||= id
      @local
    end

    def find_by_local(source, &scope)
      self.class.find_by_local(source, &scope)
    end

    module ClassMethods
      def local
        return @local if @local
        @local = Class.new(ActiveRecord::Base)
        @local.table_name = name.underscore.pluralize
        @local
      end

      # Allows you to apply filters from local model to remote data.
      #
      # @param source [ObjectJSONMapper::Relation]
      # @param scope [Proc] scope to execute on local results
      # @return [ObjectJSONMapper:Relation]
      #
      # @example
      #   class User < ObjectJSONMapper::Base
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
      #   # => SELECT * FROM local_users WHERE local_column = 'value'
      #   # => GET http://example.com/users?id_in=1,2,3
      def find_by_local(source, &scope)
        source.where(
          id_in: source.klass
                       .local
                       .all
                       .instance_exec(&scope)
                       .pluck(:id)
        )
      end
    end
  end
end
