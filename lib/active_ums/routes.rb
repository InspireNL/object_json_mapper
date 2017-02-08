module ActiveUMS
  module Routes
    def self.included(base)
      base.extend(ClassMethods)
    end

    def association_path(name)
      self.class.association_path(id, name)
    end

    module ClassMethods
      def collection_name
        name.underscore.pluralize
      end

      def element_path(id)
        File.join(ActiveUMS.base_url, collection_name, id.to_s).to_s
      end

      def collection_path(attributes = {})
        result = File.join(ActiveUMS.base_url, collection_name).to_s

        result.tap do |r|
          r << "?#{attributes.to_query}" if attributes.any?
        end
      end

      def association_path(id, name)
        File.join(ActiveUMS.base_url, collection_name, id.to_s, name.to_s).to_s
      end
    end

    private

    def element_path
      self.class.element_path(id)
    end
  end
end
