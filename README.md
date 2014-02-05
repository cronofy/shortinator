# Shortinator

Library for creating a short url

## Installation

Add this line to your application's Gemfile:

    gem 'shortinator'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install shortinator

## Configuration

```ruby
Shortinator.store_url = "mongodb://<url to server>"
Shortinator.host = "http://sho.rt"
```

Can also be set with `SHORTINATOR_STORE_URL` and `SHORTINATOR_HOST` environment variables.

## Usage

Shorten a URL and tag it

```ruby
shortened_url = Shortinator.shorten("http://company.com/a/very/long/url", "daily_update")
```

Track a click on a url

```ruby
Shortinator.click(id, "12.34.55.124")
```

## Web Host

This operates with companion project https://github.com/adambird/shortinator-web to provide the redirect


## Contributing

1. Fork it ( http://github.com/adambird/shortinator/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
