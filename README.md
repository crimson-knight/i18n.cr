# i18n

Internationalization API

## Installation


Add this to your application's `shard.yml`:

```yaml
dependencies:
  i18n:
    github: TechMagister/i18n.cr
```


## Usage

``` crystal
I18n.translate(locale : String, key : String, count = nil, default = nil, iter = nil, format = nil) : String

I18n.localize(locale : String, object, scope = :number, format = nil) : String
```

```crystal
require "i18n"

I18n.load_path += ["spec/locales"]
I18n.init

I18n.default_locale = "pt" # default can be set after loading translations

I18n.localize(123.123, scope: :currency) # => "123,123€"
I18n.translate("hello")                  # => "olá"

```

### Note on YAML Backend

The yaml backen allow to embed translations into the executable.

``` crystal
require "i18n"

I18n.backend = I18n::Backend::Yaml.new
I18n.backend.as(I18n::Backend::Yaml).embed ["spec/locales"]

I18n.default_locale = "en" # default can be set after loading translations

env_lang = ENV["LANG"][0,2]
if I18n.available_locales.includes? env_lang
    I18n.locale = env_lang
end
```

## Development

TODO :
- [ ] Add more backends ( Database, json based, ruby based ( why not ? ))
- [ ] others

## Contributing

1. Fork it ( https://github.com/[your-github-name]/i18n/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [[TechMagister]](https://github.com/TechMagister) Arnaud Fernandés - creator, maintainer

Some parts are taken from :
- https://github.com/whity/crystal-i18n
- https://github.com/mattetti/i18n
