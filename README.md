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

Define class, e.g. `User`:

```ruby
class User < ActiveUMS::Base
end
```

### Find

```ruby
User.find(1)
# => GET http://localhost:3000/users/1
```

### Where

```ruby
User.where(id: 1)
# => GET http://localhost:3000/users?id=1

User.where(id: 1).where(name: 'Name')
# => GET http://localhost:3000/users?id=1&name=Name
```

### Create

```ruby
User.create(name: 'Name')
# => POST http://localhost:3000/users
# =>   {
# =>     name: 'Name'
# =>   }
```

### Update

```ruby
u = User.find(1)
u.update(name: 'Name')
# => PATCH http://localhost:3000/users/1
# =>   {
# =>     name: 'Name'
# =>   }
```

### Delete

```ruby
u = User.find(1)
u.delete
# => DELETE http://localhost:3000/users/1
```

## Attributes

### Defaults

```ruby
class User < ActiveUMS::Base
  attribute :created_at, default: -> { DateTime.now }
end
```

### Coercion

```ruby
class User < ActiveUMS::Base
  attribute :created_at, type: Dry::Types['form.date_time']
end
```

## Associations

### Has Many

```ruby
class User < ActiveUMS::Base
  has_many :posts
end

User.find(1).posts
# => GET http://localhost:3000/users/1/posts
```

### Belongs To / Has One

```ruby
class Post < ActiveUMS::Base
  belongs_to :user
  has_one :image
end

Post.find(1).user
# => GET http://localhost:3000/posts/1/user

Post.find(1).image
# => GET http://localhost:3000/posts/1/image
```

## Scopes

```ruby
class User < ActiveUMS::Base
  scope :published, -> { where(published: true) }
  scope :active, -> { where(active: true) }
end

User.published
# => GET http://localhost:3000/users?published=true

User.published.active
# => GET http://localhost:3000/users?published=true&active=true

User.published.where(active: true)
# => GET http://localhost:3000/users?published=true&active=true

User.where(active: true).published
# => GET http://localhost:3000/users?active=true&published=true
```

## Path

```ruby
class User < ActiveUMS::Base
  path :confirmed
end

User.confirmed.where(name: 'Name')
# => GET http://localhost:3000/users/confirmed?name=Name
```

## Pluck

```ruby
User.where(published: true).pluck(:id, :email)
# => GET http://localhost:3000/users?published=true
# => [[1, 'first@example.com', [2, 'second@example.com']]
```
