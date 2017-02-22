module ActiveUMS
  module HTTP
    def self.get(url, params = {})
      response = RestClient.get(url, params)

      parse_json(response.body)
    end

    def self.parse_json(json)
      JSON.parse(json, symbolize_names: true)
    rescue JSON::ParserError
      {}
    end
  end
end
