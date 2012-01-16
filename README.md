# Solid

Solid aim to provide a easier and nicer API to create custom Liquid tags and blocks

## Installation

Due to a name conflict the gem is called tigerlily-solid. So to use it:

```
gem 'tigerlily-solid', :require => 'solid'
```

## Build Status [![Build Status](https://secure.travis-ci.org/tigerlily/solid.png)](http://travis-ci.org/tigerlily/solid)

## Tags

To create a new tag, you just have to:

  - Extend `Solid::Tag`
  - Define a `display` method
  - Give a `tag_name`

```ruby
class DummyTag < Solid::Tag

  tag_name :dummy # register in Liquid under the name of `dummy`

  def display
    'dummy !!!'
  end

end
```

```html
<p>{% dummy %}<p>
```

## Arguments

This is the simpliest tag ever but, Solid tags can receive rich arguments:

```ruby
class TypeOfTag < Solid::Tag

  tag_name :typeof

  def display(*values)
    ''.tap do |output|
      values.each do |value|
        output << "<p>Type of #{value} is #{value.class.name}</p>"
      end
    end
  end

end
```

```html
{% capture myvar %}eggspam{% endcapture %}
{% typeof "foo", 42, 4.2, myvar, myoption:"bar", otheroption:myvar %}
<!-- produce -->
<p>Type of "foo" is String</p>
<p>Type of 42 is Integer</p>
<p>Type of 4.2 is Float</p>
<p>Type of "eggspam" is String</p>
<p>Type of {:myoption=>"bar", :otheroption=>"eggspam"} is Hash</p>
```

## Context attributes

If there is some "global variables" in your liquid context you can declare that
your tag need to access it:

```ruby
class HelloTag < Solid::Tag

  tag_name :hello

  context_attribute :current_user

  def display
    "Hello #{current_user.name} !"
  end

end
```

```html
<p>{% hello %}</p>
<!-- produce -->
<p>Hello Homer</p>
```
## Blocks

Block are just tags with a body. They perform the same argument parsing.
To render the block body from it's `display` method you just have to `yield`:

```ruby
class PBlock < Solid::Block

  tag_name :p

  def display(options)
    "<p class='#{options[:class]}'>#{yield}</p>"
  end

end
```

```html
{% p class:"content" %}
  It works !
{% endp %}
<!-- produce -->
<p class="content">It works !</p>
```

Of course you are free to yield once, multiple times or even never.

## Conditional Blocks

Conditional blocks are blocks with two bodies. If you yield `true` you will receive the main block
and if you yield `false` you will receive the else block:

```ruby
class IfAuthorizedToTag < Solid::ConditionalBlock

  tag_name :if_authorized_to

  context_attribute :current_user

  def display(permission)
    yield(current_user.authorized_to?(permission))
  end

end
```

```html
{% if_authorized_to "publish" %}
  You are authorized !
{% else %}
  Get out !
{% endif_authorized_to %}
```

## License

Solid is released under the MIT license:

http://www.opensource.org/licenses/MIT