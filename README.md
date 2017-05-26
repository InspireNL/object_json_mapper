# ActiveUMS

[![CircleCI](https://circleci.com/gh/InspireNL/ActiveUMS.svg?style=svg&circle-token=28455d7bc9acb59984023207070f1f4afdc60d15)](https://circleci.com/gh/InspireNL/ActiveUMS)

* [Installation](#installation)
* [Usage](#usage)
  * [Find](#find)
  * [Where](#where)
  * [Create](#create)
  * [Update](#update)
  * [Delete](#delete)
* [Attributes](#attributes)
  * [Defaults](#defaults)
  * [Coercion](#coercion)
* [Associations](#associations)
  * [HasMany](#hasmany)
  * [BelongsTo / HasOne](#belongsto--hasone)
* [Scope](#scope)
* [Pluck](#pluck)
* [None](#none)
* [Root](#root)
* [Configure](#configure)

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
  # Required
  config.base_url = 'http://localhost:3000'

  # Optional
  config.headers  = {
    'Authorization' => 'secret-token'
  }
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

Executes given `Proc` if value is `nil`.

```ruby
class User < ActiveUMS::Base
  attribute :created_at, default: -> { DateTime.now }
end
```

### Coercion

Expects a object with `#call` interface to return modified value.

```ruby
class User < ActiveUMS::Base
  attribute :created_at, type: Dry::Types['form.date_time']
end
```

## Associations

### HasMany

Returns a `Relation` with model objects.

```ruby
class User < ActiveUMS::Base
  has_many :posts
end

User.find(1).posts
# => GET http://localhost:3000/users/1/posts
```

### BelongsTo / HasOne

Returns a single model object.

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

## Scope

Defines a scope for current model and all it relations.
It's possible to chain `#where` methods and defined scopes in any order.

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

## Pluck

```ruby
User.where(published: true).pluck(:id, :email)
# => GET http://localhost:3000/users?published=true
# => [[1, 'first@example.com', [2, 'second@example.com']]
```

## None

Returns a chainable relation without records, wouldn't make any queries.

```ruby
User.none
# => []

User.where(id: 1).none
# => []

User.none.where(id: 1)
# => []
```

## Root

Allows to change resource path for model client.

```ruby
User.root('people').where(name: 'Name')
# => GET http://localhost:3000/people?name=Name
```

## Configure

Available options:

* `root_url` - resource path for current model.

```ruby
class User < ActiveUMS::Base
  configure do |c|
    c.root_url = 'people'
  end
end

User.all
# => GET http://localhost:3000/people

User.find(1)
# => GET http://localhost:3000/people/1

User.find(1).posts
# => GET http://localhost:3000/people/1
# => GET http://localhost:3000/people/1/posts
```

## License

ActiveUMS is released under the [MIT License](https://github.com/InspireNL/ActiveUMS/blob/master/LICENSE).

## About

ActiveUMS is maintained by [Inspire](https://inspire.nl).
