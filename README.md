# i18n

[![Build Status](https://travis-ci.org/TechMagister/i18n.cr.svg?branch=master)](https://travis-ci.org/TechMagister/i18n.cr)

Internationalization API

## Breaking changes from 0.3 to 0.4
- Pluralization rules are now fully suites [CLDR convention](http://cldr.unicode.org/index/cldr-spec/plural-rules). Specifically `en` pluralization no more returns `zero`

## Breaking changes from 0.2 to 0.3
- The first day of the week is now Monday according to ISO 8601.
- The nil value in `month_names` and `abbr_month_names` was removed.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  i18n:
    github: TechMagister/i18n.cr
```

## Usage

``` crystal
I18n.translate(
    "some.dot.separated.path",  # key : String
    {attr_to_interpolate: "a"}, # options : Hash | NamedTuple? = nil
    "pt",                       # force_locale : String = nil
    2,                          # count : Numeric? = nil
    "default translation",      # default : String? = nil
    nil                         # iter : Int? = nil
)

I18n.localize(
    Time.utc_now, # object : _
    "pt",         # force_locale : String = I18n.config.locale
    :time,        # scope : Symbol? = :number
    "long"        # format : String? = nil
)
```

### Arguments interpolation

Translation may include argument interpolation. For doing this use regular crystal named interpolation placeholder and pass hash or named tuple as a `options` argument:

```yaml
message:
  new: "New message: %{text}"
```

```crystal
# New message: hello
I18n.translate("message.new", {text: "hello"})
I18n.translate("message.new", {:text => "hello"})
I18n.translate("message.new", {"text" => "hello"})
```

Also any extra key-value pair will be ignored and missing one will not cause any exception:

```crystal
I18n.translate("message.new", {message: "hello"}) # New message: %{text}
```

### Configuration

```crystal
require "i18n"

I18n.load_path += ["spec/locales"]
I18n.init # This will load locales from all specified locations

I18n.default_locale = "pt" # default can be set after loading translations
```

There is a [handler](https://github.com/TechMagister/kemalyst-i18n) for Kemalyst that bring I18n configuration.

### Note on YAML Backend

Putting translations for all parts of your application in one file per locale could be hard to manage. You can store these files in a hierarchy which makes sense to you.

For example, your config/locales directory could look like this:

```console
locales
|--defaults
|----en.yml
|----pt.yml
|--models
|----en.yml
|----pt.yml
|--views
|----users
|------en.yml
|------pt.yml
```

This way you can separate model related translations from the view ones. To require all described subfolders at once use `**` - `I18n.load_path += ["locals/**/"]`

#### Date/Time Formats

To localize the time (or date) format you should pass `Time` object to the `I18n.localize`. To pick a specific format path `format` argument:

```crystal
I18n.localize(Time.local, scope: :date, format: :long)
```

> By default `Time` will be localized with `:time` scope.

To specify formats and all need localization information (like day or month names) fill your file in following way:
> NOTE: According to ISO 8601, Monday is the first day of the week

```yaml
__formats__:
  date:
    formats:
      default: '%Y-%m-%d' # is used by default
      long: '%A, %d de %B %Y'
    month_names: # long month names
      - Janeiro
      - Fevereiro
      - Março
      - Abril
      - Maio
      - Junho
      - Julho
      - Agosto
      - Setembro
      - Outubro
      - Novembro
      - Dezembro
    abbr_month_names: # month abbreviations
      - Jan
      - Fev
      # ...
    day_names: # fool day names
      - Segunda
      # ...
    abbr_day_names: # short day names
      - Seg
      # ...
```

Format accepts any crystal `Time::Format` directives. Also following directives will be automatically localized:

| Directive | Description | Key |
|---|---|---|
| `%a` | short day name | `date.abbr_day_names` |
| `%A` | day name | `date.day_names` |
| `%b` | short month name | `date.abbr_month_names` |
| `%B` | month name | `date.month_names` |
| `%p` | am-pm (lowercase) | `time.am`/`time.pm` |
| `%P` | AM-PM (uppercase) | `time.am`/`time.pm` |

#### Pluralization

In many languages — including English — there are only two forms, a singular and a plural, for a given string, e.g. "1 message" and "2 messages". Other languages (Arabic, Japanese, Russian and many more) have different grammars that have additional or fewer plural forms.

The `count` interpolation variable has a special role in that it both is interpolated to the translation and used to pick a pluralization from the translations according to the pluralization rules defined by CLDR:

```yaml
message:
  one: "%{count} message"
  other: "%{count} messages"
```

```crystal
I18n.translate("message", count: 1) # 1 message
I18n.translate("message", count: 2) # 2 messages
I18n.translate("message", count: 0) # 0 messages
```

> `count` should be passed as argument - not inside of `options`. Otherwise regular translation lookup will be applied.

I18n defines default [CLDR rules](http://cldr.unicode.org/index/cldr-spec/plural-rules) for many locales (see `src/i18n/config/plural_rules`), however they can be overwritten:

```crystal
I18n.plural_rules["ru"] = ->(n : Int32) {
  if n == 0
    :zero
  elsif ((n % 10) == 1) && ((n % 100 != 11))
    # 1, 21, 31, 41, 51, 61...
    :one
  elsif ([2, 3, 4].includes?(n % 10) && ![12, 13, 14].includes?(n % 100))
    # 2-4, 22-24, 32-34...
    :few
  elsif ((n % 10) == 0 || ![5, 6, 7, 8, 9].includes?(n % 10) || ![11, 12, 13, 14].includes?(n % 100))
    # 0, 5-20, 25-30, 35-40...
    :many
  else
    :other
  end
}
```

```yaml
kid:
  zero: 'нет детей'
  one: '%{count} ребенок'
  few: '%{count} ребенка'
  many: '%{count} детей'
  other: '%{count} детей'
```

```crystal
I18n.locale = "ru"

I18n.translate("kid", count: 0) # нет детей
I18n.translate("kid", count: 1) # 1 ребенок
I18n.translate("kid", count: 2) # 2 ребенка
I18n.translate("kid", count: 6) # 6 детей
```

#### Iteration

To store several alternative objects under one localization key they could be just listed in the file and later retrieved using `iter` argument:

> NOTE : The first index is `0`

```yaml
__formats__:
  date:
    day_names: [Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday]
```

```crystal
I18n.translate("__formats__.date.day_names", iter: 2)  # >>> "Wednesday"
```

### Embedding translations inside your binary

You can embed translations inside your binary by using the following macro call:

```crystal
I18n::Backend::Yaml.embed(["some/locale/directory", "some/other/locale/directory"])
```

## Development

TODO :

- [ ] Add more backends ( Database, json based, ruby based ( why not ? ))
- [ ] others ( there is always something to add ... or remove )

## Contributing

1. Fork it ( https://github.com/TechMagister/i18n/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [[TechMagister]](https://github.com/TechMagister) Arnaud Fernandés - creator, maintainer
- [[imdrasil]](https://github.com/imdrasil) Roman Kalnytskyi

Inspiration taken from:

- https://github.com/whity/crystal-i18n
- https://github.com/mattetti/i18n
