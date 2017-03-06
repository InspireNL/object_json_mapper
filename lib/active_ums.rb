require 'active_model'
require 'rest-client'
require 'json'

require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/object/to_query'
require 'active_support/core_ext/enumerable'

require 'active_ums/version'

require 'active_ums/associations/association'
require 'active_ums/associations/has_many'
require 'active_ums/associations/has_one'
require 'active_ums/associations/registry'
require 'active_ums/associations'
require 'active_ums/conversion'
require 'active_ums/errors'
require 'active_ums/http'
require 'active_ums/local'

require 'active_ums/relation'
require 'active_ums/null_relation'
require 'active_ums/base'

if defined?(Kaminari)
  require 'active_ums/extensions/kaminari'
end

module ActiveUMS
  mattr_accessor :base_url, :headers

  def self.configure
    yield self
  end
end
