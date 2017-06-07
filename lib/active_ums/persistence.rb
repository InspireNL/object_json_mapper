module ActiveUMS
  module Persistence
    def self.included(base)
      base.extend(ClassMethods)
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

    # @return [ActiveUMS::Base]
    def reload
      tap do |base|
        base.attributes = HTTP.parse_json(client.get.body) if reloadable?
      end
    end

    module ClassMethods
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
