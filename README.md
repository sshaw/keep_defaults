# Keep Defaults

[![Build Status](https://travis-ci.org/sshaw/keep_defaults.svg?branch=master)](https://travis-ci.org/sshaw/keep_defaults)

Prevent ActiveRecord attributes for `not null` columns with default values from being set to `nil`.

Why is this necessary? Take this example:
```rb
class OrderItem < ApplicationRecord
  # Has column: total numeric(11,2) not null default 0
  # Validation etc...
end

class Order < ApplicationRecord
  # Has columns: total and taxes, both numeric(11,2) not null default 0
  # Validation etc...

  has_many :order_items

  def total
    order_items.sum(&:total) + taxes
  end
end
```

The columns have a default value of `0`, but the attributes can still be set to `nil`.
This can make for code that is far from bulletproof:
```rb
o = Order.new
o.total  # 0
o.taxes = nil
o.total  # 💥 TypeError: nil can't be coerced into Fixnum
```

To fix you can do something like:
```rb
class Order < ApplicationRecord
  def total
    order_items.sum(&:total) + taxes.to_f
  end
end
```

But `OrderItem#total` can be set to `nil` too. You can do:
```rb
class OrderItem < ApplicationRecord
  def total
    super || 0
  end
end
```

But what about the other contexts in which these can be called or the other attributes you may have? This can get tedious.

With Keep Defaults:
```rb
class ApplicationRecord < ActiveRecord::Base
  include KeepDefaults
end
```

```rb
o = Order.new
o.total  # 0
o.taxes = nil
o.total  # 0
o.taxes  # 0
```

Now if an attribute is set to `nil` it will retain its default value instead.

## Installation

Add this line to your application's `Gemfile`:

```rb
gem "keep_defaults"
```

Or

```rb
gem install keep_defaults
```

## Usage

To use everywhere add to `ApplicationRecord`:

```rb
class ApplicationRecord < ActiveRecord::Base
  include KeepDefaults
end
```

To use for a specific class add it directly to that class:

```rb
class Order < ApplicationRecord
  include KeepDefaults
end
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
