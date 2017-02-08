# ActiveUMS

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'active_ums'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install active_ums

## Usage

Set default url for your API in `config/initializers/active_ums.rb`:

```ruby
require 'active_ums'

ActiveUMS.configure do |config|
  config.base_url = 'http://localhost:3000'
end
```
