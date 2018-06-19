require 'simplecov'
SimpleCov.start

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'object_json_mapper'
require 'webmock/rspec'

ObjectJSONMapper.configure do |config|
  config.base_url = 'http://localhost:3000'
end

RSpec.configure do |config|
  config.before(:each) do
    class User < ObjectJSONMapper::Base
      attribute :id
      attribute :email
      attribute :password
    end
  end

  config.after(:each) do
    Object.send(:remove_const, :User)
    WebMock.reset!
  end
end
