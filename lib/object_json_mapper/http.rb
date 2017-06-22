module ObjectJSONMapper
  module HTTP
    def self.parse_json(json)
      JSON.parse(json, symbolize_names: true)
    rescue JSON::ParserError
      {}
    end
  end
end
