$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'active_ums'
require 'webmock/rspec'

ActiveUMS.configure do |config|
  config.base_url = 'http://localhost:3000'
end

RSpec.configure do |config|
  config.before(:each) do
    class User < ActiveUMS::Base
      attribute :id
    end
  end

  config.after(:each) do
    Object.send(:remove_const, :User)
    WebMock.reset!
  end
end
