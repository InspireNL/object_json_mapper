module Kaminari
  module ActiveUMS
    module ActiveUMSExtension
      include Kaminari::ConfigurationMethods

      def self.included(base)
        base.define_singleton_method(Kaminari.config.page_method_name) do |num|
          where(page: num, per_page: Kaminari.config.default_per_page)
        end
      end
    end

    module ActiveUMSCriteriaMethods
      def limit_value
        collection
        @limit_value
      end

      def total_count
        collection
        @total_count
      end

      def total_pages
        (total_count.to_f / limit_value).ceil
      rescue ZeroDivisionError
        1
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

ActiveUMS::Base.send(:include, Kaminari::ActiveUMS::ActiveUMSExtension)
ActiveUMS::Relation.send(:include, Kaminari::ActiveUMS::ActiveUMSExtension)
ActiveUMS::Relation.send(:include, Kaminari::PageScopeMethods)
ActiveUMS::Relation.send(:include, Kaminari::ActiveUMS::ActiveUMSCriteriaMethods)
