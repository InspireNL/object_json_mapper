require 'active_model'
require 'rest-client'
require 'json'

require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/object/to_query'
require 'active_support/core_ext/enumerable'

require 'object_json_mapper/version'

require 'object_json_mapper/associations/association'
require 'object_json_mapper/associations/has_many'
require 'object_json_mapper/associations/has_one'
require 'object_json_mapper/associations/registry'
require 'object_json_mapper/associations'
require 'object_json_mapper/conversion'
require 'object_json_mapper/serialization'
require 'object_json_mapper/persistence'
require 'object_json_mapper/errors'
require 'object_json_mapper/http'
require 'object_json_mapper/local'

require 'object_json_mapper/relation'
require 'object_json_mapper/null_relation'
require 'object_json_mapper/base'

if defined?(Kaminari)
  require 'object_json_mapper/extensions/kaminari'
end

module ObjectJSONMapper
  mattr_accessor :base_url, :headers

  def self.configure
    yield self
  end
end
