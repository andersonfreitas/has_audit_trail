# HasAuditTrail [![Build Status](https://secure.travis-ci.org/andersonfreitas/has_audit_trail.png)](http://travis-ci.org/andersonfreitas/has_audit_trail)

## Disclaimer

This is **VERY** experimental, please wait until the release 0.1.0 before using it in production!

## Installation

Add this line to your application's Gemfile:

    gem 'has_audit_trail'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install has_audit_trail

## Usage

```ruby
class User < ActiveRecord::Base
  has_audit_trail
end
```

```ruby
class User < ActiveRecord::Base
  has_audit_trail :only => [ :name, :email ]
end
```

```ruby
class User < ActiveRecord::Base
  has_audit_trail :only => [ :name, :email, :projects => { :audit => Proc.new { |p| p.name } } ]
end
```

```ruby
class Project < ActiveRecord::Base
  has_many :tasks
  
  accepts_nested_attributes_for :tasks

  has_audit_trail(
    :audit_nested => {
      :tasks => {
        :label => Proc.new { |task| task.name },
        :value_print => Proc.new { |value| value }
      }
    }
  )
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
