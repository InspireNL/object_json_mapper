module Kaminari
  module ObjectJSONMapper
    module ObjectJSONMapperExtension
      include Kaminari::ConfigurationMethods

      def self.included(base)
        page = lambda do |num|
          where(page: num, per_page: Kaminari.config.default_per_page)
        end

        base.define_singleton_method(Kaminari.config.page_method_name, &page)
        base.send(:define_method, Kaminari.config.page_method_name, &page)
      end
    end

    module ObjectJSONMapperCriteriaMethods
      def limit_value
        collection unless @limit_value
        @limit_value
      end

      def total_count
        collection unless @total_count
        @total_count
      end

      def total_pages
        return 1 if limit_value.zero?
        (total_count.to_f / limit_value).ceil
      end

      def offset_value
        limit_value * current_page
      end

      def current_page
        page = conditions[:page].to_i
        page > 0 ? page : 1
      end

      def max_pages
        total_count / offset_value
      end
    end
  end
end

ObjectJSONMapper::Base.send(:include, Kaminari::ObjectJSONMapper::ObjectJSONMapperExtension)
ObjectJSONMapper::Relation.send(:include, Kaminari::ObjectJSONMapper::ObjectJSONMapperExtension)
ObjectJSONMapper::Relation.send(:include, Kaminari::PageScopeMethods)
ObjectJSONMapper::Relation.send(:include, Kaminari::ObjectJSONMapper::ObjectJSONMapperCriteriaMethods)
