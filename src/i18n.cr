require "./i18n/*"

module I18n
  extend self

  macro define_delegators(names)
    {% for name in names %}
      def {{name.id}}
        config.{{name.id}}
      end

      def {{name.id}}=(value)
        config.{{name.id}} = (value)
      end
    {% end %}
  end

  # Gets I18n configuration object.
  def config
    @@inner_config ||= Config.new
  end

  # Sets I18n configuration object.
  def config=(value)
    @@inner_config = value
  end

  def init
    load_path.each do |path|
      config.backend.load(path)
    end
  end

  define_delegators(%w(locale backend default_locale available_locales default_separator exception_handler load_path plural_rules))

  # Translates, pluralizes and interpolates a given key using a given locale, default, as well as interpolation values.
  #
  # #### INTERPOLATION
  #
  # Translations can contain interpolation variables which will be replaced by values passed to #translate as part of
  # the options hash, with the keys matching the interpolation variable names.
  #
  # E.g., with a translation `"foo" => "foo %{bar}"` the option value for the key `bar` will be interpolated into the
  # translation:
  #
  # ```
  # I18n.translate("foo", {"bar" => "baz"}) # => 'foo baz'
  # ```
  #
  # #### PLURALIZATION
  #
  # Translation data can contain pluralized translations. Pluralized translations are arrays of singular/plural versions
  # of translations like `["Foo", "Foos"]`.
  #
  # This returns the singular version of a pluralized translation:
  #
  # ```
  # I18n.translate("foo", count: 1) # => "Foo"
  # ```
  #
  # #### DEFAULTS
  #
  # This returns the translation for `"foo"` or `"default"` if no translation was found:
  #
  # ```
  # I18n.translate("foo", default: "default')
  # ```
  def translate(key : String, options : Hash | NamedTuple? = nil, force_locale = config.locale, count = nil, default = nil, iter = nil) : String
    raise I18n::ArgumentError.new if key.empty?

    backend = config.backend

    begin
      backend.translate(force_locale, key, options: options, count: count, default: default)
    rescue e
      e.inspect
    end
  end

  # Returns whether a translation exists for a given key.
  def exists?(key : String, force_locale = config.locale, count = nil) : Bool
    config.backend.exists?(force_locale, key, count: count)
  end

  # Localizes certain objects, such as dates and numbers to local formatting.
  def localize(object, force_locale = config.locale, *args, **options) : String
    config.backend.localize(force_locale, object, *args, **options)
  rescue e
    e.inspect
  end

  # Executes block with given I18.locale set.
  def with_locale(tmp_locale)
    current_locale = config.locale
    config.locale = tmp_locale

    yield
  ensure
    config.locale = current_locale
  end
end
